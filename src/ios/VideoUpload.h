#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

#import "GMImagePickerController.h"
#import "RecordingView.h"
#import "RecordingUploader.h"
#import "VidUploader.h"

@interface VideoUpload : CDVPlugin <GMImagePickerControllerDelegate, RecordingUploaderDelegate, RecordingViewDelegate, VidUploaderDelegate>

@property(nonatomic, copy) NSString* actionCallbackId;
@property(nonatomic, copy) NSString* watcherCallbackId;
@property(nonatomic, copy) NSDictionary* selectionObject;
@property(nonatomic, copy) NSDictionary* selectedCategory;
@property(nonatomic, copy) NSURL* selectedVideo;
@property(nonatomic) int selectedVideoCreated;

@property(nonatomic) BOOL capturing;

@property(nonatomic, copy) GMImagePickerController* picker;
@property(nonatomic, copy) RecordingView* recordingView;
@property(nonatomic, copy) RecordingUploader *recordingUploader;
@property(nonatomic, copy) VidUploader* uploader;

- (void)init:(CDVInvokedUrlCommand*)command;

- (void)startUpload:(CDVInvokedUrlCommand*)command;

- (void)saveVideo:(CDVInvokedUrlCommand*)command;

- (void)addWatcher:(CDVInvokedUrlCommand*)command;

- (void)getCurrentCapturing:(CDVInvokedUrlCommand*)command;

@end
