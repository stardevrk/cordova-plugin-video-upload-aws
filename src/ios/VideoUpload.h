#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

#import "GMImagePickerController.h"
#import "RecordingView.h"
#import "RecordingUploader.h"
#import "LivePreview.h"

@interface VideoUpload : CDVPlugin <GMImagePickerControllerDelegate, RecordingUploaderDelegate, RecordingViewDelegate>

@property(nonatomic, copy) NSString* actionCallbackId;
@property(nonatomic, copy) NSString* watcherCallbackId;

@property(nonatomic, copy) GMImagePickerController* picker;
@property(nonatomic, copy) RecordingView* recordingView;
@property(nonatomic, copy) RecordingUploader *recordingUploader;
@property(nonatomic, copy) LivePreview *livePreview;

- (void)init:(CDVInvokedUrlCommand*)command;

- (void)startUpload:(CDVInvokedUrlCommand*)command;

- (void)initLive:(CDVInvokedUrlCommand*)command;

- (void)startBroadcast:(CDVInvokedUrlCommand*)command;

- (void)addWatcher:(CDVInvokedUrlCommand*)command;

@end
