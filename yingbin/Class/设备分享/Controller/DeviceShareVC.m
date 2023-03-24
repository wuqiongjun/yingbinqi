//
//  DeviceShareVC.m
//  yingbin
//
//  Created by slxk on 2021/5/15.
//  Copyright © 2021 wq. All rights reserved.
//

#import "DeviceShareVC.h"
#import "DeviceShareCell.h"
#import "TIoTRefreshHeader.h"

@interface DeviceShareVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) DeviceViewModel *model;
@property (nonatomic, strong) UIView *headerView;
@end

@implementation DeviceShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"设备分享");
    self.model = [UserManageCenter sharedUserManageCenter].deviceModel;

    self.navigationItem.rightBarButtonItem = self.ShareDeviceItem;


    [self.view addSubview:self.tableView];
    
    
    // 下拉刷新
    WEAK
    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
        STRONG
        [self queryDeviceUserList];
    }];
    
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    
    [self queryDeviceUserList];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, 250, 20)];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.textColor = KColor999999;
    label.text = LOCSTR(@"设备已经单独分享给以下用户");
    [view addSubview:label];
    self.headerView = view;

}
//发送分享请求
- (void)shareDeviceItemClick:(UIBarButtonItem *)btn{
    WEAK
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCSTR(@"提示") message:LOCSTR(@"此手机号为将要分享到的账号") preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"取消") style:UIAlertActionStyleDefault handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                STRONG
                //获取第1个输入框
                UITextField *TextField = alertController.textFields.firstObject;
                NSString *moneyStr = TextField.text;
                if ([MethodTool isBlankString:moneyStr])
                {
                    [MBProgressHUD showError:LOCSTR(@"请输入账号")];
                }
                else
                {
                    if (moneyStr.length >20) {
                        [MBProgressHUD showError:LOCSTR(@"手机号不能超过20个字符")];
                    }else{
                        [[TIoTCoreDeviceSet shared] sendInvitationToPhoneNum:moneyStr withCountryCode:@"86" familyId:self.model.FamilyId productId:self.model.ProductId deviceName:self.model.DeviceName success:^(id  _Nonnull responseObject) {
                            STRONG
                            [MBProgressHUD showSuccess:LOCSTR(@"发送成功")];
                            [self.navigationController popViewControllerAnimated:YES];
                        } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                            if ([reason isEqualToString:@"PhoneNumber invalid"]) {
                                [MBProgressHUD showError:LOCSTR(@"手机号格式不正确")];
                            }else if([reason isEqualToString:@"User not found"]){
                                [MBProgressHUD showError:LOCSTR(@"用户不存在")];
                            }else{
                                [MBProgressHUD showError:reason];
                            }
                        }];
                    }
                    
                }
               
                
            }]];

            //定义第一个输入框
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"请输入手机号";
                textField.keyboardType = UIKeyboardTypeDecimalPad;
            }];

            [self presentViewController:alertController animated:true completion:nil];
}


#pragma mark - request - 获取分享的设备列表
//Users =     (
//            {
//        Avatar = "http://iotexplore-app-1256872341.cos.ap-guangzhou.myqcloud.com/iotexplorer-app-logs/user_250921057949585408/7F03078C-026A-44CC-B8BB-CEF48E5C4EDE";
//        BindTime = 1620986787;
//        CountryCode = 86;
//        NickName = "mobile_8615622878576";
//        PhoneNumber = "156****8576";
//        UserID = 250921057949585408;
//    }
//);
- (void)queryDeviceUserList
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:self.model.ProductId forKey:@"ProductId"];
    [param setValue:self.model.DeviceName forKey:@"DeviceName"];
    WEAK
    [[TIoTCoreRequestObject shared] post:AppListShareDeviceUsers Param:param success:^(id responseObject) {
        STRONG

        self.dataArray = [responseObject[@"Users"] mutableCopy];
        if (self.dataArray.count <= 0) {
            self.tableView.tableHeaderView.hidden = YES;
        }
        [self refreshUI];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];

    }];

    [self.tableView.mj_header endRefreshing];
    
    /*
    NSDictionary *tmpDic = @{
        @"ProductId":self.model.ProductId?:@"",
        @"DeviceName":self.model.DeviceName?:@"",
        @"FamilyId":[TIoTCoreUserManage shared].familyId
    };
    [[TIoTCoreRequestObject shared] post:@"AppCreateShareDeviceToken" Param:tmpDic success:^(id responseObject) {
        STRONG
        [self AppDescribeShareDeviceToken:responseObject[@"ShareDeviceToken"]];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
    }];
*/
}
-(void)refreshUI{
    [self.tableView showDataCount:self.dataArray.count Title:LOCSTR(@"暂无数据呦。。。。。。") image:KImage(@"icon_wushuju")];
    [self.tableView reloadData];
}
/*
{
    RequestId = "007F6D4D-B8EA-4451-B2EA-7DBAABBD3560";
    ShareDeviceTokenInfo =     {
        AliasName = dev0002;
        BindTime = 0;
        Context = "";
        CreateTime = 1624430914;
        DeviceId = "56UED5AJ29/dev0002";
        DeviceName = dev0002;
        ExpireTime = 1624517314;
        FromUserID = 272748441371676672;
        FromUserNick = "mobile_8616670123221";
        IconUrl = "https://main.qcloudimg.com/raw/1c69eb04f93e925436a3ee9d4896068e.png";
        ProductId = 56UED5AJ29;
        UserID = "";
        UserNick = "";
    };
}
 */
