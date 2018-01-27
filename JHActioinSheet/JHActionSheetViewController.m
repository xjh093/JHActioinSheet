//
//  JHActionSheetViewController.m
//  JHKit
//
//  Created by HaoCold on 16/8/11.
//  Copyright © 2016年 HaoCold. All rights reserved.
//
//  MIT License
//
//  Copyright (c) 2017 xjh093
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "JHActionSheetViewController.h"

//#import "UIButton+WebCache.h"

@implementation JHActionSheetTitleConfig

- (instancetype)init{
    if (self = [super init]) {
        _enable = YES;
    }
    return self;
}
@end

@interface JHActionSheetViewController ()

@property (strong,  nonatomic) NSArray            *menus;      /**< 菜单, array */
@property (strong,  nonatomic) UIView             *menuView;
@property (assign,  nonatomic) CGFloat             vY;
@property (assign,  nonatomic) NSInteger           buttonIndex;
@property (copy,    nonatomic) NSString           *selectedTitle;
@property (assign,  nonatomic) CGFloat             height1;
@property (assign,  nonatomic) CGFloat             height2;

@property (nonatomic,  strong) NSMutableArray     *buttonsArray;
@property (nonatomic,    weak) UIViewController   *vc;

@end

@implementation JHActionSheetViewController

- (instancetype)init
{
    if (self = [super init]) {
        
#if 0
        UIViewController *vc = [self jhGetViewControllerOnScreen];
        
        // 1.开启上下文
        UIGraphicsBeginImageContextWithOptions(vc.view.frame.size, NO, 0.0);
        
        // 2.将控制器view的layer渲染到上下文
        [vc.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        // 3.取出图片
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // 4.结束上下文
        UIGraphicsEndImageContext();
        
        // 5.设置view的背景
        self.view.layer.contents = (id)newImage.CGImage;
#endif
    }
    return self;
}

- (UIViewController *)jhGetViewControllerOnScreen
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *twindow in windows) {
            if (twindow.windowLevel == UIWindowLevelNormal) {
                window = twindow;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    }
    
    return window.rootViewController;
}

- (instancetype)initWithMenus:(NSArray *)menus
{
    if (self = [super init]) {
        _height1 = 40;
        _height2 = 50;
        _menus = menus;
        _buttonsArray = @[].mutableCopy;
        [self jhSetupViews];
    }
    return self;
}

- (instancetype)initWithMenus:(NSArray *)menus
                menuRowHeight:(CGFloat)height1
              cancelRowHeight:(CGFloat)height2
{
    if (self = [super init]) {
        _menus = menus;
        _height1 = height1 < 30 ? 30 : height1;
        _height2 = height2 < 30 ? 30 : height2;
        _buttonsArray = @[].mutableCopy;
        [self jhSetupViews];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)jhSetupViews
{
    //灰色View
    UIView *grayView = [[UIView alloc] init];
    grayView.frame = self.view.bounds;
    grayView.backgroundColor = [UIColor blackColor];
    grayView.alpha = 0.2;
    [self.view addSubview:grayView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jhTapEvent)];
    [grayView addGestureRecognizer:tap];
    
    //菜单
    [self jhSetupMenuView];

}

- (void)jhTapEvent
{
    _buttonIndex = 0;
    _selectedTitle = @"";
    [self jhHide];
}

