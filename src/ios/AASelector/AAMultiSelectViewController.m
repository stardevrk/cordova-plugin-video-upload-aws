
#import "AAMultiSelectViewController.h"
#import "AAPopupView.h"
#import "Masonry.h"
#import "AAMultiSelectTableViewCell.h"
#import "AAMultiSelectModel.h"

#define AA_SAFE_BLOCK_CALL(block, ...) block ? block(__VA_ARGS__) : nil
#define UIColorFromHexWithAlpha(hexValue,a) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:a]
#define UIColorFromHex(hexValue) UIColorFromHexWithAlpha(hexValue,1.0)

#define FONT(size) [UIFont systemFontOfSize:size]
#define BOLD_FONT(size) [UIFont boldSystemFontOfSize:size]

static NSString * const tableViewCellIdentifierName    = @"multiTableViewCell";

static CGFloat const viewCornerRadius                  = 5.f;
static CGFloat const tableViewRowHeight                = 50;
static NSInteger const titleLabelMarginTop             = 15;
static CGFloat const separatorHeight                   = 0.5f;
static NSInteger const topSeparatorMarginTop           = 10;
static NSInteger const bottomSeparatorMarginTop        = 10;

static NSInteger const buttonContainerViewMarginTop    = 25;
static NSInteger const buttonContainerViewMarginLeft   = 20;
static NSInteger const buttonContainerViewMarginRight  = 20;
static NSInteger const buttonContainerViewMarginBottom = 20;
static CGFloat const buttonCornerRadius                = 5.f;
static CGFloat const buttonTitleFontSize               = 16.0;
static CGFloat const buttonInsetsTop                   = 10.0;
static CGFloat const buttonInsetsLeft                  = 30.0;
static CGFloat const buttonInsetsBottom                = 10.0;
static CGFloat const buttonInsetsRight                 = 30.0;
static CGFloat const buttonMarginHorizontal            = 5.f;
static NSInteger const AADefaultConfirmButtonBackgroundColor     = 0X800080;
static NSInteger const AADefaultCancelButtonBackgroundColor     = 0XAAAAAA;
static NSInteger const separatorBackgroundColor        = 0XDCDCDC;

@interface AAMultiSelectViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton    *confirmButton;
@property (nonatomic, strong) UIButton    *cancelButton;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UIView      *topSeparator;
@property (nonatomic, strong) UIView      *bottomSeparator;
@property (nonatomic, strong) AAPopupView *popupView;

@end

@implementation AAMultiSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark - Set up

- (void)setupUI {
    [self setupView];
    [self setupTitleLabel];
    [self setupTableView];
    [self setupButtons];
    [self setupPopup];
}

- (void)setupView {
    self.view.layer.cornerRadius = viewCornerRadius;
    self.view.clipsToBounds      = YES;
    self.view.backgroundColor    = [UIColor whiteColor];
}

- (void)setupTitleLabel {
    UILabel *titleLabel               = [UILabel new];
    titleLabel.textColor              = self.titleTextColor ? : [UIColor blackColor];
    titleLabel.font                   = self.titleFont ? : [UIFont systemFontOfSize:15];
    titleLabel.text                   = self.titleText;
    titleLabel.textAlignment          = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(titleLabelMarginTop);
    }];
    self.titleLabel                   = titleLabel;
    self.topSeparator                 = [UIView new];
    self.topSeparator.backgroundColor = UIColorFromHex(separatorBackgroundColor);
    [self.view addSubview:self.topSeparator];
    [self.topSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(topSeparatorMarginTop);
        make.height.mas_equalTo(separatorHeight);
    }];
}

- (void)setupButtons {
    UIView *buttonContainerView           = [[UIView alloc] init];
    buttonContainerView.backgroundColor   = [UIColor clearColor];
    [self.view addSubview:buttonContainerView];
    [buttonContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(buttonContainerViewMarginLeft);
        make.right.equalTo(self.view).offset(-buttonContainerViewMarginRight);
        make.bottom.equalTo(self.view).offset(-buttonContainerViewMarginBottom);
        make.top.equalTo(self.tableView.mas_bottom).offset(buttonContainerViewMarginTop);
    }];
    
    self.confirmButton                    = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton.backgroundColor    = self.confirmButtonBackgroudColor ? : UIColorFromHex(AADefaultConfirmButtonBackgroundColor);
    self.confirmButton.layer.cornerRadius = buttonCornerRadius;
    self.confirmButton.titleLabel.font    = BOLD_FONT(buttonTitleFontSize);
    self.confirmButton.contentEdgeInsets  = UIEdgeInsetsMake(buttonInsetsTop, buttonInsetsLeft,
                                                             buttonInsetsBottom, buttonInsetsRight);
    [self.confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton setTitle:@"confirm" forState:UIControlStateNormal];
    [buttonContainerView addSubview:self.confirmButton];
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(buttonContainerView);
        make.top.equalTo(buttonContainerView);
        make.bottom.equalTo(buttonContainerView);
    }];
    
    self.cancelButton                     = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.backgroundColor     = self.cancelButtonBackgroudColor ? : UIColorFromHex(AADefaultCancelButtonBackgroundColor);
    self.cancelButton.layer.cornerRadius  = buttonCornerRadius;
    self.cancelButton.titleLabel.font     = BOLD_FONT(buttonTitleFontSize);
    self.cancelButton.contentEdgeInsets   = UIEdgeInsetsMake(buttonInsetsTop, buttonInsetsLeft,
                                                             buttonInsetsBottom, buttonInsetsRight);
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:@"cancel" forState:UIControlStateNormal];
    [buttonContainerView addSubview:self.cancelButton];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(buttonContainerView);
        make.bottom.equalTo(buttonContainerView);
        make.top.equalTo(buttonContainerView);
        make.width.equalTo(self.confirmButton);
        make.left.greaterThanOrEqualTo(self.confirmButton.mas_right).offset(buttonMarginHorizontal);
    }];
}

