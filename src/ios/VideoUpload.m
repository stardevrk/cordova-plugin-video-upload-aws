#import "VideoUpload.h"
#import <UIKit/UIKit.h>

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
    NSString *CognitoPoolID = [command.arguments objectAtIndex:0];
    NSString *region = [command.arguments objectAtIndex:1];
    NSString *bucket = [command.arguments objectAtIndex:2];
    NSString *folder = [command.arguments objectAtIndex:3];
    [_picker setupAWSS3:CognitoPoolID region:region bucket:bucket folder:folder];
    _picker.delegate = self;
    _picker.title = @"Albums";
    _picker.customDoneButtonTitle = @"Finished";
    _picker.customCancelButtonTitle = @"Cancel";
    _picker.customNavigationBarPrompt = @"";
    
    _picker.colsInPortrait = 3;
    _picker.colsInLandscape = 5;
    _picker.minimumInteritemSpacing = 2.0;

    CGSize recordingViewSize = CGSizeMake(180, 300);
    CGPoint recordingViewPoint = CGPointMake(30, self.webView.frame.size.height - 300 - 40);
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGSize webviewSize = self.webView.frame.size;
    
    [_recordingView setupOriginalViewPort:recordingViewSize leftCorner:recordingViewPoint bottomOffset:40 startOrientation:UIInterfaceOrientationIsPortrait(interfaceOrientation) startingParentSize:webviewSize];
    [_recordingUploader setupRecodingAWSS3:CognitoPoolID region:region bucket:bucket folder:folder];
    _recordingUploader.delegate = self;
    _recordingView.delegate = self;

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

- (void)startUpload:(CDVInvokedUrlCommand*)command {
    self.actionCallbackId = command.callbackId;
           
    
        
        

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat: @"What do you want?"]
                message:nil
                preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Video Upload"]
                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                // Ok action example
                [self.commandDelegate runInBackground:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
                        {
                            [self.viewController showViewController:self.picker sender:nil];
                        } else {
                            [self.viewController presentViewController:self.picker animated:YES completion:nil];
                        };
                    });
                }];
            }];
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Record"]
                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                // Other action
                
//                    [self.webView addSubview:self.recordingView];
                
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
                
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:okAction];
            [alert addAction:otherAction];
            [alert addAction:cancelAction];
            [self.viewController presentViewController:alert animated:YES completion:nil];
          
       
        
  
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
    [self.recordingUploader setupRecordedURL:recordingResult];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recordingUploader.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self.viewController presentViewController:self.recordingUploader animated:YES completion:nil];
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

 @end