- (void)jhHide
{
    if ([_vc isKindOfClass:[UINavigationController class]]) {
        [_vc setValue:@(YES) forKeyPath:@"interactivePopGestureRecognizer.enabled"];
    }else{
        _vc.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    CGRect frame = _menuView.frame;
    frame.origin.y = CGRectGetHeight([UIScreen mainScreen].bounds);
    [UIView animateWithDuration:0.25 animations:^{
        _menuView.frame = frame;
    } completion:^(BOOL finished) {
        if (_clickBlock) {
            _clickBlock(_buttonIndex,_selectedTitle);
        }
        
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)jhSetupMenuView
{
    if (_menus.count == 0) {
        return;
    }
    
    NSInteger count = _menus.count;
    CGFloat   H1 = _height1; // menu row height
    CGFloat   H2 = _height2; // cancel row height
    
    CGFloat H  = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat W  = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat xH = H1*count + 10 + H2;
    CGFloat vH = xH > H*0.5 ? H*0.5: xH;
    CGRect  vframe = CGRectMake(0, H, W, vH);
    
    UIView *view = [[UIView alloc] init];
    view.frame = vframe;
    view.backgroundColor = [UIColor colorWithRed:236.0/255 green:236.0/255 blue:243.0/255 alpha:1];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, W, vH-10-H2);
    scrollView.contentSize = CGSizeMake(W, H1*count);
    scrollView.showsVerticalScrollIndicator = NO;
    [view addSubview:scrollView];
    
    [self.view addSubview:view];
    _menuView = view;
    _vY = H - vH;
    
    CGFloat bH = H1;
    for (int i = 0; i < _menus.count; i++) {
        
        NSString *image = nil;
        NSString *title = nil;
        
        if ([_menus[i] isKindOfClass:[NSArray class]]) {
            image = _menus[i][0];
            title = _menus[i][1];
        }else if ([_menus[i] isKindOfClass:[NSString class]]){
            title = _menus[i];
        }
        
        UIButton *button = [self jhSetupButton:title image:image];
        button.tag = i + 1;
        button.frame = CGRectMake(0, bH*i, W, bH);
        [scrollView addSubview:button];
        [_buttonsArray addObject:button];
        
        UIView *line = [self jhSetupLine];
        line.frame = CGRectMake(0, bH*(i+1)-1, W, 1);
        [scrollView addSubview:line];
    }
    
    // 取消按钮
    CGFloat tH = H2;
    CGFloat tY = CGRectGetMaxY(scrollView.frame) + 10;
    
    UIButton *button = [self jhSetupButton:@"取消" image:nil];
    button.tag = 0;
    button.frame = CGRectMake(0, tY, W, tH);
    [view addSubview:button];
    [_buttonsArray addObject:button];
}

- (UIButton *)jhSetupButton:(NSString *)title image:(NSString *)image
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:0];
    UIColor *color = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    [button setTitleColor:color forState:0];
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    if ([image hasPrefix:@"http"]) {
        //[button sd_setImageWithURL:[NSURL URLWithString:image] forState:0 placeholderImage:[UIImage imageNamed:@""]];
    }else{
        if ([image isKindOfClass:[NSString class]] && (image.length > 0)) {
            [button setImage:[UIImage imageNamed:image] forState:0];
        }
    }
    [button addTarget:self action:@selector(jhButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIView *)jhSetupLine
{
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1];
    return line;
}

- (void)jhButtonEvent:(UIButton *)button
{
    _buttonIndex = button.tag;
    if (_buttonIndex == 0) {
        _selectedTitle = @"";
    }else{
        _selectedTitle = _menus[_buttonIndex-1];
    }
    [self jhHide];
}

- (void)showIn:(UIViewController *)vc
{
    _vc = vc;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        [vc setValue:@(NO) forKeyPath:@"interactivePopGestureRecognizer.enabled"];
    }else{
        vc.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [vc addChildViewController:self];
    [vc.view addSubview:self.view];
    [self.view setFrame:vc.view.bounds];
    [self didMoveToParentViewController:vc];

    [self show];
}

- (void)show
{
    // NSLog(@"statusBar:%@",NSStringFromCGRect([[UIApplication sharedApplication] statusBarFrame]));
    CGFloat offsetY = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame])==44?34:0;
    CGRect frame = _menuView.frame;
    frame.origin.y = _vY - offsetY;
    
    [UIView animateWithDuration:0.25 animations:^{
        _menuView.frame = frame;
    }];
}

- (void)setTitleConfig:(NSArray<JHActionSheetTitleConfig *> *)titleConfig{
    _titleConfig = titleConfig;
    if (_titleConfig.count == 0) {
        return;
    }
    
    NSInteger count = MIN(titleConfig.count, _buttonsArray.count);
    for (NSInteger i = 0; i < count; ++i) {
        JHActionSheetTitleConfig *config = titleConfig[i];
        UIButton *button = _buttonsArray[i];
        
        [button setTitleColor:config.color forState:0];
        [button setTitleColor:config.highlightedColor forState:1];
        button.titleLabel.font = config.font;
        button.userInteractionEnabled = config.enable;
    }
}

@end
