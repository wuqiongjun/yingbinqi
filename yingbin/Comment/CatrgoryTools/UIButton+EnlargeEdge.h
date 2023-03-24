//
//  UIButton+EnlargeEdge.h
//  MECO
//
//  Created by 李钢 on 2018/11/20.
//  Copyright © 2018年 GiveU. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <objc/runtime.h>
typedef NS_ENUM(NSInteger, ZJButtonImageStyle){
    ZJButtonImageStyleTop = 0,  //图片在上，文字在下
    ZJButtonImageStyleLeft,     //图片在左，文字在右
    ZJButtonImageStyleBottom,   //图片在下，文字在上
    ZJButtonImageStyleRight     //图片在右，文字在左
};

@interface UIButton (EnlargeEdge)

@property (strong,nonatomic) UIActivityIndicatorView *loginIndicator;
/** 设置可点击范围到按钮边缘的距离 */
- (void)setEnlargeEdge:(CGFloat)size;

/** 设置可点击范围到按钮上、右、下、左的距离 */
- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;


/**
 设置button的imageView和titleLabel的布局样式及它们的间距
 
 @param style imageView和titleLabel的布局样式
 @param space imageView和titleLabel的间距
 */
- (void)layoutButtonWithImageStyle:(ZJButtonImageStyle)style
                 imageTitleToSpace:(CGFloat)space;


/**
 开始加载动画
 */
- (void)startLoadingAnimation;

/**
 结束加载动画
 */
- (void)stopLoadingAnimation;

+ (instancetype)buttonWithImage:(NSString *)image title:(NSString *)title target:(id)target action:(SEL)action;
@end

