//
//  LivePreview.h
//  MyApp
//
//  Created by DevMaster on 8/18/20.
//

#import <UIKit/UIKit.h>
#import <LFLiveKit/LFLiveKit.h>
#import "AACEncoder.h"
#import "H264Encoder.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LivePreviewDelegate;

@interface LivePreview : UIView <LFLiveSessionDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

//@property (nonatomic, strong) UIButton *beautyButton;
//@property (nonatomic, strong) UIButton *cameraButton;
//@property (nonatomic, strong) UIButton *closeButton;
//@property (nonatomic, strong) UIButton *startLiveButton;
//@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) LFLiveDebug *debugInfo;
@property (nonatomic, strong) LFLiveSession *session;
//@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic) CGFloat currentScaleFactor;

@property (nonatomic) AVCaptureDevice* device;
@property (nonatomic) AVCaptureDevice* audioDevice;
@property (nonatomic, strong) AVCaptureVideoDataOutput    *videoOutput; //

@property (nonatomic) H264Encoder       *videoEncoder;
@property (nonatomic) AACEncoder        *audioEncoder;
@property (nonatomic, strong) AVCaptureSession  *avSession;


@property(nonatomic, copy) UIButton* closeBtn;
@property(nonatomic, copy) UIButton* removeBtn;
@property(nonatomic, copy) UIButton* stopBtn;
@property(nonatomic, copy) UIButton* controlBtn;
@property(nonatomic, copy) UILabel* stateLabel;
@property(nonatomic, copy) NSString* rtmpURL;
@property(nonatomic, copy) UIView* preview;
@property(nonatomic) CGRect originalRect;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) dispatch_queue_t encodeQueue;


@property Boolean fullscreenMode;
@property CGSize originSize;
@property CGPoint originalPoint;
@property CGFloat bottomOffset;
@property Boolean streaming;
@property (nonatomic, weak) id <LivePreviewDelegate> delegate;

- (void)setupOriginalViewPort:(CGSize)viewSize leftCorner:(CGPoint)viewPoint bottomOffset:(CGFloat)bottomPoint startOrientation:(Boolean)isPortrait startingParentSize:(CGSize)parentSize;
- (void)setupPreview:(NSString*)rtmpURL;
- (void)startSession;
- (void)stopSession;
- (void)startStreaming;
- (void)stopStreaming;
- (void) setupProducer;
- (void) initSessionWithStream: (NSString*) streamName;

@end

@protocol LivePreviewDelegate <NSObject>

- (void)livePreviewController:(LivePreview *)preview finished:(NSMutableDictionary *)result;

@end

NS_ASSUME_NONNULL_END
