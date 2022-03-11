//
//  LivePreview.m
//  MyApp
//
//  Created by DevMaster on 8/18/20.
//

#import "LivePreview.h"
#import "AppDelegate+VideoUpload.h"
#include <putMedia.h>


@implementation LivePreview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.originalRect = frame;
        NSLog(@"Init Frame ==== %f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        self.originSize = CGSizeMake(frame.size.width, frame.size.height);
        self.bottomOffset = 60;
        self.originalPoint = CGPointMake(30, self.superview.frame.size.height - frame.size.height - self.bottomOffset);
        [self requestAccessForVideo];
        [self requestAccessForAudio];
//        self.fullscreenMode = false;
        
        if (!_closeBtn) {
            CGRect closeBtnRect = CGRectMake(120, 10, 40, 40);
           _closeBtn = [[UIButton alloc] init];
           _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
           _closeBtn.frame = closeBtnRect;
           [_closeBtn setBackgroundImage:[UIImage imageNamed:@"minimize"] forState:UIControlStateNormal];
           [_closeBtn addTarget:self action:@selector(changeInlayView) forControlEvents:UIControlEventTouchUpInside];
        }
       
        if (!_removeBtn) {
            CGRect removeBtnRect = CGRectMake(10, 10, 70, 40);
            _removeBtn = [[UIButton alloc] init];
            _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _removeBtn.frame = removeBtnRect;
            [_removeBtn setBackgroundImage:[UIImage imageNamed:@"live"] forState:UIControlStateNormal];
        }
        if (!_controlBtn) {
            CGRect controlBtnRect = CGRectMake(80, 160, 60, 60);
           _controlBtn = [[UIButton alloc] init];
           _controlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
           _controlBtn.frame = controlBtnRect;
           [_controlBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
           _controlBtn.exclusiveTouch = true;
           [_controlBtn addTarget:self action:@selector(removeRecordingView) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (!_stateLabel) {
            CGRect labelRect = CGRectMake(70, 100, 130, 20);
            _stateLabel = [[UILabel alloc] initWithFrame:labelRect];
            _stateLabel.text = @"00:00";
            _stateLabel.textColor = [UIColor whiteColor];
            _stateLabel.backgroundColor = [UIColor redColor];
            _stateLabel.layer.cornerRadius = 5;
            _stateLabel.layer.masksToBounds = true;
            _stateLabel.textAlignment = NSTextAlignmentCenter;
            _stateLabel.text = @"Not Sending";
            _stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
        }

        self.currentScaleFactor = 1.0f;
        self.streaming = false;
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = true;
        [self addSubview:self.stateLabel];
        [self updateStateLabel];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        UITapGestureRecognizer *singleFingerTap =
          [[UITapGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
    
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(changeOrientation)    name:UIDeviceOrientationDidChangeNotification  object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(checkStreaming)    name:UIApplicationDidEnterBackgroundNotification  object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(checkStreaming)    name:UIApplicationDidReceiveMemoryWarningNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeStreaming) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopStreaming) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        AppDelegate* shared=[UIApplication sharedApplication].delegate;
        [shared saveBlockRotation:TRUE];
    }
    return self;
}

- (void) setupPreview:(NSString*)rtmpURL
{
    _rtmpURL = [[NSString alloc] initWithString:rtmpURL];
    [self addSubview:self.closeBtn];
    [self addSubview:self.stateLabel];
    [self addSubview:self.removeBtn];
    
    [self touchPreview];
//    [self.avSession startRunning];
}

- (void) addButtons
{
    self.closeBtn.center = CGPointMake(self.frame.size.width - 30, 70);
    self.removeBtn.center = CGPointMake(45, 70);
    self.controlBtn.center = CGPointMake(self.frame.size.width / 2, self.superview.frame.size.height - 50);
    [self addSubview:self.removeBtn];
    [self addSubview:self.closeBtn];
    [self addSubview:self.controlBtn];
}

- (void) removeButtons
{
    [self.closeBtn removeFromSuperview];
    [self.removeBtn removeFromSuperview];
    [self.controlBtn removeFromSuperview];
}

- (void) updateStateLabel
{
    self.stateLabel.center = CGPointMake(self.frame.size.width / 2, self.superview.frame.size.height - 90);
}

- (void) changeFrameFullscreen
{
    CGRect newFrame = self.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = 0;
    newFrame.size.height = self.superview.frame.size.height;
    newFrame.size.width = self.superview.frame.size.width;
    self.frame = newFrame;
    self.previewLayer.frame = self.bounds;
    self.layer.masksToBounds = true;
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];
}

- (void) changeFrameOrigin
{
//    CGRect newFrame = self.frame;
//    newFrame.origin.x = self.originalPoint.x;
//    newFrame.origin.y = self.originalPoint.y;
//    newFrame.size = self.originSize;
    self.frame = self.originalRect;
    self.previewLayer.frame = self.bounds;
    self.layer.masksToBounds = true;
    [super layoutSubviews];
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];
}

