#import "VideoUpload.h"
#import <UIKit/UIKit.h>
#import "AppDelegate+VideoUpload.h"

@implementation VideoUpload
@synthesize actionCallbackId;


- (void)init:(CDVInvokedUrlCommand*)command {
     if (!_picker){
         _picker = [[GMImagePickerController alloc] init];
     }
     if (!_recordingView){
         CGRect testRect = CGRectMake(0, 0, 180, 300);
         _recordingView = [[RecordingView alloc] initWithFrame:testRect];
     }
    if (!_recordingUploader){
        _recordingUploader = [[RecordingUploader alloc] init];
    }
    if (!_uploader) {
        _uploader = [[VidUploader alloc] init];
    }
    NSString *CognitoPoolID = [command.arguments objectAtIndex:0];
    NSString *region = [command.arguments objectAtIndex:1];
    NSString *bucket = [command.arguments objectAtIndex:2];
    NSString *folder = [command.arguments objectAtIndex:3];
    NSNumber *inlayViewWidth = [command.arguments objectAtIndex:4];
    NSNumber *inlayViewHeight = [command.arguments objectAtIndex:5];
//    NSArray *arr = [selectionData componentsSeparatedByString:@","];
//    NSString *strSecond = [arr objectAtIndex:1];
    
    
    [_picker setupAWSS3:CognitoPoolID region:region bucket:bucket folder:folder];
    _picker.delegate = self;
    _picker.title = @"Albums";
    _picker.customDoneButtonTitle = @"Finished";
    _picker.customCancelButtonTitle = @"Cancel";
    _picker.customNavigationBarPrompt = @"";
    
    _picker.colsInPortrait = 3;
    _picker.colsInLandscape = 5;
    _picker.minimumInteritemSpacing = 2.0;
    
    float rcViewWidth = [inlayViewWidth floatValue];
    float rcViewHeight = [inlayViewHeight floatValue];
    CGSize recordingViewSize = CGSizeMake(rcViewWidth, rcViewHeight);
    CGPoint recordingViewPoint = CGPointMake(30, self.webView.frame.size.height - 300 - 40);
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGSize webviewSize = self.webView.frame.size;
    
    [_recordingView setupOriginalViewPort:recordingViewSize leftCorner:recordingViewPoint bottomOffset:40 startOrientation:UIInterfaceOrientationIsPortrait(interfaceOrientation) startingParentSize:webviewSize];
    [_recordingUploader setupRecodingAWSS3:CognitoPoolID region:region bucket:bucket folder:folder];
    _recordingUploader.delegate = self;
    _recordingView.delegate = self;
    
    [_uploader setupRecodingAWSS3:CognitoPoolID region:region bucket:bucket folder:folder];
    _uploader.delegate = self;

    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
    {
       _picker.modalPresentationStyle = UIModalPresentationPopover;
    }
     self.actionCallbackId = command.callbackId;
     [self.commandDelegate runInBackground:^{
         CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
         [self.commandDelegate sendPluginResult:result callbackId:self.actionCallbackId];
     }];
}

-(void)addWatcher:(CDVInvokedUrlCommand*)command
{
    self.watcherCallbackId = command.callbackId;
    self.capturing = NO;
    if (@available(iOS 11.0, *)) {
      [[NSNotificationCenter defaultCenter] addObserver:self
                    selector:@selector(handleScreenCaptureChange)
       name:UIScreenCapturedDidChangeNotification object:nil];
    }
}

-(void)getCurrentCapturing:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:self.capturing];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

-(void)handleScreenCaptureChange
{
    UIScreen *aScreen;
    BOOL isMainScreenMirrored = NO;
    BOOL screenCaptured = NO;
    NSArray *screens = [UIScreen screens];
    for (aScreen in screens)
    {
        if ([aScreen respondsToSelector:@selector(mirroredScreen)]
            && [aScreen mirroredScreen] == [UIScreen mainScreen])
        {
            // The main screen is being mirrored.
            isMainScreenMirrored = YES;
        }
    }

    if (@available(iOS 11.0, *)) {
        screenCaptured = [[UIScreen mainScreen] isCaptured];
    }
    
    NSString *sendResult;
    if (screenCaptured == YES) {
        sendResult =@"YES";
        self.capturing = YES;
    } else {
        sendResult =@"NO";
        self.capturing = NO;
    }
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:screenCaptured];

    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:self.watcherCallbackId];
}

