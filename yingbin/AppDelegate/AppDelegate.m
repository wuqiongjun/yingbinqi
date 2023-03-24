//
//  AppDelegate.m
//  yingbin
//
//  Created by slxk on 2021/4/12.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
//#import "Firebase.h"
#import "TIoTCoreAppEnvironment.h"
#import "TIoTCoreFoundation.h"

 #import "XGPushManage.h"


@interface AppDelegate ()<UITabBarControllerDelegate,CYLTabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    //信鸽推送配置
    
    [XGPushManage sharedXGPushManage].launchOptions = launchOptions;
    [[XGPushManage sharedXGPushManage] startPushService];
    
    /*
     * 此处仅供参考, 需自建服务接入物联网平台服务，以免 App Secret 泄露
     * 自建服务可参考此处 https://cloud.tencent.com/document/product/1081/45901#.E6.90.AD.E5.BB.BA.E5.90.8E.E5.8F.B0.E6.9C.8D.E5.8A.A1.2C-.E5.B0.86-app-api-.E8.B0.83.E7.94.A8.E7.94.B1.E8.AE.BE.E5.A4.87.E7.AB.AF.E5.8F.91.E8.B5.B7.E5.88.87.E6.8D.A2.E4.B8.BA.E7.94.B1.E8.87.AA.E5.BB.BA.E5.90.8E.E5.8F.B0.E6.9C.8D.E5.8A.A1.E5.8F.91.E8.B5.B7
     */
    
    TIoTCoreAppEnvironment *environment = [TIoTCoreAppEnvironment shareEnvironment];
    [environment setEnvironment];
    
//    公司账号下，后续的正式 key
//    APP Key    iLUHLtawEGSJTABZU
//    APP Secret    BwQbpaZzseDzHHKOfKcZ
    environment.appKey = @"iLUHLtawEGSJTABZU";
    environment.appSecret = @"BwQbpaZzseDzHHKOfKcZ";
    //测试的
//    environment.appKey = @"aMrchOrvSgxwpNlRW";
//    environment.appSecret = @"qEKutZsyFgguxPZgJyCh";

    /**
     * 此处若接入腾讯云物理网智能视频服务,则需要进行相关注册后，获取以下信息
     * 参考连接
     * https://cloud.tencent.com/product
     */
//    environment.cloudSecretId = @"";
//    environment.cloudSecretKey = @"";
//    environment.cloudProductId = @"";
    
    //firebase注册
//    [FIRApp configure];
    
    
    [[TIoTWebSocketManage shared] SRWebSocketOpen];
    
    
    [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].toolbarDoneBarButtonItemText = LOCSTR(@"完成");
    [IQKeyboardManager sharedManager].enableDebugging = NO;
    
#if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
    if(@available(iOS 13.0,*)){
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
#endif
    
    [self createRootViewVC];

    WEAK
    [[TLNotificationCenter rac_addObserverForName:LoginSuccessNotify object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        STRONG
        [self createRootViewVC];
    }];
    
    [self requestUpdate];
    
    return YES;
}
#pragma mark - 判断进登录或首页
- (void)createRootViewVC{
    
    if (![TIoTCoreUserManage shared].isValidToken && [self needLogin]) {
        self.window.rootViewController = [[BaseNavigationController alloc]initWithRootViewController:[LoginViewController new]];
    }else{
        self.tabBar = [[BaseTabBarController alloc] init];
        self.window.rootViewController = self.tabBar;
    }
}
//判断是否重新登录
- (BOOL)needLogin{
    if ([[TIoTCoreUserManage shared].expireAt integerValue] <= [[NSString getNowTimeString] integerValue]) {
        return YES;
    }
    return NO;
}

//app进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

//app进入前台
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:appEnterForeground object:nil];


}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    [[XGPushManage sharedXGPushManage] reportXGNotificationInfo:userInfo];
    WCLog(@"---------userInfo-静默消息---%@",[NSString jsonToObject:userInfo[@"custom"]]);
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
      NSLog(@"--------didReceiveRemoteNotification:APP在前台运行时，不做处理");
        //APP在前台，先暂不处理，后面跟产品商定
    }//当APP在后台运行时，当有通知栏消息时，点击它，就会执行下面的方法跳转到相应的页面
    else if([UIApplication sharedApplication].applicationState == UIApplicationStateInactive){
      // 取得 APNs 标准信息内容
      NSLog(@"-------didReceiveRemoteNotification:APP在后台运行时，当有通知栏消息时，点击它，就会执行下面的方法跳转到相应的页面");
    }
    completionHandler(UIBackgroundFetchResultNewData);
     
}

#pragma mark - 检查版本更新

- (void)requestUpdate{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    params[@"version"] = @([KAppVersion stringByReplacingOccurrencesOfString:@"." withString:@""].intValue);
    params[@"app_type"] = @"yingbin";
    
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"module"] = @"user";
    para[@"func"] = @"CheckVersion";
    para[@"params"] = params;
    //#endif
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//http://yjzx.8325.com/mapi 正式的
//http://sl.8325.com/mapi 测试的
    [manager POST:@"http://yjzx.8325.com/mapi" parameters:para headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary *dic = responseObject;
        
        NSString *newVersion = dic[@"name"];
        KUserCenter.versionDic = dic;
        NSComparisonResult comparingResults = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] compare:newVersion options:NSCaseInsensitiveSearch];
        
        if (comparingResults == NSOrderedAscending) {
            NSLog(@"升序");//（说明当前版本较低）
            NSLog(@"有版本更新");
            NSString *msg = [NSString stringWithFormat:@"%@%@，%@",NSLocalizedString(@"检测到新版本", nil),newVersion,NSLocalizedString(@"是否更新?", nil)];
            
            [TLUIUtility showAlertWithTitle:LOCSTR(@"版本更新提示") message:msg cancelButtonTitle:LOCSTR(@"暂不更新") otherButtonTitles:@[LOCSTR(@"去更新")] actionHandler:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://apps.apple.com/cn/app/id1576645856"] options:@{} completionHandler:^(BOOL success) {
                                        
                    }];
                }else{
                    if ([dic[@"is_force"] integerValue] == 1) {
                        [UIView animateWithDuration:1.5f animations:^{
                            [UIApplication sharedApplication].delegate.window.alpha = 0;
                            [UIApplication sharedApplication].delegate.window.window.frame = CGRectMake(0, 0, 0, 0);
                        } completion:^(BOOL finished) {
                            exit(0);
                        }];
                    }
                }
            }];

        }else if (comparingResults == NSOrderedSame){
            
            NSLog(@"相等");// (等同于当前版本)
        }else{
            NSLog(@"降序");////降序(说明当前版本较高)
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}
@end
