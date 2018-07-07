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

#define kJH_USE_SD 0
#if kJH_USE_SD
#import "UIButton+WebCache.h"
#endif

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
@property (nonatomic,  assign) NSInteger           visiableRows;

@end

@implementation JHActionSheetViewController


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

- (instancetype)initWithMenus:(NSArray *)menus
                menuRowHeight:(CGFloat)height1
              cancelRowHeight:(CGFloat)height2
                 visiableRows:(NSInteger)row
{
    if (self = [super init]) {
        _menus = menus;
        _height1 = height1 < 30 ? 30 : height1;
        _height2 = height2 < 30 ? 30 : height2;
        _visiableRows = row;
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
    CGFloat vH = xH > H*0.5 ? H*0.5: xH; // whole menu view Height.
    
    // normal height, half [UIScreen mainScreen].bounds.size.height
    CGRect  vframe = CGRectMake(0, H, W, vH);
    
    //
    CGFloat scrollViewH = vH-10-H2;
    if (_visiableRows > 0) {
        NSInteger t_count = _visiableRows;
        if (_visiableRows > count) { // visiable rows more than menu count
            t_count = count;
        }
        
        scrollViewH = t_count * H1;
        vH = scrollViewH + 10 + H2;
        if (vH >= H*0.5) {
            t_count = H*0.5/H1;
            scrollViewH = t_count * H1;
            vH = scrollViewH + 10 + H2;
        }
        vframe = CGRectMake(0, H, W, vH);
    }
    
    
    
    // menuView 
    UIView *view = [[UIView alloc] init];
    view.frame = vframe;
    view.backgroundColor = [UIColor colorWithRed:236.0/255 green:236.0/255 blue:243.0/255 alpha:1];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, W, scrollViewH);
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
#if kJH_USE_SD
        [button sd_setImageWithURL:[NSURL URLWithString:image] forState:0 placeholderImage:[UIImage imageNamed:@""]];
#endif
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
        
        if (config.color) {
            [button setTitleColor:config.color forState:0];
        }
        if (config.highlightedColor) {
            [button setTitleColor:config.highlightedColor forState:1];
        }
        if (config.font) {
            button.titleLabel.font = config.font;
        }
        button.userInteractionEnabled = config.enable;
    }
}

- (void)setAllMenuTitleConfig:(JHActionSheetTitleConfig *)allMenuTitleConfig{
    _allMenuTitleConfig = allMenuTitleConfig;
    
    [self jhTitleconfigFrom:0 to:_buttonsArray.count-1 config:allMenuTitleConfig];
}

- (void)setCancelTitleConfig:(JHActionSheetTitleConfig *)cancelTitleConfig{
    _cancelTitleConfig = cancelTitleConfig;
    
    [self jhTitleconfigFrom:_buttonsArray.count-1 to:_buttonsArray.count config:cancelTitleConfig];
}

- (void)jhTitleconfigFrom:(NSInteger)start to:(NSInteger)end config:(JHActionSheetTitleConfig *)config{
    for (NSInteger i = start; i < end; ++i) {
        UIButton *button = _buttonsArray[i];
        
        if (config.color) {
            [button setTitleColor:config.color forState:0];
        }
        if (config.highlightedColor) {
            [button setTitleColor:config.highlightedColor forState:1];
        }
        if (config.font) {
            button.titleLabel.font = config.font;
        }
        button.userInteractionEnabled = config.enable;
    }
}


@end