- (BOOL)checkFreeSpace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }

    //If Free Space is smaller than 500MiB
//    NSNumber *compareFreeValue = [[NSNumber alloc] initWithUnsignedLongLong:totalFreeSpace];
    if (totalFreeSpace < 500 * 1024 * 1024) {
        return false;
    } else {
        return true;
    }
}

- (void)startUpload:(CDVInvokedUrlCommand*)command {
    NSString *pluginType = [command.arguments objectAtIndex:0];
//    AppDelegate* shared=[UIApplication sharedApplication].delegate;
//    if ([shared getUploadingStatus]) {
//
//        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
//        [result setValue:@"broken" forKey:@"result"];
//        NSLog(@"Another Upload Task is undergone");
//
//        [self.commandDelegate runInBackground:^{
//            [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result] callbackId:command.callbackId];
//        }];
//        return;
//    }
    self.actionCallbackId = command.callbackId;
    if ([pluginType isEqualToString:@"standard"]) {
        UIAlertController *alert;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat: @"How do you want to upload Video?"]
            message:nil
            preferredStyle:UIAlertControllerStyleAlert];
        } else {
            alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat: @"How do you want to upload Video?"]
            message:nil
            preferredStyle:UIAlertControllerStyleActionSheet];
        };
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"From Camera Roll"]
            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Ok action example
            
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusAuthorized) {
                 // Access has been granted.
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                    {
                        [self.viewController showViewController:self.picker sender:nil];
                    } else {
                        [self.viewController presentViewController:self.picker animated:YES completion:nil];
                    };
                });
            }

            else if (status == PHAuthorizationStatusDenied) {
                 // Access has been denied.
            }

            else if (status == PHAuthorizationStatusNotDetermined) {

                 // Access has not been determined.
                 [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {

                     if (status == PHAuthorizationStatusAuthorized) {
                         // Access has been granted.
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                             {
                                 [self.viewController showViewController:self.picker sender:nil];
                             } else {
                                 [self.viewController presentViewController:self.picker animated:YES completion:nil];
                             };
                         });
                     }

                     else {
                         // Access has been denied.
                     }
                 }];
            }
            
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
//        [alert addAction:otherAction];
        [alert addAction:cancelAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.viewController presentViewController:alert animated:YES completion:nil];
        });
    }
    
    if ([pluginType isEqualToString:@"record"]) {
        if ([self checkFreeSpace]) {
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(authStatus == AVAuthorizationStatusAuthorized)
            {
                NSLog(@"Camera access is granted!!!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.recordingView cameraViewSetup];
                        [self.webView addSubview:self.recordingView];
                    });
                
                    
            } else if (authStatus == AVAuthorizationStatusNotDetermined) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
                {
                    if(granted)
                    {
                        NSLog(@"Granted access to %@", AVMediaTypeVideo);
                        
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.recordingView cameraViewSetup];
                                [self.webView addSubview:self.recordingView];
                            });
                        
                    }
                    else
                    {
                        NSLog(@"Not granted access to %@", AVMediaTypeVideo);

                    }
                }];
            }
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat: @"Device Storage is almost Full!"]
                    message:@"You can free up space on this device by managing your storage."
                    preferredStyle:UIAlertControllerStyleAlert];
                
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.viewController presentViewController:alert animated:YES completion:nil];
            });
        }
    }
}

