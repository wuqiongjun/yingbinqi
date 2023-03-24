//
//  BaseTabBarController.m
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseTabBarController.h"
#import "DeviceViewController.h"
#import "ChangJingViewController.h"
#import "WoDeViewController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self addAllChildVcs];
    [self customizeTabBarAppearance];
    
}

- (void)customizeTabBarAppearance {
 
    [[UITabBar appearance] setTranslucent:NO];
    
    [self rootWindow].backgroundColor = [UIColor cyl_systemBackgroundColor];
    
    // set the text color for unselected state
    // 普通状态下的文字属性
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = KColor666666;
    
    // set the text color for selected state
    // 选中状态下的文字属性
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = KThemeColor;
    
    
    // set the text Attributes
    // 设置文字属性
    UITabBarItem *tabBar = [UITabBarItem appearance];
    [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [tabBar setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    
    
}

- (void)hideContentController:(UIViewController*) content{
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void)addAllChildVcs{
//    if ([TLUserDefaults boolForKey:USDEF_DEFAULT_MAP])
//    {
//        [TLUserDefaults setBool:NO forKey:USDEF_DEFAULT_MAP];
//        if (![Lauguage isEqualToString:@"zh"]) {
//            [TLUserDefaults setInteger:mapTypeGOOGLE forKey:KSELECT_MAP];
//        }
//    }

    if (self.viewControllers && self.viewControllers.count > 0) {
        for (UIViewController *vc in self.viewControllers) {
            [self hideContentController:vc];
        }
    }

    self.tabBarItemsAttributes = [self tabBarItemsAttributesForController];
    self.viewControllers = [self viewControllersForTabBar];
    self.selectedIndex = 0;
}

- (NSArray *)tabBarItemsAttributesForController {
    NSArray *tabBarItemsAttributes;
        NSDictionary *devTabBarItemsAttributes          = @{
                                                            CYLTabBarItemTitle : LOCSTR(@"首页"),
                                                            CYLTabBarItemImage :@"icon_dev_off",
                                                            CYLTabBarItemSelectedImage : @"icon_dev_on",
                                                            };
        
        NSDictionary *cahngjingTabBarItemsAttributes     = @{
                                                            CYLTabBarItemTitle : LOCSTR(@"场景"),
                                                            CYLTabBarItemImage : @"icon_changjing_off",
                                                            CYLTabBarItemSelectedImage : @"icon_changjing_on",
                                                            };

        NSDictionary *mineTabBarItemsAttributes         = @{
                                                            CYLTabBarItemTitle : LOCSTR(@"我的"),
                                                            CYLTabBarItemImage : @"icon_wode_off",
                                                            CYLTabBarItemSelectedImage : @"icon_wode_on",
                                                            };
        tabBarItemsAttributes = @[
            devTabBarItemsAttributes,
            cahngjingTabBarItemsAttributes,
            mineTabBarItemsAttributes,
        ];

    

    return tabBarItemsAttributes;
}
- (NSArray *)viewControllersForTabBar {
    
    DeviceViewController * devVC = [[DeviceViewController alloc] init];
//    DeviceViewModel *mapViewModel     = [DeviceViewModel new];
//    mapViewModel.delegate       = devVC;
//    devVC.viewModel     = mapViewModel;
    UIViewController *devNavigationController = [[BaseNavigationController alloc]
                                                 initWithRootViewController:devVC];
    [devVC cyl_setHideNavigationBarSeparator:YES];
    
    ChangJingViewController *changjingViewController = [[ChangJingViewController alloc] init];
    ChangJingViewModel *functionViewModel           = [ChangJingViewModel new];
//    functionViewModel.delegate             = changjingViewController;
    changjingViewController.viewModel           = functionViewModel;
    UIViewController *changjingNavigationController = [[BaseNavigationController alloc]
                                                      initWithRootViewController:changjingViewController];
    [changjingViewController cyl_setHideNavigationBarSeparator:YES];

    WoDeViewController *wodeViewController = [[WoDeViewController alloc] init];
    WoDeViewModel *alarmViewModel           = [WoDeViewModel new];
//    alarmViewModel.delegate               = wodeViewController;
    wodeViewController.viewModel             = alarmViewModel;
    UIViewController *wodeNavigationController = [[BaseNavigationController alloc]
                                                  initWithRootViewController:wodeViewController];
    [wodeViewController cyl_setHideNavigationBarSeparator:YES];


    NSArray *viewControllers;
    viewControllers = @[
        devNavigationController,
        changjingNavigationController,
        wodeNavigationController,
    ];

    return viewControllers;
}

@end
