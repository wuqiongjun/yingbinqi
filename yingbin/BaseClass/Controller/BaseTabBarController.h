//
//  BaseTabBarController.h
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import <CYLTabBarController/CYLTabBarController.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseTabBarController : CYLTabBarController<UITabBarControllerDelegate>

- (void)addAllChildVcs;

@end

NS_ASSUME_NONNULL_END