- (void) initPreviewState
{
    self.fullscreenMode = false;
}

- (void) initSessionWithStream: (NSString*) streamName
{
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.encodeQueue = dispatch_queue_create("encode queue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(self.sessionQueue, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"pem"];
        const char* cfilePath = [path UTF8String];
        const char* sName = [streamName UTF8String];
        // initPutMedia(sName, "AKIAUFGOIX4NXI5V6DE   T", "Hnt+cR/O9CIEvQnRgMc64KN0GqDWZN2jbDxfIK0   d", cfilePath);
        
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        if (self.audioDevice == nil)
        {
            printf("Couldn't create audio capture device");
        }
        
        self.avSession = [[AVCaptureSession alloc] init];
        self.avSession.sessionPreset = AVCaptureSessionPreset640x480;
        
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioDevice error:nil];
        AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [audioOutput setSampleBufferDelegate:self queue:self.encodeQueue];
        [audioOutput connectionWithMediaType:AVMediaTypeAudio];
        if ([_avSession canAddInput:audioInput]) {
            [_avSession addInput:audioInput];
        }
        if ([_avSession canAddOutput:audioOutput]) {
            [_avSession addOutput:audioOutput];
        }
        AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
        if ([self.avSession canAddInput:videoInput]) {
            [self.avSession addInput:videoInput];
        }
        
        self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [self.videoOutput setAlwaysDiscardsLateVideoFrames:NO];
        [self.videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        [self.videoOutput setSampleBufferDelegate:self queue:self.encodeQueue];
        if ([self.avSession canAddOutput:self.videoOutput]) {
            [self.avSession addOutput:self.videoOutput];
        }
        
        AVCaptureConnection *connection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        
        self.videoEncoder = [[H264Encoder alloc] init];
//        self.audioEncoder = [[AACEncoder alloc] init];
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.avSession];
        _previewLayer.frame = self.bounds;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.layer addSublayer:_previewLayer];
        
        [self.avSession startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        });
        self.streaming = TRUE;
    });
    
}

- (void)startSession
{
    
    dispatch_sync(self.sessionQueue, ^{
        [self.avSession startRunning];
    });
    
}
- (void)stopSession
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    dispatch_sync(self.sessionQueue, ^{
        [self.avSession stopRunning];
    });
}

- (void) setupProducer
{
    
}

- (void) stopStreaming
{
    self.streaming = FALSE;
}

- (void) resumeStreaming
{
    [self.videoEncoder stopH264Encode];
    self.videoEncoder = [[H264Encoder alloc] init];
    self.streaming = TRUE;
}




#pragma mark -- Public Method
- (void)requestAccessForVideo{
//    __weak typeof(self); _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            
            //dispatch_async(dispatch_get_main_queue(), ^{
//            [self.session setRunning:YES];
            //});
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            
            break;
        default:
            break;
    }
}

- (void)requestAccessForAudio{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}

- (void)addZoomControl
{
    UIPinchGestureRecognizer * pinGeture =  [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchZoom:)];
    [self addGestureRecognizer:pinGeture];
}