-(void)AppDescribeShareDeviceToken:(NSString *)token{
//    WEAK
    NSDictionary *tmpDic = @{
        @"ShareDeviceToken":token?:@"",
    };
    [[TIoTCoreRequestObject shared] post:@"AppDescribeShareDeviceToken" Param:tmpDic success:^(id responseObject) {
//        STRONG
        NSLog(@"-----");
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];

    }];
}

#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK
    DeviceShareCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceShareCell class]) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataDic = self.dataArray[indexPath.row];
    cell.model = self.model;
    
    cell.CancelShareBtnBlock = ^(UIButton * _Nonnull btn) {
        [TLUIUtility showAlertWithTitle:LOCSTR(@"提示") message:LOCSTR(@"确定要取消分享吗？") cancelButtonTitle:LOCSTR(@"取消") otherButtonTitles:@[@"确定"] actionHandler:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                STRONG
                NSString *userId = self.dataArray[indexPath.row][@"UserID"];
                
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setValue:userId forKey:@"RemoveUserID"];
                [param setValue:self.model.ProductId forKey:@"ProductId"];
                [param setValue:self.model.DeviceName forKey:@"DeviceName"];
                [[TIoTCoreRequestObject shared] post:AppRemoveShareDeviceUser Param:param success:^(id responseObject) {
                    STRONG
                    [MBProgressHUD showSuccess:LOCSTR(@"取消成功")];
                    [self.dataArray removeObjectAtIndex:indexPath.row];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                    [self refreshUI];
                } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                    [MBProgressHUD showError:reason];
                }];

            }
        }];
    };
     
    return cell;
}
/*
-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
    //删除
    WEAK
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:LOCSTR(@"删除") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        STRONG
        NSString *userId = self.dataArray[indexPath.row][@"UserID"];
        
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setValue:userId forKey:@"RemoveUserID"];
        [param setValue:self.model.ProductId forKey:@"ProductId"];
        [param setValue:self.model.DeviceName forKey:@"DeviceName"];
        [[TIoTCoreRequestObject shared] post:AppRemoveShareDeviceUser Param:param success:^(id responseObject) {
            STRONG
            [MBProgressHUD showSuccess:LOCSTR(@"删除成功")];
            [self.dataArray removeObjectAtIndex:indexPath.row];
            [self refreshUI];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [MBProgressHUD showError:reason];
            [MethodTool judgeUserSignoutWithReturnToken:dic];

        }];




        completionHandler (YES);
        [self.tableView reloadData];
    }];
    deleteRowAction.image = [UIImage imageNamed:LOCSTR(@"删除")];
    deleteRowAction.backgroundColor = [UIColor redColor];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
}
*/
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//
//    UIView *view = [[UIView alloc]init];
//    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, 250, 20)];
//    label.font = [UIFont boldSystemFontOfSize:15];
//    label.textColor = KColor999999;
//    label.text = LOCSTR(@"设备已经单独分享给以下用户");
//    [view addSubview:label];
//    return view;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_NavBar) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.headerView;
        [_tableView registerClass:[DeviceShareCell class] forCellReuseIdentifier:NSStringFromClass([DeviceShareCell class])];

    }
    return _tableView;
}
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}


@end