- (void)saveVideo:(CDVInvokedUrlCommand*)command {
    NSString *videoURL = [command.arguments objectAtIndex:0];
    self.actionCallbackId = command.callbackId;
    NSURL *url = [NSURL URLWithString:videoURL];
//    if([[NSFileManager defaultManager] fileExistsAtPath:videoURL]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        }
        completionHandler:^(BOOL success, NSError *error) {
            if (success)
            {
                NSLog(@"Video saved");
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }else{
                NSLog(@"%@",error.description);
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:false];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
//    }
}

//- (void)initLive:(CDVInvokedUrlCommand *)command {
//    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    switch (status) {
//        case AVAuthorizationStatusNotDetermined:{
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//                if (granted) {
//                }
//            }];
//            break;
//        }
//        case AVAuthorizationStatusAuthorized:{
//            break;
//        }
//        case AVAuthorizationStatusDenied:
//        case AVAuthorizationStatusRestricted:
//
//            break;
//        default:
//            break;
//    }
//    AVAuthorizationStatus auStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
//    switch (auStatus) {
//        case AVAuthorizationStatusNotDetermined:{
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
//            }];
//            break;
//        }
//        case AVAuthorizationStatusAuthorized:{
//            break;
//        }
//        case AVAuthorizationStatusDenied:
//        case AVAuthorizationStatusRestricted:
//            break;
//        default:
//            break;
//    }
//    CGRect testRect = CGRectMake(30, self.webView.frame.size.height - 300 - 60, 180, 300);
//    _livePreview = [[LivePreview alloc] initWithFrame:testRect];
//    _livePreview.delegate = self;
//
//    NSNumber *inlayViewWidth = [command.arguments objectAtIndex:0];
//    NSNumber *inlayViewHeight = [command.arguments objectAtIndex:1];
//    NSString *streamName = [command.arguments objectAtIndex:2];
//    [self.webView addSubview:_livePreview];
//    [_livePreview setupProducer];
//    [_livePreview initSessionWithStream:streamName];
//    self.actionCallbackId = command.callbackId;
//
//}

//- (void)startBroadcast:(CDVInvokedUrlCommand *)command {
//    NSString *rtmpURL = [command.arguments objectAtIndex:0];
////    [_livePreview setupPreview:rtmpURL];
//
//    self.actionCallbackId = command.callbackId;
//    [self.commandDelegate runInBackground:^{
//        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//        [self.commandDelegate sendPluginResult:result callbackId:self.actionCallbackId];
//    }];
//}

- (NSDictionary*) parseSelectionOptions: (NSString*)selectionData {
    NSData* jsonData = [selectionData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *responseObj = [NSJSONSerialization
                                 JSONObjectWithData:jsonData
                                 options:0
                                 error:&error];
    NSArray *responseArray = [responseObj objectForKey:@"selects"];
    for (NSDictionary *alternative in responseArray) {
        NSString *value = [alternative objectForKey:@"value"];
        NSLog(@"Test Input Data: %@", value);
    }
    return responseObj;
}

 #pragma mark - GMImagePickerControllerDelegate

 - (void)assetsPickerController:(GMImagePickerController *)picker didFinishUpload:(NSMutableDictionary *)result
 {
     [self.viewController dismissViewControllerAnimated:YES completion:nil];
     NSString *Status = [result objectForKey:@"Status"] ? [result objectForKey:@"Status"] : [[NSString alloc] init];
     
     
     if (![Status isEqualToString:@"Stored"]) {
         NSLog(@"Upload was failed.");
         [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"cancelled"] callbackId:self.actionCallbackId];
         return;
     }
     
     
     NSLog(@"Upload completed.");
     [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result] callbackId:self.actionCallbackId];
     
 }

- (void)assetsPickerController:(GMImagePickerController *)picker didFinishPick:(NSMutableDictionary *)result
{
    NSLog(@"You Picked the video &&&&&&&&");
    self.selectedVideo = [result objectForKey:@"url"];
    NSNumber *created = [result objectForKey:@"created"];
    self.selectedVideoCreated = [created intValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        [picker dismissViewControllerAnimated:NO completion:nil];
//        [self presentSelectionDialog];
    });
    [self.uploader setupRecordedURL:self.selectedVideo];
    [self.uploader uploadRecodingFile];
}

 //Optional implementation:
 -(void)assetsPickerControllerDidCancel:(GMImagePickerController *)picker
 {
     NSLog(@"User pressed cancel button");
     [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"cancelled"] callbackId:self.actionCallbackId];
 }

