//
//  RecordingView.m
//  MyApp
//
//  Created by DevMaster on 1/28/20.
//

#import "RecordingView.h"
@import Photos;


@implementation RecordingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
//    _fullscreenMode = false;
//    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
//    singleFingerTap.delegate = self;
//    [self addGestureRecognizer:singleFingerTap];
//    self.backgroundColor = [UIColor grayColor];
    
    CGRect closeBtnRect = CGRectMake(120, 10, 40, 40);
    _closeBtn = [[UIButton alloc] init];
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.frame = closeBtnRect;
    [_closeBtn setBackgroundImage:[UIImage imageNamed:@"SwitchIcon"] forState:UIControlStateNormal];
    _closeBtn.hidden = true;
    [_closeBtn addTarget:self action:@selector(changeInlayView) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect removeBtnRect = CGRectMake(10, 10, 40, 40);
    _removeBtn = [[UIButton alloc] init];
    _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _removeBtn.frame = removeBtnRect;
    [_removeBtn setBackgroundImage:[UIImage imageNamed:@"CloseIcon"] forState:UIControlStateNormal];
    _removeBtn.hidden = true;
    [_removeBtn addTarget:self action:@selector(removeRecordingView) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect controlBtnRect = CGRectMake(80, 160, 40, 40);
    _controlBtn = [[UIButton alloc] init];
    _controlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _controlBtn.frame = controlBtnRect;
    [_controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
    _controlBtn.hidden = true;
    [_controlBtn addTarget:self action:@selector(clickControlButton) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect labelRect = CGRectMake(70, 100, 60, 20);
    _timerShow = [[UILabel alloc] initWithFrame:labelRect];
    _timerShow.text = @"00:00";
    _timerShow.hidden = true;
    _timerShow.textColor = [UIColor whiteColor];
    _timerShow.backgroundColor = [UIColor redColor];
    _timerShow.layer.cornerRadius = 5;
    _timerShow.layer.masksToBounds = true;
    _timerShow.textAlignment = NSTextAlignmentCenter;
    
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = true;
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(changeOrientation)    name:UIDeviceOrientationDidChangeNotification  object:nil];
//    CGRect stopBtnRect = CGRectMake(80, 160, 20, 20);
//    _stopBtn = [[UIButton alloc] initWithFrame:stopBtnRect];
//    _controlBtn.backgroundColor = [UIColor redColor];
//    _stopBtn.hidden = true;
//    [_controlBtn addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    
//        _captureSession = [AVCaptureSession new];
//        _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
//
//        AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        if (!backCamera) {
//            NSLog(@"Unable to access back camera!");
//    //        return;
//        } else {
//            NSError *error;
//            _videoInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:backCamera
//                                                                                error:&error];
//            if (!error) {
//                //Step 9
//                if ([_captureSession canAddInput:_videoInputDevice]) {
//                    [_captureSession addInput:_videoInputDevice];
//                }
//            }
//            else {
//                NSLog(@"Error Unable to initialize back camera: %@", error.localizedDescription);
//            }
//
//            _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
//            if (_videoPreviewLayer) {
//
//                _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//            }
//            //ADD MOVIE FILE OUTPUT
//            NSLog(@"Adding movie file output");
//            _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
//            Float64 TotalSeconds = 1800;        //Total seconds
//            int32_t preferredTimeScale = 30;    //Frames per second
//            CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);    //<<SET MAX DURATION
//            _movieFileOutput.maxRecordedDuration = maxDuration;
//            _movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
//            //<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
//
//            if ([_captureSession canAddOutput:_movieFileOutput])
//                [_captureSession addOutput:_movieFileOutput];
//
//    //        [self CameraSetOutputProperties];
//
//            [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
//
//            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080])
//            {
//                [_captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
//            }
//            else if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720])
//            {
//                //Check size based configs are supported before setting them
//                [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
//            }
//            else if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480])
//            {
//                //Check size based configs are supported before setting them
//                [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
//            }
//
//            _videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
//
//            self.videoPreviewLayer.frame = self.layer.bounds;
//            [self.layer addSublayer:self.videoPreviewLayer];
//
//
//            //Step12
//            dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//            dispatch_async(globalQueue, ^{
//                self.recording = false;
//                [self.captureSession startRunning];
//
//                //Step 13
//                NSLog(@"session Started");
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    self.videoPreviewLayer.frame = self.bounds;
//                });
//            });
//
//        }
//
//    [self addSubview:_closeBtn];
//    [self addSubview:_controlBtn];
//    [self addSubview:_timerShow];
//    [self addSubview:_removeBtn];
    
    _captureSession = [AVCaptureSession new];
//    _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    [_captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080])
    {
        [_captureSession setSessionPreset:AVCaptureSessionPreset1920x1080];
    }
    else if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        //Check size based configs are supported before setting them
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    else if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480])
    {
        //Check size based configs are supported before setting them
        [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    if (_videoPreviewLayer) {
        _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    _videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    _videoPreviewLayer.frame = self.layer.bounds;
      
    return self;
}

- (void) cameraViewSetup
{
    
    
    self.backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    if (!self.backCamera) {
//        NSLog(@"Unable to access back camera!");
////        return;
//    } else {
        NSError *error;
        self.videoInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera
                                                                            error:&error];
        if (!error) {
            //Step 9
            if ([self.captureSession canAddInput:self.videoInputDevice]) {
                [self.captureSession addInput:self.videoInputDevice];
            }
            
            //ADD MOVIE FILE OUTPUT
            NSLog(@"Adding movie file output");
            _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
            Float64 TotalSeconds = 1800;        //Total seconds
            int32_t preferredTimeScale = 30;    //Frames per second
            CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);    //<<SET MAX DURATION
            _movieFileOutput.maxRecordedDuration = maxDuration;
            _movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
            //<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
            
            if ([_captureSession canAddOutput:_movieFileOutput]) {
                [_captureSession addOutput:_movieFileOutput];
            } else {
                if ([self.delegate respondsToSelector:@selector(videoRecordingView:didFinishAddingCaptureSession:)]) {
                    NSLog(@"Delegate Called = ****");
                    NSError *addError = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                    code:101 userInfo:nil];
                    [self.delegate videoRecordingView:self didFinishAddingCaptureSession:addError];
                }
            }
            
            //Step12
            dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(globalQueue, ^{
                self.recording = false;
                [self.captureSession startRunning];
                
                //Step 13
                NSLog(@"session Started");
                
            });
            
            
//            _videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            [self.layer addSublayer:self.videoPreviewLayer];
            [self addSubview:self.closeBtn];
            [self addSubview:self.controlBtn];
            [self addSubview:self.timerShow];
            [self addSubview:self.removeBtn];
        }
        else {
            NSLog(@"Error Unable to initialize back camera: %@", error.localizedDescription);
        }
        
//    }
    
    
}

- (void)cameraSetOutputProperties
{
    //SET THE CONNECTION PROPERTIES (output properties)
    AVCaptureConnection *CaptureConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //Set landscape (if required)
//    if ([CaptureConnection isVideoOrientationSupported])
//    {
//        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeRight;        //<<<<<SET VIDEO ORIENTATION IF LANDSCAPE
//        [CaptureConnection setVideoOrientation:orientation];
//    }
    
    //Set frame rate (if requried)
//    CMTimeShow(CaptureConnection.videoMinFrameDuration);
//    CMTimeShow(CaptureConnection.videoMaxFrameDuration);
//
//    if (CaptureConnection.supportsVideoMinFrameDuration)
//        CaptureConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
//    if (CaptureConnection.supportsVideoMaxFrameDuration)
//        CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
//
//    CMTimeShow(CaptureConnection.videoMinFrameDuration);
//    CMTimeShow(CaptureConnection.videoMaxFrameDuration);
    
}

- (void)setupParent:(UIView *)View
{
    self.parentView = View;
}

- (void)changeOrientation
{
    
    if (self.fullscreenMode == false)
    {
        [self handlerFrame];
    }
    else
    {
        CGRect newFrame = self.frame;
        newFrame.origin.x = 0;
        newFrame.origin.y = 0;
        newFrame.size.height = self.superview.frame.size.height;
        newFrame.size.width = self.superview.frame.size.width;
        self.frame = newFrame;
        self.closeBtn.center = CGPointMake(self.superview.frame.size.width - 30, 70);
        self.controlBtn.center = CGPointMake(self.superview.frame.size.width / 2, self.superview.frame.size.height - 50);
        self.timerShow.center = CGPointMake(self.superview.frame.size.width / 2, self.superview.frame.size.height - 90);
        [self checkDeviceOrientation];
    }
}

- (NSString*) checkDeviceOrientation
{
    NSString *returnValue = @"";
    if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft)
    {
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        returnValue = @"left";
        
    }
    else if (UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeRight)
    {
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        returnValue = @"right";
    }
    else if (UIDevice.currentDevice.orientation == UIDeviceOrientationPortrait)
    {
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        returnValue = @"portrait";
    }
    
    if (self.fullscreenMode == false)
    {
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = true;
        self.videoPreviewLayer.frame = self.layer.bounds;
    } else {
        self.layer.cornerRadius = 0;
        self.layer.masksToBounds = true;
        self.videoPreviewLayer.frame = self.layer.bounds;
    }

    return returnValue;
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
    } else {
        CGSize landscapeSize = CGSizeMake(self.originSize.height, self.originSize.width);
        newFrame.size = landscapeSize;
        newFrame.origin.x = self.originalPoint.x;
        newFrame.origin.y = self.superview.frame.size.height - landscapeSize.height - self.bottomOffset;
    }
    
    self.frame = newFrame;
    [self checkDeviceOrientation];
    
}

