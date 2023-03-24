//
//  UIView+WQNoContent.h
//  yingbin
//
//  Created by slxk on 2021/4/22.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ButtonClickComplete)(void);

@interface UIView (WQNoContent)

@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, copy) ButtonClickComplete buttonClickComplete;


- (void)addEmptyDataWithTitle:(NSString *)title image:(UIImage *)image complete:(void (^)(void))complete;

- (void)addEmptyDataToTopWithTitle:(NSString *)title image:(UIImage *)image complete:(void (^)(void))complete;

- (void)removeEmptyView;

@end

NS_ASSUME_NONNULL_END
