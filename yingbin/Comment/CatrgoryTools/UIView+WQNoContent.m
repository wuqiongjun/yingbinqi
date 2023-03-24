//
//  UIView+WQNoContent.m
//  yingbin
//
//  Created by slxk on 2021/4/22.
//  Copyright © 2021 wq. All rights reserved.
//

#import "UIView+WQNoContent.h"
#import <objc/runtime.h>

static const void *empty_view_key = &empty_view_key;
static const void *button_click_key = &button_click_key;

@implementation UIView (WQNoContent)
- (void)setButtonClickComplete:(ButtonClickComplete)buttonClickComplete
{
    objc_setAssociatedObject(self, button_click_key, buttonClickComplete, OBJC_ASSOCIATION_COPY);
}

- (ButtonClickComplete)buttonClickComplete
{
    return objc_getAssociatedObject(self, button_click_key);
}

- (void)setEmptyView:(UIView *)emptyView
{
    objc_setAssociatedObject(self, empty_view_key, emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)emptyView
{
    return objc_getAssociatedObject(self, empty_view_key);
}

- (void)addEmptyDataWithTitle:(NSString *)title image:(UIImage *)image complete:(void (^)(void))complete
{
    if (self.emptyView) {
        return;
    }
    self.buttonClickComplete = complete;
    self.emptyView = [[UIView alloc] initWithFrame:self.bounds];
    self.emptyView.tag = 121212;
    [self addSubview:self.emptyView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 65)];
    imageView.centerX = self.centerX;
    imageView.centerY = self.centerY-80;
    imageView.image = image;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.bottom+10, self.width-20, 30)];
    label.text = title;
    label.textColor = KColor6C7078;
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;

    
    [self.emptyView addSubview:imageView];
    [self.emptyView addSubview:label];
}

- (void)addEmptyDataToTopWithTitle:(NSString *)title image:(UIImage *)image complete:(void (^)(void))complete
{
    if (self.emptyView) {
        return;
    }
    self.buttonClickComplete = complete;
    self.emptyView = [[UIView alloc] initWithFrame:self.bounds];
    self.emptyView.tag = 121212;
    [self addSubview:self.emptyView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 135, 140)];
    imageView.centerX = self.centerX;
    imageView.top = 80;
    imageView.image = image;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.bottom+10, self.width-20, 30)];
    label.text = title;
    label.textColor = KThemeColor;
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;

    
    [self.emptyView addSubview:imageView];
    [self.emptyView addSubview:label];
}

- (void)removeEmptyView
{
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
    }
}

- (void)onClick
{
    self.buttonClickComplete();
}


@end