- (void) checkDeviceOrientation
{
    if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft)
    {
//        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
//        if (self.session) {
//            [self.session changeOrientation:1];
//        }

    }
    else if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight)
    {
//        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
//        if (self.session) {
//            [self.session changeOrientation:2];
//        }

    }
    else if (UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait)
    {
//        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
//        if (self.session) {
//            [self.session changeOrientation:0];
//        }
    } else {
//        if (self.session) {
//            [self.session changeOrientation:0];
//        }
    }
    
    if (self.fullscreenMode == false)
    {
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = true;
    } else {
        self.layer.cornerRadius = 0;
        self.layer.masksToBounds = true;
    }
}

- (void)handlerFrame
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect newFrame = self.frame;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        newFrame.size = self.originSize;
        newFrame.origin.x = self.originalPoint.x;
        newFrame.origin.y = self.superview.frame.size.height - self.originSize.height - self.bottomOffset;
        self.stateLabel.center = CGPointMake(self.originSize.width / 2, self.originSize.height - 20);
    } else {
        CGSize landscapeSize = CGSizeMake(self.originSize.height, self.originSize.width);
        newFrame.size = landscapeSize;
        newFrame.origin.x = self.originalPoint.x;
        newFrame.origin.y = self.superview.frame.size.height - landscapeSize.height - self.bottomOffset;
        self.stateLabel.center = CGPointMake(self.originSize.height / 2, self.originSize.width - 20);
    }
    
    self.frame = newFrame;
    [self checkDeviceOrientation];
}

- (void)changeOrientation
{
    
//    if (self.fullscreenMode == false)
//    {
//        [self handlerFrame];
//    }
//    else
//    {
//        CGRect newFrame = self.frame;
//        newFrame.origin.x = 0;
//        newFrame.origin.y = 0;
//        newFrame.size.height = self.superview.frame.size.height;
//        newFrame.size.width = self.superview.frame.size.width;
//        self.frame = newFrame;
//        self.closeBtn.center = CGPointMake(self.superview.frame.size.width - 30, 70);
//        self.controlBtn.center = CGPointMake(self.superview.frame.size.width / 2, self.superview.frame.size.height - 50);
//        self.stateLabel.center = CGPointMake(self.superview.frame.size.width / 2, self.superview.frame.size.height - 90);
//        [self checkDeviceOrientation];
//    }
}

- (void)setupOriginalViewPort:(CGSize)viewSize leftCorner:(CGPoint)viewPoint bottomOffset:(CGFloat)bottomPoint startOrientation:(Boolean)isPortrait startingParentSize:(CGSize)parentSize
{
    self.originSize = viewSize;
    self.originalPoint = viewPoint;
    self.bottomOffset = bottomPoint;
    CGRect newFrame = self.frame;
    if (isPortrait)
    {
        newFrame.size = self.originSize;
        newFrame.origin.x = self.originalPoint.x;
        newFrame.origin.y = parentSize.height - self.originSize.height - self.bottomOffset;
    } else {
        CGSize landscapeSize = CGSizeMake(self.originSize.height, self.originSize.width);
        newFrame.size = landscapeSize;
        newFrame.origin.x = self.originalPoint.x;
        newFrame.origin.y = parentSize.height - landscapeSize.height - self.bottomOffset;
    }
    self.fullscreenMode = false;
    self.stateLabel.center = CGPointMake(self.originSize.width / 2, self.originSize.height - 20);
    [self checkDeviceOrientation];
    
    self.frame = newFrame;
    
}

- (void)changeInlayView
{
    
//    [self handlerFrame];
    [self removeButtons];
    [self changeFrameOrigin];
//    [self updateStateLabel];
//    self.fullscreenMode = false;
}

- (void)touchPreview
{
//    self.stateLabel.hidden = false;
    
//    if (self.fullscreenMode == false)
//    {
        [self changeFrameFullscreen];
//        [self checkDeviceOrientation];
        [self addButtons];
//        [self updateStateLabel];
//        self.fullscreenMode = true;
//    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"PreViewTouched");
    [self touchPreview];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    
    
}

