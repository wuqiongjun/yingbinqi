//
//  ResetPwdViewController.m
//  yingbin
//
//  Created by slxk on 2021/5/14.
//  Copyright © 2021 wq. All rights reserved.
//

#import "ResetPwdViewController.h"

@interface ResetPwdViewController ()

@property (nonatomic, strong)NSMutableArray *dataArray;

@end

@implementation ResetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"修改密码");
    [self createSubviews];

}
- (void)createSubviews{

   __block NSString *temp;

    WEAK
    self.clear();
    self.addSection(0).sectionInsets(UIEdgeInsetsMake(15, 0, 0, 0));
    self.addCells(@"ForgotPwdCell").toSection(0).withDataModelArray(self.dataArray).eventAction(^id(NSInteger index,BaseGeneralModel *model){
        STRONG
        switch (model.tag) {
            case 0:
                self.viewModel.oldPwd = model.itemName;
                break;
            case 1:
                temp = model.itemName;
                break;
            case 2:
                self.viewModel.n_pwd = model.itemName;
                break;
            default:
                break;
        }
        return nil;
    });
    
    
    self.addSection(1);
    self.addSeperatorCell(CGSizeMake(SCREEN_WIDTH, 30), UIColor.groupTableViewBackgroundColor).toSection(1);
    self.addCell(@"BaseButtonCell").toSection(1).withDataModel(LOCSTR(@"确定")).eventAction(^id (NSInteger ty, UIButton *x){
        STRONG
        if (self.viewModel.oldPwd.length <= 0) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"请输入旧密码")];
            return nil;
        }
        if (temp.length <= 0) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"请输入新密码")];
            return nil;
        }
        if (self.viewModel.n_pwd.length <= 0) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"请再次输入新密码")];
            return nil;
        }
        
        if (![temp isEqualToString:self.viewModel.n_pwd]) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"两次输入新密码不一致")];
            return nil;
        }
        
        if ([self.viewModel.oldPwd isEqualToString:self.viewModel.n_pwd]) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"不能修改成原密码")];
            return nil;
        }
        if (![MethodTool detectionIsPasswordQualified:self.viewModel.n_pwd]) {
            [SVProgressHUD showInfoWithStatus:LOCSTR(@"密码支持8-16位，必须包含字母和数字")];
            return nil;
        }
        
//        if(![MethodTool isValidPsw:self.viewModel.nPwd])
//        {
//            [SVProgressHUD showInfoWithStatus:LOCSTR(@"密码只能由字母,数字,下划线6~15位的字符组成")];
//            return nil;
//        }
        [self requestModifyPassword];
        return nil;
    });
    
}
//修改密码
- (void)requestModifyPassword{
//    WEAK
    NSDictionary *tmpDic = @{@"Password":self.viewModel.oldPwd,@"NewPassword":self.viewModel.n_pwd};
    [[TIoTCoreRequestObject shared] post:AppUserResetPassword Param:tmpDic success:^(id responseObject) {
//        STRONG
        [MBProgressHUD showMessage:LOCSTR(@"密码已修改 请重新登录") icon:@""];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [[TIoTCoreAccountSet shared] signOutOnSuccess:^(id  _Nonnull responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TLNotificationCenter postNotificationName:LoginSuccessNotify object:nil];
                });
                
            } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                [MBProgressHUD showError:reason];
                [MethodTool judgeUserSignoutWithReturnToken:dic];
                
            }];
        });
        


    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];

    }];
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        NSMutableArray *dateArray = [NSMutableArray array];
        [dateArray addObject:@{titleKey   : @"",
                               placeholderKey : LOCSTR(@"请输入旧密码"),
                               tagKey     : @(0)
                               }];
        [dateArray addObject:@{titleKey   : @"",
                               placeholderKey : LOCSTR(@"请输入新密码"),
                               tagKey     : @(1)
                               }];
        [dateArray addObject:@{titleKey   : @"",
                               placeholderKey : LOCSTR(@"请再次输入新密码"),
                               tagKey     : @(2)
                               }];
        
        
        _dataArray = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateArray] mutableCopy];
    }
    return _dataArray;
}


@end
