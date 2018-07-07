//
//  JHActionSheetViewController.h
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

/**<
 eg:
 - (void)jhTaptoChangePhoto
 {
    NSLog(@"换头像");
 
    JHActionSheetViewController *actionSheetVC = [[JHActionSheetViewController alloc] initWithMenus:@[@"拍照",@"本地相册"]];
    __weak id weakSelf = self;
    [actionSheetVC setClickBlock:^(NSInteger index,NSString *title) {
        NSLog(@"index:%@,title:%@",@(index),title);
    }];

    [actionSheetVC showIn:self];
 }

 */

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

@property (nonatomic,  strong) JHActionSheetTitleConfig *allMenuTitleConfig;

@property (nonatomic,  strong) JHActionSheetTitleConfig *cancelTitleConfig;

/// menus types : 1. @[@"title1",@"title2"...] 2. @[@[@"image1",@"title1"],@[@"image2",@"title2"]...]
- (instancetype)initWithMenus:(NSArray *)menus;

/// menus types : 1. @[@"title1",@"title2"...] 2. @[@[@"image1",@"title1"],@[@"image2",@"title2"]...]
- (instancetype)initWithMenus:(NSArray *)menus
                menuRowHeight:(CGFloat)height1
              cancelRowHeight:(CGFloat)height2;

/// menus types : 1. @[@"title1",@"title2"...] 2. @[@[@"image1",@"title1"],@[@"image2",@"title2"]...]
- (instancetype)initWithMenus:(NSArray *)menus
                menuRowHeight:(CGFloat)height1
              cancelRowHeight:(CGFloat)height2
                 visiableRows:(NSInteger)row;

- (void)showIn:(UIViewController *)vc;

@end

