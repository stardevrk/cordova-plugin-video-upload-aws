//
//  VidUploader.h
//  PitchAware
//
//  Created by DevMaster on 9/15/21.
//

#import <Foundation/Foundation.h>

@protocol VidUploaderDelegate;

@interface VidUploader : NSObject

@property (nonatomic) NSURL *recordingToBeUploaded;
@property (nonatomic) NSMutableDictionary *recordingUploadResult;

@property (nonatomic) NSString *recordingBucket;
@property (nonatomic) NSString *recordingFolder;

@property (nonatomic, weak) id <VidUploaderDelegate> delegate;

- (void)setupRecordedURL:(NSURL *)recordedFile;

- (void)setupRecodingAWSS3:(NSString *)CognitoPoolID region:(NSString *)region bucket:(NSString *)bucket folder:(NSString *)folder;

- (void) uploadRecodingFile;

@end

@protocol VidUploaderDelegate <NSObject>

- (void)vidUploadController:(VidUploader *)uploader finished:(NSMutableDictionary *)uploadingResult;

- (void)vidUploadController:(VidUploader *)uploader didPercent:(double)percent;

- (void)vidUploadController:(VidUploader *)uploader memeryLeak:(NSString *)memory;

@end