#pragma mark - RecordingViewDelegate

- (void)videoRecordingView:(RecordingView *)view didFinishRecording:(NSURL *)recordingResult;
{
    NSLog(@"Delegate Calling Result ==== %@", recordingResult);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat: @"Upload Now?"]
            message:@"Do you need to upload recorded video now?"
            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"No"]
            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            // Ok action example
            [self.recordingUploader setupRecordedURL:recordingResult];
            [self.uploader setupRecordedURL:recordingResult];
            self.selectedVideoCreated = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.recordingUploader.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                [self.viewController presentViewController:self.recordingUploader animated:YES completion:nil];
            });
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Yes"]
            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            
        }];
        [alert addAction:okAction];
        [alert addAction:otherAction];
    });
}

#pragma mark - RecordingUploaderDelegate

- (void)recordingUploadController:(RecordingUploader *)controller didFinishUploading:(NSMutableDictionary *)uploadingResult;
{
    NSLog(@"Recording Uploader Delegate Result ==== %@",uploadingResult);
    NSString *Status = [uploadingResult objectForKey:@"Status"] ? [uploadingResult objectForKey:@"Status"] : [[NSString alloc] init];
    
    
    if (![Status isEqualToString:@"Stored"]) {
        NSLog(@"Upload was failed.");
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"cancelled"] callbackId:self.actionCallbackId];
        return;
    }
    
    
    NSLog(@"Upload completed.");
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:uploadingResult] callbackId:self.actionCallbackId];
}

- (void)recordingUploadController:(RecordingUploader *)controller didUploadPercent:(double)percent;
{
    
    NSLog(@"Upload is done: %f.", percent);
    int progress = (int)percent;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    if (progress == 1) {
        [result setValue:@"success" forKey:@"result"];
    } else {
        [result setValue:@"uploading" forKey:@"result"];
    }
    [result setValue:@(progress) forKey:@"progress"];
    [result setValue:self.selectedCategory forKey:@"category"];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.actionCallbackId];
}

#pragma mark - VidUploaderDelegate

- (void)vidUploadController:(VidUploader *)uploader finished:(NSMutableDictionary *)uploadingResult
{
    NSString *Status = [uploadingResult objectForKey:@"Status"] ? [uploadingResult objectForKey:@"Status"] : [[NSString alloc] init];
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:uploadingResult];
    [result setValue:@"success" forKey:@"result"];
    [result setValue:self.selectedCategory forKey:@"category"];
    [result setValue:[NSNumber numberWithInt:self.selectedVideoCreated] forKey:@"videoCreated"];
    NSLog(@"Upload completed. %@", Status);
    
    if (![Status isEqualToString:@"Stored"]) {
        NSLog(@"Upload was failed.");
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"cancelled"] callbackId:self.actionCallbackId];
        return;
    }

    [self.commandDelegate runInBackground:^{
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result] callbackId:self.actionCallbackId];
    }];
}

- (void)vidUploadController:(VidUploader *)uploader didPercent:(double)percent
{
    NSLog(@"Upload is done: %f.", percent);
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setValue:@"uploading" forKey:@"result"];
    [result setValue:@(percent) forKey:@"progress"];
    [result setValue:self.selectedCategory forKey:@"category"];
    [result setValue:[NSNumber numberWithInt:self.selectedVideoCreated] forKey:@"videoCreated"];
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.actionCallbackId];
    }];
}

- (void)vidUploadController:(VidUploader *)uploader memeryLeak:(NSString *)memory
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Low Memory?"]
        message:@"Your phone does not have enough memory to read video file"
        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"OK"]
        style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];
    [alert addAction:okAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

//#pragma mark - LivePreviewDelegate
//- (void)livePreviewController:(LivePreview *)preview finished:(NSMutableDictionary *)result
//{
//    [self.commandDelegate runInBackground:^{
//        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"finished"] callbackId:self.actionCallbackId];
//    }];
//}

 @end


