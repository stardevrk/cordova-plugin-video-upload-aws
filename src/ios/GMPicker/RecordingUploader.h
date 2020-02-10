//
//  RecordingUploader.h
//  MyApp
//
//  Created by DevMaster on 2/9/20.
//

#import <UIKit/UIKit.h>
#import "ProgressViewController.h"
#import "RecordingView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecordingUploaderDelegate;

@interface RecordingUploader : UIViewController

@property (nonatomic) NSURL *recordingToBeUploaded;
@property (nonatomic) NSMutableDictionary *recordingUploadResult;

@property (nonatomic) NSString *recordingBucket;
@property (nonatomic) NSString *recordingFolder;

@property(nonatomic, copy) ProgressViewController *progressController;

@property (nonatomic, weak) id <RecordingUploaderDelegate> delegate;

- (void)setupRecordedURL:(NSURL *)recordedFile;

- (void)setupRecodingAWSS3:(NSString *)CognitoPoolID region:(NSString *)region bucket:(NSString *)bucket folder:(NSString *)folder;

- (void)finishUploadingRecordFile:(id)sender;

@end

@protocol RecordingUploaderDelegate <NSObject>

- (void)recordingUploadController:(RecordingUploader *)controller didFinishUploading:(NSMutableDictionary *)uploadingResult;

@end

NS_ASSUME_NONNULL_END
