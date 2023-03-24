//
//  LoginViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgotPwdViewController.h"
#import <TTTAttributedLabel.h>
#import "DeviceViewController.h"
#import "WebViewController.h"

 #import "XGPushManage.h"

 
@interface LoginViewController ()<TTTAttributedLabelDelegate>

KSTRONG UIButton *versionButton;

KSTRONG UIImageView *locationView;
KSTRONG UITextField *userNameField;
KSTRONG UITextField *passField;
KSTRONG UIButton *passHideButton;

KSTRONG UIButton *changePwdButton;
KSTRONG TTTAttributedLabel *registerButton;
KSTRONG UIButton *loginButton;

KSTRONG TTTAttributedLabel *privacyLabel;
KSTRONG UIButton *saveButton;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self createSubviews];
}
- (void)createSubviews{
    WEAK
    self.versionButton = self.view
    .addButton(0)
    .titleFont(KPingFangFont(14))
//    .hidden(YES)
    .title([NSString stringWithFormat:@"V%@",KAppVersion])
    .titleColor(UIColor.darkTextColor)
    .contentHorizontalAlignment(UIControlContentHorizontalAlignmentRight)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
//        STRONG
    })
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(k_Height_StatusBar);
        make.right.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    })
    .view;
    
    self.locationView = self.view
    .addImageView(1)
    .cornerRadius(10)
    .image(KImage(@"icon_login"))
    .masonry(^(MASConstraintMaker *make){
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    })
    .view;
    
    self.userNameField = self.view
    .addTextField(7)
    .font(KPingFangFont(15))
    .placeholder(LOCSTR(@"请输入手机号"))
    .text([[NSUserDefaults standardUserDefaults] objectForKey:USERLOGIN_USERNAME])
    .backgroundColor(UIColor.clearColor)
    .textColor(UIColor.blackColor)
    .keyboardType(UIKeyboardTypeNumberPad)
    .clearButtonMode(UITextFieldViewModeWhileEditing)
    .textAlignment(NSTextAlignmentLeft)
    .masonry(^(MASConstraintMaker *make){
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(self.locationView.mas_bottom).mas_offset(65);
        make.height.mas_equalTo(50);
    })
    .view;
    self.userNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIView *userNameLine = self.view
    .addView(5)
    .backgroundColor(KColorE5E5E5)
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.userNameField.mas_bottom);
        make.left.right.mas_equalTo(self.userNameField);
        make.height.mas_equalTo(1);
    })
    .view;
    
    //创建左侧视图
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_wode"]];
    UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 200)];//宽度根据需求进行设置，高度必须大于 textField 的高度
    lv.backgroundColor = [UIColor clearColor];
    iv.center = lv.center;
    [lv addSubview:iv];
    self.userNameField.leftViewMode = UITextFieldViewModeAlways;
    self.userNameField.leftView = lv;
    
    self.passField = self.view
    .addTextField(7)
    .font(KPingFangFont(15))
    .placeholder(LOCSTR(@"请输入密码"))
    .backgroundColor(UIColor.clearColor)
    .textColor(UIColor.blackColor)
    .keyboardType(UIKeyboardTypeDefault)
    .clearButtonMode(UITextFieldViewModeWhileEditing)
    .textAlignment(NSTextAlignmentLeft)
    .secureTextEntry(YES)
    .masonry(^(MASConstraintMaker *make){
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.top.mas_equalTo(self.userNameField.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(50);
    })
    .view;
    self.passField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIView *passNameLine = self.view
    .addView(5)
    .backgroundColor(KColorE5E5E5)
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.passField.mas_bottom);
        make.left.right.mas_equalTo(userNameLine);
        make.height.mas_equalTo(1);
    })
    .view;
    
    UIImageView *ivi = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_mima"]];
    UIView *lvv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 200)];
    lvv.backgroundColor = [UIColor clearColor];
    ivi.center = lvv.center;
    [lvv addSubview:ivi];
    self.passField.leftViewMode = UITextFieldViewModeAlways;
    self.passField.leftView = lvv;
    
    /*
    self.passHideButton = [[UIButton alloc] init];
    [self.passHideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 200));
    }];
    self.passHideButton.backgroundColor = [UIColor clearColor];
    self.passHideButton.selected = YES;
    [self.passHideButton setImage:[UIImage imageNamed:@"icon_pass_no"] forState:UIControlStateSelected];
    [self.passHideButton setImage:[UIImage imageNamed:@"icon_pass_yes"] forState:UIControlStateNormal];
    [self.passHideButton addTarget:self action:@selector(passHideClick:) forControlEvents:UIControlEventTouchUpInside];
    self.passField.rightViewMode = UITextFieldViewModeAlways;
    self.passField.rightView = self.passHideButton;
    */
    self.saveButton = self.view
    .addButton(12)
    .image(KImage(@"icon_wxz"))
    .imageSelected(KImage(@"icon_xz"))
    .title(LOCSTR(@"记住密码"))
    .titleFont(KPingFangFont(14))
    .titleColor(KColor666666)
    .contentHorizontalAlignment(UIControlContentHorizontalAlignmentLeft)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        x.selected = !x.selected;
    })
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(passNameLine.mas_bottom).mas_offset(20);
        make.left.mas_equalTo(self.passField);
        make.size.mas_equalTo(CGSizeMake(130, 20));
    })
    .view;
    [self.saveButton layoutButtonWithImageStyle:ZJButtonImageStyleLeft imageTitleToSpace:10];
    
    self.changePwdButton = self.view
    .addButton(15)
    .title(LOCSTR(@"忘记密码?"))
    .titleFont(KPingFangFont(14))
    .titleColor(KThemeColor)
    .contentHorizontalAlignment(UIControlContentHorizontalAlignmentRight)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
        ForgotPwdViewController *vc = [[ForgotPwdViewController alloc]init];
        vc.title_str = LOCSTR(@"找回密码");
        vc.registeredSuccess = ^(NSString * _Nonnull account, NSString * _Nonnull password) {
            STRONG
            self.userNameField.text = account;
            self.passField.text = password;
        };
        LoginViewModel *viewModel = [LoginViewModel new];
        vc.viewModel = viewModel;
        PushVC(vc)
    })
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.saveButton);
        make.right.mas_equalTo(self.passField);
        make.height.mas_equalTo(20);
    })
    .view;
    
    self.loginButton = self.view
    .addButton(14)
    .backgroundColor(KThemeColor)
    .title(LOCSTR(@"登录"))
    .cornerRadius(5)
    .titleFont(KPingFangFont(15))
    .titleColor(UIColor.whiteColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
        if (self.userNameField.text.length <=0) {
            return [SVProgressHUD showInfoWithStatus:LOCSTR(@"请输入手机号")];
        }
        if (self.passField.text.length <= 0) {
            return [SVProgressHUD showInfoWithStatus:LOCSTR(@"请输入密码")];
        }

        [self toLogin];
        
    })
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.saveButton.mas_bottom).mas_offset(30);
        make.left.right.mas_equalTo(self.passField);
        make.height.mas_equalTo(40);
    })
    .view;
    
   
    self.registerButton = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.registerButton];
    self.registerButton.zz_make
    .textAlignment(NSTextAlignmentCenter)
    .font(KPingFangFont(12))
    .textColor(KColor999999)
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.loginButton.mas_bottom).mas_offset(15);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(20);
    });
    
    self.registerButton.delegate = self;
    [self.registerButton setLinkAttributes:@{NSForegroundColorAttributeName:KThemeColor, NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleNone]}];
    
    NSString *tempStrr = LOCSTR(@"还没有账号，立即注册");
    NSRange boldRangee = [tempStrr rangeOfString:LOCSTR(@"立即注册") options:NSCaseInsensitiveSearch];
    [self.registerButton setText:tempStrr  afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString*(NSMutableAttributedString*mutableAttributedString){
        //设置可点击文字的范围
        //设定可点击文字的的大小
        UIFont*boldSystemFont = KPingFangFont(12);
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize,NULL);
        if(font){
            //设置可点击文本的大小
            [mutableAttributedString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)font range:boldRangee];
            //设置可点击文本的颜色
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)KColor666666 range:boldRangee];
    
            CFRelease(font);
        }
        return mutableAttributedString;
    }];
    [self.registerButton addLinkToURL:[NSURL URLWithString:@"1"] withRange:boldRangee];
    
    
    self.privacyLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.privacyLabel];
    self.privacyLabel.zz_make
    .textAlignment(NSTextAlignmentCenter)
    .font(KPingFangFont(12))
    .numberOfLines(0)
    .textColor(KColor999999)
    .masonry(^(MASConstraintMaker *make){
        make.left.right.mas_equalTo(self.loginButton);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(self.view).mas_offset(-(k_Height_SafetyArea+50));

    });
    self.privacyLabel.delegate = self;
    [self.privacyLabel setLinkAttributes:@{NSForegroundColorAttributeName:UIColor.redColor, NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleNone]}];
    
    NSString *tempStr = LOCSTR(@"登录注册表示同意用户协议及隐私条款");
    NSRange boldRange = [tempStr rangeOfString:LOCSTR(@"用户协议及隐私条款") options:NSCaseInsensitiveSearch];
    [self.privacyLabel setText:tempStr  afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString*(NSMutableAttributedString*mutableAttributedString){
        //设置可点击文字的范围
        //设定可点击文字的的大小
        UIFont*boldSystemFont = KPingFangFont(12);
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize,NULL);
        if(font){
            //设置可点击文本的大小
            [mutableAttributedString addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            //设置可点击文本的颜色
            [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)KColor666666 range:boldRange];
    
            CFRelease(font);
        }
        return mutableAttributedString;
    }];
    NSURL*firstUrl = [NSURL URLWithString:@"http://ys.cciot.cc/ybin/privacyPolicy_yingbin.html"];
    if (![Lauguage isEqualToString:@"zh"]) {
        firstUrl = [NSURL URLWithString:@"http://ys.cciot.cc/ybin/privacyPolicy_yingbin_en.html"];
    }
    //添加url
    [self.privacyLabel addLinkToURL:firstUrl withRange:boldRange];
    
    [self getFileNameData];
}
//显示与隐藏
-(void)passHideClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        self.passField.secureTextEntry = YES;
    }else{
        self.passField.secureTextEntry = NO;
    }
}
//登录=={
//    Data =     {
//        ExpireAt = 1620262761;
//        Token = 5d4f0047b4ae4fe0a1b5e58030bc7055;
//    };
//    RequestId = "D3A5955D-5805-4B4F-AF68-5CD4D0D9B81B";
//}
-(void)toLogin{
    WEAK
    [[TIoTCoreAccountSet shared] signInWithCountryCode:@"86" phoneNumber:self.userNameField.text password:self.passField.text success:^(id  _Nonnull responseObject) {
        STRONG
        NSLog(@"登录==%@",responseObject);
        //信鸽推送注册
       
         [[XGPushManage sharedXGPushManage] startPushService];

         

        [self appGetUserId];
        [SVProgressHUD showSuccessWithStatus:LOCSTR(@"登录成功")];

        [self dismissViewControllerAnimated:YES completion:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [TLNotificationCenter postNotificationName:LoginSuccessNotify object:nil];
        });
        [self savePaw];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
    }];
    

}
//获取用户id
-(void)appGetUserId{
    
    [[TIoTCoreAccountSet shared] getUserInfoOnSuccess:^(id  _Nonnull responseObject) {
        [[NSUserDefaults standardUserDefaults]setValue:responseObject[@"Data"] forKey:@"userInfo"];
    } failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
        
    }];
}

