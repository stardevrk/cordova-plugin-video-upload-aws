//
//  HJH264Encoder.m
//  Smart_Device_Server
//
//  Created by Josie on 2017/9/21.
//  Copyright © 2017年 Josie. All rights reserved.
//
//  视频编码
//  使用videoToolbox进行硬编码

#import "H264Encoder.h"
#import <VideoToolbox/VideoToolbox.h>

@interface H264Encoder()
{
    int frameID;
    dispatch_queue_t m_EncodeQueue;
    VTCompressionSessionRef EncodingSession;
    
}
@end


@implementation H264Encoder

- (instancetype)init
{
    self = [super init];
    if (self) {
        m_EncodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); // 获取全局队列，后台执行
        [self initVideoToolBox];
        
    }
    return self;
}


-(void)startH264EncodeWithSampleBuffer:(CMSampleBufferRef)sampleBuffer andReturnData:(ReturnDataBlock)block
{
    self.returnDataBlock = block;
    
    dispatch_sync(m_EncodeQueue, ^{
        [self encode:sampleBuffer];
    });
}


-(void)stopH264Encode
{
    [self EndVideoToolBox];
}

- (void)initVideoToolBox {
    dispatch_sync(m_EncodeQueue  , ^{  // 在后台 同步执行 （同步，需要加锁）
        frameID = 0;
        
        // ----- 1. 创建session -----
        int width = 480, height = 640;
        OSStatus status = VTCompressionSessionCreate(NULL, width, height,
                                                     kCMVideoCodecType_H264, NULL, NULL, NULL,
                                                     didCompressH264, (__bridge void *)(self),  &EncodingSession);
        NSLog(@"H264: VTCompressionSessionCreate %d", (int)status);
        if (status != 0)
        {
            NSLog(@"H264: session 创建失败");
            return ;
        }
        
        // ----- 2. 设置session属性 -----
        // 设置实时编码输出（避免延迟）
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_RealTime, kCFBooleanTrue);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
        
        // 设置关键帧（GOPsize)间隔
        int frameInterval = 10;
        CFNumberRef  frameIntervalRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &frameInterval);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, frameIntervalRef);
        
        // 设置期望帧率
        int fps = 10;
        CFNumberRef  fpsRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &fps);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_ExpectedFrameRate, fpsRef);
        
        
        //设置码率，上限，单位是bps
        int bitRate = width * height * 3 * 4 * 8;
        CFNumberRef bitRateRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRate);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_AverageBitRate, bitRateRef);
        
        //设置码率，均值，单位是byte
        int bitRateLimit = width * height * 3 * 4;
        CFNumberRef bitRateLimitRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &bitRateLimit);
        VTSessionSetProperty(EncodingSession, kVTCompressionPropertyKey_DataRateLimits, bitRateLimitRef);
        
        // Tell the encoder to start encoding
        VTCompressionSessionPrepareToEncodeFrames(EncodingSession);
    });
}


// 把编码后的数据写入TCP文件
-(void)returnDataToTCPWithHeadData:(NSData*)headData andData:(NSData*)data
{
    printf("---- video 编码后的数据data大小 = %d + %d \n",(int)[headData length] ,(int)[data length]);
    NSMutableData *tempData = [NSMutableData dataWithData:headData];
    [tempData appendData:data];
    
    
    // 传给socket
    if (self.returnDataBlock) {
        self.returnDataBlock(tempData);
    }
}

-(void)returnData:(NSData*)data
{
//    printf("---- video data = %d + \n",(int)[data length]);
    
    if (self.returnDataBlock) {
        self.returnDataBlock(data);
    }
}


// -------- 3. 传入编码帧 ---------
- (void) encode:(CMSampleBufferRef )sampleBuffer
{
    CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    // 帧时间，如果不设置会导致时间轴过长。
    CMTime presentationTimeStamp = CMTimeMake(frameID++, 1000); // CMTimeMake(分子，分母)；分子/分母 = 时间(秒)
    VTEncodeInfoFlags flags;
    OSStatus statusCode = VTCompressionSessionEncodeFrame(EncodingSession,
                                                          imageBuffer,
                                                          presentationTimeStamp,
                                                          kCMTimeInvalid,
                                                          NULL, NULL, &flags);
    if (statusCode != noErr) {
        NSLog(@"H264: VTCompressionSessionEncodeFrame failed with %d", (int)statusCode);
        
        VTCompressionSessionInvalidate(EncodingSession);
        CFRelease(EncodingSession);
        EncodingSession = NULL;
        return;
    }
}

// 编码完成回调
void didCompressH264(void *outputCallbackRefCon,
                     void *sourceFrameRefCon,
                     OSStatus status,
                     VTEncodeInfoFlags infoFlags,
                     CMSampleBufferRef sampleBuffer)
{
//    NSLog(@"didCompressH264 called with status %d infoFlags %d", (int)status, (int)infoFlags); // 0 1
    if (status != 0) {
        return;
    }
    
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        NSLog(@"didCompressH264 data is not ready ");
        return;
    }
//    ViewController* encoder = (__bridge ViewController*)outputCallbackRefCon;
    
    H264Encoder *encoder = (__bridge H264Encoder*)(outputCallbackRefCon);
    
