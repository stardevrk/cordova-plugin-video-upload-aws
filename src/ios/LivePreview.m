//
//  LivePreview.m
//  MyApp
//
//  Created by DevMaster on 8/18/20.
//

#import "LivePreview.h"
#import "AppDelegate+VideoUpload.h"


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
//        self.backgroundColor = [UIColor clearColor];
        [self requestAccessForVideo];
        [self requestAccessForAudio];
        
        if (!_preview) {
            _preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.originSize.width, self.originSize.height)];
        }
        if (!_closeBtn) {
            CGRect closeBtnRect = CGRectMake(120, 10, 40, 40);
           _closeBtn = [[UIButton alloc] init];
           _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
           _closeBtn.frame = closeBtnRect;
           [_closeBtn setBackgroundImage:[UIImage imageNamed:@"SwitchIcon"] forState:UIControlStateNormal];
           _closeBtn.hidden = true;
           [_closeBtn addTarget:self action:@selector(changeInlayView) forControlEvents:UIControlEventTouchUpInside];
        }
       
        if (!_removeBtn) {
            CGRect removeBtnRect = CGRectMake(10, 10, 40, 40);
            _removeBtn = [[UIButton alloc] init];
            _removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _removeBtn.frame = removeBtnRect;
            [_removeBtn setBackgroundImage:[UIImage imageNamed:@"CloseIcon"] forState:UIControlStateNormal];
            _removeBtn.hidden = true;
            [_removeBtn addTarget:self action:@selector(removeRecordingView) forControlEvents:UIControlEventTouchUpInside];
        }
        if (!_controlBtn) {
            CGRect controlBtnRect = CGRectMake(80, 160, 40, 40);
           _controlBtn = [[UIButton alloc] init];
           _controlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
           _controlBtn.frame = controlBtnRect;
           [_controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
           _controlBtn.hidden = true;
           _controlBtn.exclusiveTouch = true;
           [_controlBtn addTarget:self action:@selector(clickStartButton) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        if (!_stateLabel) {
            CGRect labelRect = CGRectMake(70, 100, 130, 20);
            _stateLabel = [[UILabel alloc] initWithFrame:labelRect];
            _stateLabel.text = @"00:00";
            _stateLabel.hidden = true;
            _stateLabel.textColor = [UIColor whiteColor];
            _stateLabel.backgroundColor = [UIColor redColor];
            _stateLabel.layer.cornerRadius = 5;
            _stateLabel.layer.masksToBounds = true;
            _stateLabel.textAlignment = NSTextAlignmentCenter;
            _stateLabel.text = @"Not Connected";
            _stateLabel.font = [UIFont boldSystemFontOfSize:14.f];
        }
        
        
        [self addZoomControl];
        self.currentScaleFactor = 1.0f;
        self.streaming = false;
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = true;
//        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(changeOrientation)    name:UIApplicationWillChangeStatusBarOrientationNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(changeOrientation)    name:UIDeviceOrientationDidChangeNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(checkStreaming)    name:UIApplicationDidEnterBackgroundNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(checkStreaming)    name:UIApplicationDidReceiveMemoryWarningNotification  object:nil];
        
        AppDelegate* shared=[UIApplication sharedApplication].delegate;
        [shared saveBlockRotation:TRUE];
    }
    return self;
}

- (void) setupPreview:(NSString*)rtmpURL
{
    _rtmpURL = [[NSString alloc] initWithString:rtmpURL];
//    self.preview.frame = self.bounds;
//    self.preview.hidden = false;
////    [self.preview setBackgroundColor:[UIColor redColor]];
//    [self addSubview:self.preview];
    [self addSubview:self.closeBtn];
    [self addSubview:self.controlBtn];
    [self addSubview:self.stateLabel];
    [self addSubview:self.removeBtn];
    
//    [self sendSubviewToBack:self.preview];
    [self.session setSaveLocalVideo:false];
    [self.session setMuted:true];
    [self.session setTorch:false];
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
                        [self.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            
            //dispatch_async(dispatch_get_main_queue(), ^{
            [self.session setRunning:YES];
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
        self.stateLabel.center = CGPointMake(self.superview.frame.size.width / 2, self.superview.frame.size.height - 90);
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
    self.stateLabel.center = CGPointMake(self.originSize.width / 2, self.originSize.height - 20);
    [self checkDeviceOrientation];
    
    self.frame = newFrame;
    
}

- (void)changeInlayView
{
    self.closeBtn.hidden = true;
    self.controlBtn.hidden = true;
    self.removeBtn.hidden = true;
    self.stateLabel.center = CGPointMake(self.originSize.width / 2, self.originSize.height - 20);
    self.fullscreenMode = false;
    [self handlerFrame];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"PreViewTouched");
    self.stateLabel.hidden = false;
    
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
        self.stateLabel.center = CGPointMake(self.superview.frame.size.width / 2, self.superview.frame.size.height - 90);

        self.fullscreenMode = true;
        [self checkDeviceOrientation];
        
    }
}

- (void)removeRecordingView
{
    /*Initialize properties*/
    self.fullscreenMode = false;
    self.closeBtn.hidden = true;
    self.controlBtn.hidden = true;
    self.removeBtn.hidden = true;
    self.stopBtn.hidden = true;
    if (self.streaming == true)
    {
        self.streaming = false;
        [self.controlBtn setBackgroundImage:[UIImage imageNamed:@"RecIcon"] forState:UIControlStateNormal];
        [self.session stopLive];
    }
    [self handlerFrame];
    [self removeFromSuperview];
    AppDelegate* shared=[UIApplication sharedApplication].delegate;
    [shared saveBlockRotation:FALSE];
}

- (void)checkStreaming
{
    if (self.streaming && self.session) {
        [self.session stopLive];
    }
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
        [self.session setZoomScale:self.currentScaleFactor];
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
        LFLiveVideoConfiguration* videoConfig = [LFLiveVideoConfiguration defaultConfiguration];
        [videoConfig setAutorotate:true];
       _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfig];

        _session.delegate = self;
        _session.preView = self;
        
        [_session setCaptureDevicePosition:AVCaptureDevicePositionBack];
        [_session setMuted:true];

    }
    return _session;
}


-(void)clickStartButton
{
    self.controlBtn.selected = !self.controlBtn.selected;
    if(self.controlBtn.selected){
        LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
//        stream.url = @"rtmp://3.89.78.208/live/g121790";
        stream.url = self.rtmpURL;
        [self.session startLive:stream];
    }else{
        [self.session stopLive];
    }
}

@end
