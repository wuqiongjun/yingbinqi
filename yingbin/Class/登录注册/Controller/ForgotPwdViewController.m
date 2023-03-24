//
//  ForgotPwdViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "ForgotPwdViewController.h"
#import "WQCountryCodeController.h"
@interface ForgotPwdViewController ()

KSTRONG NSMutableArray *dataArray;

@end

@implementation ForgotPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    /*
     注册和重置密码
     */
    self.navigationItem.title = self.title_str;
    [self createSubviews];
}
- (void)createSubviews{
    WEAK
    self.clear();
    self.addSection(0);
    self.addCells(@"ForgotPwdCell").toSection(0).withDataModelArray(self.dataArray).eventAction(^id(NSInteger index,BaseGeneralModel *model){
        switch (index) {
            case 0:
            {
                self.viewModel.n_pwd = model.itemName;
            }
                break;
            case 1:
            {
                self.viewModel.zc_pwd = model.itemName;
            }
                break;
            case 1112:
            {
                self.viewModel.code = model.itemName;
            }
                break;
                
            default:
                break;
        }
        if (index == 100) {
            if (self.viewModel.phone.length <= 0) {
                [SVProgressHUD showInfoWithStatus:LOCSTR(@"请输入手机号码")];
                return nil;
            }
            if ([self.title_str containsString:LOCSTR(@"注册")]) {
                /*
                 发送验证码（用于手机号注册）
                 */
                [[TIoTCoreAccountSet shared] sendVerificationCodeWithCountryCode:self.viewModel.zone phoneNumber:self.viewModel.phone success:^(id  _Nonnull responseObject) {
                    [TLNotificationCenter postNotificationName:@"CountdownBegin" object:nil];
                    [SVProgressHUD showSuccessWithStatus:LOCSTR(@"验证码发送成功")];
                } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                    [MBProgressHUD showError:reason];
                }];
            }else{
                /*
                 发送用于重置的短信验证码
                 */
                [[TIoTCoreAccountSet shared] sendCodeForResetWithCountryCode:self.viewModel.zone phoneNumber:self.viewModel.phone success:^(id  _Nonnull responseObject) {
                    [TLNotificationCenter postNotificationName:@"CountdownBegin" object:nil];
                    [SVProgressHUD showSuccessWithStatus:LOCSTR(@"验证码发送成功")];
                } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                    [MBProgressHUD showError:reason];
                }];
            }
            return nil;
        }
        return nil;
    });
    self.insertCell(@"EditPhoneCell")
       .toSection(0)
       .toIndex(0)
       .withDataModel([BaseGeneralModel yy_modelWithJSON:@{titleKey   : @"",
                                                      placeholderKey : LOCSTR(@"请输入手机号"),
                                                      subTitleKey:@"+86",
                                                      tagKey     : @(1)
       }])
       .eventAction(^id(NSInteger index,BaseGeneralModel *model){
           STRONG
           switch (index) {
               case 0:
               {
                   WQCountryCodeController *countryCodeVC = [[WQCountryCodeController alloc] init];
                   countryCodeVC.returnCountryCodeBlock = ^(NSString *countryName, NSString *code) {
                       STRONG
                       self.viewModel.zone = code;
                       model.itemSubName = [NSString stringWithFormat:@"+%@",code];
                       [self reloadView];
                   };
                   
                   [self.navigationController pushViewController:countryCodeVC animated:YES];

               }
                   break;
               case 1:
               {
                   self.viewModel.phone = model.itemName;
               }
                   break;
               default:
                   break;
           }


           return nil;
       });
   
    self.addSection(1);
    self.addSeperatorCell(CGSizeMake(SCREEN_WIDTH, 30), UIColor.whiteColor).toSection(1);
    self.addCell(@"BaseButtonCell").toSection(1).withDataModel(LOCSTR(@"确认")).eventAction(^id (NSInteger ty, UIButton *x){
        STRONG

        if (self.viewModel.phone.length <= 0) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"请输入手机号码")];
            return nil;
        }
        if (self.viewModel.code.length <= 0) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"请输入验证码")];
            return nil;
        }
        if (self.viewModel.n_pwd.length <= 0) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"请输入密码")];
            return nil;
        }
        if (self.viewModel.zc_pwd.length <= 0) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"请再次输入密码")];
            return nil;
        }
        if (![self.viewModel.n_pwd isEqualToString:self.viewModel.zc_pwd]) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"两次输入密码不一致")];
            return nil;
        }
        if (![MethodTool detectionIsPasswordQualified:self.viewModel.n_pwd]) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"密码支持8-16位，必须包含字母和数字")];
            return nil;
        }
        if ([self.title_str containsString:LOCSTR(@"注册")]) {
            /*
             手机号注册self.viewModel.zone 默认中国86
             */
            [[TIoTCoreAccountSet shared] createPhoneUserWithCountryCode:@"86" phoneNumber:self.viewModel.phone verificationCode:self.viewModel.code password:self.viewModel.n_pwd success:^(id  _Nonnull responseObject) {
                STRONG
                [MBProgressHUD showSuccess:LOCSTR(@"注册成功")];
                [self.navigationController popViewControllerAnimated:YES];
                KBLOCK_EXEC(self.registeredSuccess,self.viewModel.phone,self.viewModel.n_pwd);

            } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                [MBProgressHUD showError:reason];
            }];
        }else{
            /*
             重置密码（手机号方式）self.viewModel.zone
             */
            [[TIoTCoreAccountSet shared] ResetPasswordWithCountryCode:@"86" phoneNumber:self.viewModel.phone verificationCode:self.viewModel.code password:self.viewModel.n_pwd success:^(id  _Nonnull responseObject) {
                STRONG
                
                [MBProgressHUD showSuccess:LOCSTR(@"找回密码成功")];
                [self.navigationController popViewControllerAnimated:YES];
                KBLOCK_EXEC(self.registeredSuccess,self.viewModel.phone,self.viewModel.n_pwd);

            } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                [MBProgressHUD showError:reason];
            }];
        }
        
        return nil;
    });
    
    
    
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        NSMutableArray *dateArray = [NSMutableArray array];
        
        [dateArray addObject:@{titleKey   : @"",
                               placeholderKey : LOCSTR(@"请输入验证码"),
                               tagKey     : @(1112)
                               }];
        [dateArray addObject:@{titleKey   : @"",
                               placeholderKey : LOCSTR(@"请输入密码"),
                               tagKey     : @(0)
                               }];
        [dateArray addObject:@{titleKey   : @"",
                               placeholderKey : LOCSTR(@"请再次输入密码"),
                               tagKey     : @(1)
                               }];
        
        
        _dataArray = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateArray] mutableCopy];
    }
    return _dataArray;
}


@end
