//
//  LivePreview.h
//  MyApp
//
//  Created by DevMaster on 8/18/20.
//

#import <UIKit/UIKit.h>
#import <LFLiveKit/LFLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LivePreview : UIView <LFLiveSessionDelegate>

//@property (nonatomic, strong) UIButton *beautyButton;
//@property (nonatomic, strong) UIButton *cameraButton;
//@property (nonatomic, strong) UIButton *closeButton;
//@property (nonatomic, strong) UIButton *startLiveButton;
//@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) LFLiveDebug *debugInfo;
@property (nonatomic, strong) LFLiveSession *session;
//@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic) CGFloat currentScaleFactor;


@property(nonatomic, copy) UIButton* closeBtn;
@property(nonatomic, copy) UIButton* removeBtn;
@property(nonatomic, copy) UIButton* stopBtn;
@property(nonatomic, copy) UIButton* controlBtn;
@property(nonatomic, copy) UILabel* stateLabel;
@property(nonatomic, copy) NSString* rtmpURL;
@property(nonatomic, copy) UIView* preview;

@property Boolean fullscreenMode;
@property CGSize originSize;
@property CGPoint originalPoint;
@property CGFloat bottomOffset;
@property Boolean streaming;

- (void)setupOriginalViewPort:(CGSize)viewSize leftCorner:(CGPoint)viewPoint bottomOffset:(CGFloat)bottomPoint startOrientation:(Boolean)isPortrait startingParentSize:(CGSize)parentSize;
- (void)setupPreview:(NSString*)rtmpURL;

@end

NS_ASSUME_NONNULL_END
