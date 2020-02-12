//
//  RecordingView.h
//  MyApp
//
//  Created by DevMaster on 1/28/20.
//

#import <UIKit/UIKit.h>
@import AVFoundation;
@import CoreMedia;
@import AssetsLibrary;

NS_ASSUME_NONNULL_BEGIN

#define CAPTURE_FRAMES_PER_SECOND        20

@protocol RecordingViewDelegate;

@interface RecordingView : UIView <AVCaptureFileOutputRecordingDelegate>
    @property(nonatomic, copy) UIView* parentView;
    @property(nonatomic, copy) UIButton* closeBtn;
    @property(nonatomic, copy) UIButton* removeBtn;
    @property(nonatomic, copy) UIButton* stopBtn;
    @property(nonatomic, copy) UIButton* controlBtn;
    @property(nonatomic, copy) UILabel* timerShow;
    @property(nonatomic) NSTimer *timer;

    @property Boolean fullscreenMode;
    @property CGSize originSize;
    @property CGPoint originalPoint;
    @property CGFloat bottomOffset;
    @property Boolean recording;
    @property int timeMin;
    @property int timeSec;
    @property (nonatomic) AVCaptureSession *captureSession;
    @property (nonatomic) AVCaptureDevice *backCamera;
    @property (nonatomic) AVCapturePhotoOutput *stillImageOutput;
    @property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
    @property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
    @property (nonatomic) AVCaptureDeviceInput *videoInputDevice;

    @property (nonatomic, weak) id <RecordingViewDelegate> delegate;

    
//    - (void)handleSingleTap:(UITapGestureRecognizer*)recognizer;
    - (void)setupParent:(UIView *)View;
    - (void)setupOriginalViewPort:(CGSize)viewSize leftCorner:(CGPoint)viewPoint bottomOffset:(CGFloat)bottomPoint startOrientation:(Boolean)isPortrait startingParentSize:(CGSize)parentSize;
    - (void)changeInlayView;
    - (void)changeOrientation;
    - (void)handlerFrame;
    - (void)cameraSetOutputProperties;
    - (void)cameraViewSetup;
    - (NSString*)checkDeviceOrientation;
@end

@protocol RecordingViewDelegate <NSObject>

- (void)videoRecordingView:(RecordingView *)view didFinishRecording:(NSURL *)recordingResult;

@end

NS_ASSUME_NONNULL_END
