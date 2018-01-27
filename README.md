# JHActioinSheet
action sheet

![image](https://github.com/xjh093/JHActioinSheet/blob/master/image.png)


### .h
```
#import <UIKit/UIKit.h>

typedef void(^JHClickBlock)(NSInteger index,NSString *title);

@interface JHActionSheetTitleConfig : NSObject
@property (nonatomic,  strong) UIFont  *font;
@property (nonatomic,  strong) UIColor *color;
@property (nonatomic,  strong) UIColor *highlightedColor;
@property (nonatomic,  assign) BOOL     enable;
@end

@interface JHActionSheetViewController : UIViewController

@property (copy,    nonatomic) JHClickBlock clickBlock ; /**< 点击按钮回调 */

@property (nonatomic,  strong) NSArray <JHActionSheetTitleConfig *>*titleConfig;

/// menus types : 1. @[@"title1",@"title2"...] 2. @[@[@"image1",title1],@[@"image2",@"title2"]...]
- (instancetype)initWithMenus:(NSArray *)menus;

/// menus types : 1. @[@"title1",@"title2"...] 2. @[@[@"image1",title1],@[@"image2",@"title2"]...]
- (instancetype)initWithMenus:(NSArray *)menus
                menuRowHeight:(CGFloat)height1
              cancelRowHeight:(CGFloat)height2;

- (void)showIn:(UIViewController *)vc;

@end

```
