//
//  UITableView+WQCategory.h
//  yingbin
//
//  Created by slxk on 2021/6/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (WQCategory)


/**
 根据count显示s提示信息（无数据，网络不可用，网络请求失败）
 @param count 个数
 */
- (void)showDataCount:(NSInteger)count Title:(NSString *)title image:(UIImage *)image;


@end

NS_ASSUME_NONNULL_END