//判断保存密码
- (void)getFileNameData{
    NSString *path = [NSString documentFolder];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = [path stringByAppendingPathComponent:@"yingbin.plist"];
    NSDictionary *dicNamePwd = [NSDictionary dictionaryWithContentsOfFile:filename];

    if (![fileManager fileExistsAtPath:filename]) {
        self.saveButton.selected = NO;
    }else{
        self.saveButton.selected = YES;
        NSDictionary *dicNamePwd = [NSDictionary dictionaryWithContentsOfFile:filename];
        self.userNameField.text = [dicNamePwd objectForKey:@"name"] ;
        self.passField.text = [dicNamePwd objectForKey:@"pwd"];
        self.loginButton.enabled = YES;
    }
    //判断字典是否有pwd密码key
    if (![dicNamePwd objectForKey:@"pwd"]) {
        self.saveButton.selected = NO;
    }
    
}
//保存密码
- (void)savePaw{
    [TLUserDefaults setObject:self.userNameField.text forKey:USERLOGIN_USERNAME];
    [TLUserDefaults setObject:self.passField.text forKey:USERLOGIN_PASSWORD];
    
    NSString *path = [NSString documentFolder];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = [path stringByAppendingPathComponent:@"yingbin.plist"];
    if (self.saveButton.selected) {
        NSDictionary *dicNamePwd = @{@"name":self.userNameField.text,
                                     @"pwd":self.passField.text
                                     };
        [dicNamePwd writeToFile:filename atomically:YES];
    }
    else{
        [fileManager removeItemAtPath:filename error:nil];
    }
}
- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    if ([url.absoluteString isEqualToString:@"1"]) {
        WEAK
        ForgotPwdViewController *vc = [[ForgotPwdViewController alloc]init];
        vc.title_str = LOCSTR(@"注册");
        vc.registeredSuccess = ^(NSString * _Nonnull account, NSString * _Nonnull password) {
            STRONG
            self.userNameField.text = account;
            self.passField.text = password;
        };
        LoginViewModel *viewModel = [LoginViewModel new];
        vc.viewModel = viewModel;
        PushVC(vc)
        return;
    }

    [MethodTool pushWebVcFrom:self URL:url.absoluteString title:LOCSTR(@"隐私政策")];
}
@end
