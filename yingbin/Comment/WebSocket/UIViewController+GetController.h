//
//  UIViewController+GetController.h
//  yingbin
//
//  Created by slxk on 2021/6/17.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (GetController)

//获取根控制器
+ (UIViewController *)getRootViewController;
//获取当前view所在控制器
+ (UIViewController *)getCurrentViewController;

@end

NS_ASSUME_NONNULL_END