- (void)removeRecordingView
{
    /*Initialize properties*/
    self.fullscreenMode = false;
    self.streaming = FALSE;
    [self changeFrameOrigin];
    [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
    [self stopStreaming];
    [self stopSession];
    AppDelegate* shared=[UIApplication sharedApplication].delegate;
    [shared saveBlockRotation:FALSE];
    [self removeFromSuperview];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:@"finished" forKey:@"status"];
    if ([self.delegate respondsToSelector:@selector(livePreviewController:finished:)]) {
        [self.delegate livePreviewController:self finished:result];
    }
}

- (void)checkStreaming
{
    if (self.streaming && self.session) {
//        [self.session stopLive];
    }
//    stopPutMedia();
//    [self.avSession stopRunning];
}

#pragma mark -- Recognizer
- (void)handlePinchZoom:(UIPinchGestureRecognizer *)pinchRecognizer
{
    
    CGFloat maxZoomFactor = 3.0;
    const CGFloat pinchVelocityDividerFactor = 2.0f;
    if (pinchRecognizer.state == UIGestureRecognizerStateChanged || pinchRecognizer.state ==UIGestureRecognizerStateBegan)
    {
        
            CGFloat desiredZoomFactor = self.currentScaleFactor +
              atan2f(pinchRecognizer.velocity, pinchVelocityDividerFactor);

        self.currentScaleFactor = MAX(1.0, MIN(desiredZoomFactor, maxZoomFactor));
//        [self.session setZoomScale:self.currentScaleFactor];
    }
    
 }


#pragma mark -- LFStreamingSessionDelegate

- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    NSLog(@"liveStateDidChange: %ld", state);
    self.stateLabel.hidden = false;
    switch (state) {
        case LFLiveReady:
            _stateLabel.text = @"Not Connected";
            _streaming = false;
            [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
            break;
        case LFLivePending:
            _stateLabel.text = @"Connecting...";
            _streaming = false;
            [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
            break;
        case LFLiveStart:
            _stateLabel.text = @"Connected";
            _streaming = true;
            [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"StopIcon"] forState:UIControlStateNormal];
            break;
        case LFLiveError:
            _stateLabel.text = @"Connection Error";
            [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
            _streaming = false;
            break;
        case LFLiveStop:
            _stateLabel.text = @"Not Connected";
            [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
            _streaming = false;
            break;
        default:
            break;
    }
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug*)debugInfo{
    NSLog(@"debugInfo: %lf", debugInfo.dataFlow);
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession*)session errorCode:(LFLiveSocketErrorCode)errorCode{
    NSLog(@"errorCode: %ld", errorCode);
}

#pragma mark -- Getter Setter
- (LFLiveSession*)session{
    if(!_session){
//        LFLiveVideoConfiguration* videoConfig = [LFLiveVideoConfiguration defaultConfiguration];
//        [videoConfig setAutorotate:true];
//       _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfig];
//
//        _session.delegate = self;
//        _session.preView = self;
//
//        [_session setCaptureDevicePosition:AVCaptureDevicePositionBack];
//        [_session setMuted:true];
    }
    return _session;
}


-(void)clickStartButton
{
    self.controlBtn.selected = !self.controlBtn.selected;
    if(self.controlBtn.selected){
//        LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
//        stream.url = self.rtmpURL;
//        [self.session startLive:stream];
        [self startSession];
        
    }else{
//        [self.session stopLive];
        [self stopSession];
    }
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate AVCaptureAudioDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
        if (captureOutput == self.videoOutput) {
            NSLog(@"Video Sample Buffer ~~~~~");
            if (self.streaming == TRUE) {
                [self.videoEncoder startH264EncodeWithSampleBuffer:sampleBuffer andReturnData:^(NSData *data) {
                    NSUInteger len = [data length];
                    void *typedData = malloc(len);
                    memcpy(typedData, [data bytes], len);
                    putMedia(typedData, len);
                }];
            }
        }
        else
        {
//            dispatch_sync(self.encodeQueue, ^{
//                [self.audioEncoder encodeSampleBuffer:sampleBuffer completionBlock:^(NSData *encodedData, NSError *error) {
////                    NSUInteger len = [encodedData length];
////                    void *typedData = malloc(len);
////                    memcpy(typedData, [encodedData bytes], len);
////                    putAudio(typedData, len);
//                }];
//            });
        }
}

- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
