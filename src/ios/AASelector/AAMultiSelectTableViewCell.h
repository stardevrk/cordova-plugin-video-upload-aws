#import <UIKit/UIKit.h>

@interface AAMultiSelectTableViewCell : UITableViewCell

@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, strong) UIColor  *titleTextColor;
@property (nonatomic, strong) UIFont   *titleFont;
@property (nonatomic, strong) UIImage  *selectedImage;
@property (nonatomic, assign) BOOL     *selectedImageHidden;

@end
