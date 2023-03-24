//
//  MacroTool.h
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#ifndef MacroTool_h
#define MacroTool_h

#pragma mark - # 常用控件高度
#define KScreenW [UIScreen mainScreen].bounds.size.width
#define KScreenH [UIScreen mainScreen].bounds.size.height


//是不是iphone手机、是不是ios大于等于11版本的
#define SLXK_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SLXK_IS_IOS_11  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.f)

//判断iPhoneX以后的所有系列
#define isIphone_X (SLXK_IS_IOS_11 && SLXK_IS_IPHONE && (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 375 && MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 812))
#define k_STATUSBAR_HEIGHT     (isIphone_X ? 44.0f : 20.0f)
#define k_Height_NavContentBar 44.0f
#define k_Height_StatusBar [[UIApplication sharedApplication] statusBarFrame].size.height
#define k_Height_NavBar (isIphone_X ? 88.0 : 64.0)
#define k_Height_TabBar (isIphone_X ? 83.0 : 49.0)
#define k_Height_SafetyArea (isIphone_X ? 34.0 : 0.0)
#define k_NAVIGATIONBAR_HEIGHT     k_Height_StatusBar + k_Height_NavContentBar
#define K1PX            ([[UIScreen mainScreen] scale] > 0.0 ? 1.0 / [[UIScreen mainScreen] scale] : 1.0)
#define KColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]


#define KThemeColor     KColor(1,208,201, 1)//1,208,201, //#01D0C9
#define KColor666666    KColor(102, 102, 102, 1)
#define KColor333333    KColor(51, 51, 51, 1)//标题:32px 加粗 #333333
#define KColor999999    KColor(153, 153, 153, 1)//标题:32px 加粗 #999999
#define KColorE5E5E5    KColor(229, 229, 229, 1)//标题:32px 加粗 #999999
#define KColorFF6630    KColor(255, 102, 48, 1)// #FF6630
#define KColor6C7078    KColor(108, 112, 120, 1)// #6C7078 //暂无数据颜色
//按钮不可点击灰色
#define kNoSelectedHexColor  KColor(214, 216, 220, 1) //@"#D6D8DC"

//在线 首页字颜色
#define KColor4F4F4  KColor(79, 79, 79, 1) //@"#4F4F4F"
//不在线
#define KColor939393  KColor(147, 147, 147, 1) //@"#939393"

//折线图
#define KColor8C8C8C    KColor(140, 140, 140, 1)// #8C8C8C 



//宏定义检测block是否可用
#define KBLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); };
#define KFont(font) [UIFont systemFontOfSize:(font)]
//加粗
#define KBFont(font) [UIFont boldSystemFontOfSize:(font)]
#define KPingFangFont(font)  [UIFont fontWithName:@"PingFangSC-Regular" size:(font)]


// 国际化
#define     LOCSTR(str)                 NSLocalizedString(str, nil)
// 广播中心
#define     KNotificationCenter        [NSNotificationCenter defaultCenter]
// 用户自定义数据
#define     KUserDefaults              [NSUserDefaults standardUserDefaults]
// 图片
#define     KImage(imageName)          [UIImage imageNamed:imageName]
// URL
#define     KURL(urlString)            [NSURL URLWithString:urlString]
//拼接字符串
#define Format(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]


//APP版本号
#define KAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
//APP名称
#define KAppDisplayName   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
//系统版本号
#define KSystemVersion [UIDevice currentDevice].systemVersion.doubleValue

#define Lauguage ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0] substringToIndex:2])

#define KUserCenter [UserManageCenter sharedUserManageCenter]

#define KNavigationController (BaseNavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController

#define WEAK  @weakify(self);
#define STRONG  @strongify(self);

//#define __ZB__TEST__SERVER___ //上线需要注释掉

#ifdef __ZB__TEST__SERVER___


#define KIPAddress @"115.28.220.135"
#define KPort @"9001"


#else


#define KIPAddress @"47.104.136.20"
#define KPort @"9001"

#endif






#endif /* MacroTool_h */