- (void)changeInlayView
{
    self.closeBtn.hidden = true;
    self.controlBtn.hidden = true;
    self.removeBtn.hidden = true;
    if (self.recording == true)
    {
        self.timerShow.hidden = false;
        self.timerShow.center = CGPointMake(self.originSize.width / 2, self.originSize.height - 20);
    }
    else
    {
        self.timerShow.hidden = true;
    }
    self.fullscreenMode = false;
    [self handlerFrame];
    
}

- (void)removeRecordingView
{
    /*Initialize properties*/
    self.fullscreenMode = false;
    self.closeBtn.hidden = true;
    self.controlBtn.hidden = true;
    self.removeBtn.hidden = true;
    self.stopBtn.hidden = true;
    self.timerShow.hidden = true;
    if (self.recording == true)
    {
        self.recording = false;
        self.timerShow.hidden = true;
        [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
        [self.movieFileOutput stopRecording];
    }
    [self.timer invalidate];
    [self handlerFrame];
    [self.captureSession removeInput:self.videoInputDevice];
    [self.captureSession removeOutput:self.movieFileOutput];

    [self removeFromSuperview];
}

- (void)clickControlButton
{
    NSLog(@"ClickControlButton");
    if (self.recording == false) {
//        self.stopBtn.hidden = false;
//        self.controlBtn.hidden = true;
        
        self.timeMin = 0;
        self.timeSec = 0;
        /* Commneted By Me*/
//        self.timerShow.hidden = false;
        
        NSString *timeShow = [NSString stringWithFormat:@"%02d:%02d", self.timeMin, self.timeSec];
        self.timerShow.text = timeShow;
        self.timerShow.hidden = false;
        [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"StopIcon"] forState:UIControlStateNormal];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        
        self.recording = true;
        NSString *outPutPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
        NSURL *outPutURL = [[NSURL alloc] initFileURLWithPath:outPutPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:outPutPath])
        {
            NSError *error;
            if ([fileManager removeItemAtPath:outPutPath error:&error] == NO)
            {
                //Error - handle if requried
            }
        }
        [self.movieFileOutput startRecordingToOutputFileURL:outPutURL recordingDelegate:self];
    } else {
        [self.timer invalidate];
        self.recording = false;
        self.timerShow.hidden = true;
        [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
        [self.movieFileOutput stopRecording];
    }
}