- (void)setupTableView {
    UITableView *tableView       = [UITableView new];
    tableView.rowHeight          = tableViewRowHeight;
    tableView.tableFooterView    = [UIView new];
    [tableView registerClass:[AAMultiSelectTableViewCell class] forCellReuseIdentifier:tableViewCellIdentifierName];
    tableView.dataSource         = self;
    tableView.delegate           = self;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.topSeparator.mas_bottom);
    }];
    self.tableView               = tableView;
    
    self.bottomSeparator = [UIView new];
    self.bottomSeparator.backgroundColor = UIColorFromHex(separatorBackgroundColor);
    [self.view addSubview:self.bottomSeparator];
    [self.bottomSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.tableView.mas_bottom).offset(bottomSeparatorMarginTop);
        make.height.mas_equalTo(separatorHeight);
    }];
}

- (void)setupPopup {
    self.popupShowType    = AAPopupViewShowTypeFadeIn;
    self.popupDismissType = AAPopupViewDismissTypeFadeOut;
    self.popupMaskType    = AAPopupViewMaskTypeDimmed;
}

#pragma mark - UITableView DataSource && Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AAMultiSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifierName
                                                                        forIndexPath:indexPath];
    cell.selectionStyle             = UITableViewCellSelectionStyleNone;
    AAMultiSelectModel *selectModel = self.dataArray[indexPath.row];
    cell.titleTextColor             = self.itemTitleColor;
    cell.titleFont                  = self.itemTitleFont;
    cell.title                      = selectModel.title;
    cell.selectedImageHidden        = !selectModel.isSelected;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < self.dataArray.count; i++) {
        AAMultiSelectModel *model = self.dataArray[i];
        model.isSelected = FALSE;
    }
    AAMultiSelectModel *selectModel = self.dataArray[indexPath.row];
    selectModel.isSelected          = TRUE;
//    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView reloadData];
}

#pragma mark - Events

- (void)confirmButtonTapped {
    [self.popupView dismiss:YES];
    NSMutableArray *selectedArray = [NSMutableArray array];
    NSString *result = [[NSString alloc] init];
    for (AAMultiSelectModel *selectedModel in self.dataArray) {
        if (selectedModel.isSelected == TRUE)
            result = selectedModel.title;
    }
    
    if ([self.delegate respondsToSelector:@selector(selectionController:didFinishSelect:)]) {
        [self.delegate selectionController:self didFinishSelect:result];
    }
}

- (void)cancelButtonTapped {
    [self.popupView dismiss:YES];
}

#pragma mark - Helper

- (void)show {
    self.popupView =
    [AAPopupView popupWithContentView:self.view
                             showType:self.popupShowType
                          dismissType:self.popupDismissType
                             maskType:self.popupMaskType
             dismissOnBackgroundTouch:self.dismissOnBackgroundTouch];
    [self.popupView show];
}

#pragma mark - Setter
- (void)setTitleFont:(UIFont *)titleFont {
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
        self.titleLabel.font = titleFont;
    }
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    if (_titleTextColor != titleTextColor) {
        _titleTextColor = titleTextColor;
        self.titleLabel.textColor = titleTextColor;
    }
}

- (void)setConfirmButtonBackgroudColor:(UIColor *)confirmButtonBackgroudColor {
    if (_confirmButtonBackgroudColor != confirmButtonBackgroudColor) {
        _confirmButtonBackgroudColor       = confirmButtonBackgroudColor;
        self.confirmButton.backgroundColor = confirmButtonBackgroudColor;
    }
}

- (void)setConfirmButtonTitleColor:(UIColor *)confirmButtonTitleColor {
    if (_confirmButtonTitleColor != confirmButtonTitleColor) {
        _confirmButtonTitleColor = confirmButtonTitleColor;
        [self.confirmButton setTitleColor:confirmButtonTitleColor
                                 forState:UIControlStateNormal];
    }
}

- (void)setConfirmButtonTitleFont:(UIFont *)confirmButtonTitleFont {
    if (_confirmButtonTitleFont != confirmButtonTitleFont) {
        _confirmButtonTitleFont = confirmButtonTitleFont;
        self.confirmButton.titleLabel.font = confirmButtonTitleFont;
    }
}

- (void)setCancelButtonBackgroudColor:(UIColor *)cancelButtonBackgroudColor {
    if (_cancelButtonBackgroudColor != cancelButtonBackgroudColor) {
        _cancelButtonBackgroudColor        = cancelButtonBackgroudColor;
        self.cancelButton.backgroundColor  = cancelButtonBackgroudColor;
    }
}

- (void)setCancelButtonTitleColor:(UIColor *)cancelButtonTitleColor {
    if (_cancelButtonTitleColor != cancelButtonTitleColor) {
        _cancelButtonTitleColor = cancelButtonTitleColor;
        [self.cancelButton setTitleColor:cancelButtonTitleColor
                                forState:UIControlStateNormal];
    }
}

- (void)setCancelButtonTitleFont:(UIFont *)cancelButtonTitleFont {
    if (_cancelButtonTitleFont != cancelButtonTitleFont) {
        _cancelButtonTitleFont = cancelButtonTitleFont;
        self.cancelButton.titleLabel.font = cancelButtonTitleFont;
    }
}


@end
