//
//  BaseNavigationController.m
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()<UINavigationControllerDelegate>

KSTRONG NSArray *classNameArray;

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak BaseNavigationController *weakSelf = self;
    self.delegate = weakSelf;
    self.interactivePopGestureRecognizer.delegate = (id)self;
    [self.interactivePopGestureRecognizer setEnabled:YES];
    [self setUpNavigationBarAppearance];
}
- (NSArray *)classNameArray{
    if (!_classNameArray) {
        _classNameArray = @[
                            @"LoginViewController",
                            @"DeviceViewController",
                            @"ChangJingViewController",
                            @"WoDeViewController"
                            ];
    }
    return _classNameArray;
}
//  防止导航控制器只有一个rootViewcontroller时触发手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // 过滤执行过渡动画时的手势处理
    if ([[self valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    return self.childViewControllers.count == 1 ? NO : YES;
}

/**
 *  设置navigationBar样式
 */
- (void)setUpNavigationBarAppearance {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    NSDictionary *textAttributes = nil;
    UIColor *labelColor =   [UIColor blackColor];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        textAttributes = @{
                           NSFontAttributeName : KBFont(17),
                           NSForegroundColorAttributeName : labelColor,
                           };
    }
    navigationBarAppearance.barStyle    = UIBarMetricsDefault;
    navigationBarAppearance.translucent = NO; //導航欄不透明
    navigationBarAppearance.shadowImage = [UIImage new];
    [navigationBarAppearance setBarTintColor:[UIColor groupTableViewBackgroundColor]];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];

}
#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = NO;
    for (NSString *className in self.classNameArray) {
        if ([viewController isKindOfClass:[NSClassFromString(className) class]]){
            isShowHomePage = YES;
        }
    }
    [viewController.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}



@end
