#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

#import "GMImagePickerController.h"
#import "RecordingView.h"
#import "RecordingUploader.h"

@interface VideoUpload : CDVPlugin <GMImagePickerControllerDelegate, RecordingUploaderDelegate, RecordingViewDelegate>

@property(nonatomic, copy) NSString* actionCallbackId;

@property(nonatomic, copy) GMImagePickerController* picker;
@property(nonatomic, copy) RecordingView* recordingView;
@property(nonatomic, copy) RecordingUploader *recordingUploader;

- (void)init:(CDVInvokedUrlCommand*)command;

- (void)startUpload:(CDVInvokedUrlCommand*)command;

@end