- (void) timerTick: (NSTimer *) timer {
    self.timeSec ++;
    if (self.timeSec == 60)
    {
        self.timeSec = 0;
        self.timeMin ++;
    }
    
    NSString *timeShow = [NSString stringWithFormat:@"%02d:%02d", self.timeMin, self.timeSec];
    self.timerShow.text = timeShow;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"View Touched");
    
    if (self.fullscreenMode == false)
    {
        CGRect newFrame = self.frame;
        newFrame.origin.x = 0;
        newFrame.origin.y = 0;
        newFrame.size.height = self.superview.frame.size.height;
        newFrame.size.width = self.superview.frame.size.width;
        self.frame = newFrame;
        self.closeBtn.hidden = false;
        self.closeBtn.center = CGPointMake(self.superview.frame.size.width - 30, 70);
        self.removeBtn.hidden = false;
        self.removeBtn.center = CGPointMake(30, 70);
        self.controlBtn.hidden = false;
        self.controlBtn.center = CGPointMake(self.superview.frame.size.width / 2, self.superview.frame.size.height - 50);
        self.timerShow.center = CGPointMake(self.superview.frame.size.width / 2, self.superview.frame.size.height - 90);

        
        if (self.recording == true)
        {
            self.timerShow.hidden = false;
        }
        else
        {
            self.timerShow.hidden = true;
        }
        
        self.fullscreenMode = true;
        
        [self checkDeviceOrientation];
        
    }
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
    [self checkDeviceOrientation];
    
    self.frame = newFrame;
    
}



//- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
//{
////  CGPoint location = [recognizer locationInView:[recognizer.view superview]];
//
//  //Do stuff here...
////    self.frame = self.parentView.frame
//    if (self.fullscreenMode == false)
//    {
//        CGRect newFrame = self.frame;
//        newFrame.size.height = self.parentView.frame.size.height;
//        newFrame.size.width = self.parentView.frame.size.width;
//        self.frame = newFrame;
//        self.fullscreenMode = true;
//    }
//
//}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    NSLog(@"didFinishRecordingToOutputFileAtURL - %@", error);
    //Format Recording State
    self.recording = false;
    [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
    self.timerShow.hidden = true;
    self.timer = [[NSTimer alloc] init];

    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            RecordedSuccessfully = [value boolValue];
        }
    }
    if (RecordedSuccessfully)
    {
        //----- RECORDED SUCESSFULLY -----
            NSLog(@"didFinishRecordingToOutputFileAtURL - success");
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
//        {
//            [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
//                                        completionBlock:^(NSURL *assetURL, NSError *error)
//            {
//                if (error)
//                {
//
//                }
//                NSLog(@"AssetURL - %@", outputFileURL);
//            }];
//        }

        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            __block PHObjectPlaceholder *placeholder;
            __block NSString *assetURL;

                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                    placeholder = [createAssetRequest placeholderForCreatedAsset];
                    assetURL = [placeholder localIdentifier];
                } completionHandler:^(BOOL success, NSError *error) {
                    
                    if (success)
                    {
                       NSLog(@"didFinishRecordingToOutputFileAtURL - success for ios9");
                        NSLog(@"Result URL = %@", assetURL);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self removeRecordingView];
                        });
                        
                        if ([self.delegate respondsToSelector:@selector(videoRecordingView:didFinishRecording:)]) {
                            NSLog(@"Delegate Called = ****");
                            [self.delegate videoRecordingView:self didFinishRecording:outputFileURL];
                        }
                    }
                    else
                    {
                        NSLog(@"%@", error);
                    }
                }];
            }
        }];
    }
}

//-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
//{
//    NSLog(@"OutputFileUrl %@", outputFileURL);
//    if(error){
//        NSLog(@"ERROR : %@", error);
//    }
////    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
////    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
//
//    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (error)
//            NSLog(@"%@", error);
//
//        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
//
////        if (backgroundRecordingID != UIBackgroundTaskInvalid)
////            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
//
//
//}

@end