//    // ----- 关键帧获取SPS和PPS ------
//    bool keyframe = !CFDictionaryContainsKey( (CFArrayGetValueAtIndex(CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, true), 0)), kCMSampleAttachmentKey_NotSync);
//    // 判断当前帧是否为关键帧
//    // 获取sps & pps数据
//    if (keyframe)
//    {
//        CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
//        size_t sparameterSetSize, sparameterSetCount;
//        const uint8_t *sparameterSet;
//        OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sparameterSet, &sparameterSetSize, &sparameterSetCount, 0 );
//        if (statusCode == noErr)
//        {
//            // Found sps and now check for pps
//            size_t pparameterSetSize, pparameterSetCount;
//            const uint8_t *pparameterSet;
//            OSStatus statusCode = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pparameterSet, &pparameterSetSize, &pparameterSetCount, 0 );
//            if (statusCode == noErr)
//            {
//                // Found pps
//                NSData *sps = [NSData dataWithBytes:sparameterSet length:sparameterSetSize];
//                NSData *pps = [NSData dataWithBytes:pparameterSet length:pparameterSetSize];
//                if (encoder)
//                {
//                    [encoder gotSpsPps:sps pps:pps];  // 获取sps & pps数据
//                }
//            }
//        }
//    }
//
//
//    // --------- 写入数据 ----------
//    CMBlockBufferRef dataBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
//    size_t length, totalLength;
//    char *dataPointer;
//    OSStatus statusCodeRet = CMBlockBufferGetDataPointer(dataBuffer, 0, &length, &totalLength, &dataPointer);
//    if (statusCodeRet == noErr) {
//        size_t bufferOffset = 0;
//        static const int AVCCHeaderLength = 4; // 返回的nalu数据前四个字节不是0001的startcode，而是大端模式的帧长度length
//
//        // 循环获取nalu数据
//        while (bufferOffset < totalLength - AVCCHeaderLength) {
//            uint32_t NALUnitLength = 0;
//            // Read the NAL unit length
//            memcpy(&NALUnitLength, dataPointer + bufferOffset, AVCCHeaderLength);
//
//            // 从大端转系统端
//            NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
//
//            NSData* data = [[NSData alloc] initWithBytes:(dataPointer + bufferOffset + AVCCHeaderLength) length:NALUnitLength];
//            [encoder gotEncodedData:data isKeyFrame:keyframe];
//
//            // Move to the next NAL unit in the block buffer
//            bufferOffset += AVCCHeaderLength + NALUnitLength;
//        }
//    }
    
    NSMutableData *elementaryStream = [NSMutableData data];
    BOOL isIFrame = NO;
    CFArrayRef attachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, 0);
    if (CFArrayGetCount(attachmentsArray)) {
       CFBooleanRef notSync;
       CFDictionaryRef dict = CFArrayGetValueAtIndex(attachmentsArray, 0);
       BOOL keyExists = CFDictionaryGetValueIfPresent(dict,
                                                      kCMSampleAttachmentKey_NotSync,
                                                      (const void **)&notSync);
       // An I-Frame is a sync frame
       isIFrame = !keyExists || !CFBooleanGetValue(notSync);
    }
    static const size_t startCodeLength = 4;
    static const uint8_t startCode[] = {0x00, 0x00, 0x00, 0x01};
    
    if (isIFrame) {
           CMFormatDescriptionRef description = CMSampleBufferGetFormatDescription(sampleBuffer);
          
           // Find out how many parameter sets there are
           size_t numberOfParameterSets;
           CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description,
                                                              0, NULL, NULL,
                                                              &numberOfParameterSets,
                                                              NULL);
          
           // Write each parameter set to the elementary stream
           for (int i = 0; i < numberOfParameterSets; i++) {
               const uint8_t *parameterSetPointer;
               size_t parameterSetLength;
               CMVideoFormatDescriptionGetH264ParameterSetAtIndex(description,
                                                                  i,
                                                                  &parameterSetPointer,
                                                                  &parameterSetLength,
                                                                  NULL, NULL);
              
               // Write the parameter set to the elementary stream
               [elementaryStream appendBytes:startCode length:startCodeLength];
               [elementaryStream appendBytes:parameterSetPointer length:parameterSetLength];
           }
       }
    
    // Get a pointer to the raw AVCC NAL unit data in the sample buffer
       size_t blockBufferLength;
       uint8_t *bufferDataPointer = NULL;
       CMBlockBufferGetDataPointer(CMSampleBufferGetDataBuffer(sampleBuffer),
                                   0,
                                   NULL,
                                   &blockBufferLength,
                                   (char **)&bufferDataPointer);
      
       // Loop through all the NAL units in the block buffer
       // and write them to the elementary stream with
       // start codes instead of AVCC length headers
       size_t bufferOffset = 0;
       static const int AVCCHeaderLength = 4;
       while (bufferOffset < blockBufferLength - AVCCHeaderLength) {
           // Read the NAL unit length
           uint32_t NALUnitLength = 0; memcpy(&NALUnitLength, bufferDataPointer + bufferOffset, AVCCHeaderLength);
           // Convert the length value from Big-endian to Little-endian
           NALUnitLength = CFSwapInt32BigToHost(NALUnitLength);
           // Write start code to the elementary stream
           [elementaryStream appendBytes:startCode length:startCodeLength];
           // Write the NAL unit without the AVCC length header to the elementary stream
           [elementaryStream appendBytes:bufferDataPointer + bufferOffset + AVCCHeaderLength length:NALUnitLength]; // Move to the next NAL unit in the block buffer
           bufferOffset += AVCCHeaderLength + NALUnitLength;
       }
    
    [encoder returnData: elementaryStream];
}

- (void)EndVideoToolBox
{
    if (EncodingSession) {
        VTCompressionSessionCompleteFrames(EncodingSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(EncodingSession);
        CFRelease(EncodingSession);
        EncodingSession = NULL;
    }
}

@end
