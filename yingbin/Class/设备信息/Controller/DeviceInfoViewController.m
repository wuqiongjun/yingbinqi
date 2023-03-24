//
//  DeviceInfoViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "DeviceInfoViewController.h"

@interface DeviceInfoViewController ()

@property (nonatomic, strong)BaseGeneralModel *deviceNameModel;
@property (nonatomic, strong)DeviceViewModel *model;


@end
@implementation DeviceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"设备信息");
    self.model = [UserManageCenter sharedUserManageCenter].deviceModel;

    NSString * alias = self.model.AliasName;
    if (![MethodTool isBlankString:alias]) {
        self.deviceNameSTR = self.model.AliasName;
    }
    else{
        self.deviceNameSTR = self.model.DeviceName;
    }
    NSDictionary *dic = self.Response[@"DeviceInfo"][@"Value"];
    
    self.versionSTR = dic[@"FirmwareVersion"];
    self.wifiSTR = dic[@"WifiName"];
    self.macSTR = dic[@"Mac"];
    self.signalSTR = [NSString stringWithFormat:@"%@dbm",dic[@"Rssi"]];
    self.batterySTR = dic[@"BatteryLevel"];
    
    [self createSubviews];
}
-(void)createSubviews{
    UIView *bgView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 270+54));
    })
    .view;
    bgView.layer.cornerRadius = 9;
    [self.view sendSubviewToBack:bgView];
    
    NSMutableArray *dateArray = [NSMutableArray array];
    [dateArray addObject:@{titleKey   : LOCSTR(@"设备名称"),
                           subTitleKey:self.deviceNameSTR?:@"-",
                           selectType  : @(0)
                           }];
    [dateArray addObject:@{titleKey   : LOCSTR(@"Wifi名称"),
                           subTitleKey:self.wifiSTR?:@"-",
                          selectType  : @(1)
                          }];
    [dateArray addObject:@{titleKey   : LOCSTR(@"Mac地址"),
                           subTitleKey:self.macSTR?:@"-",
                           selectType  : @(2)
                           }];
    [dateArray addObject:@{titleKey   : LOCSTR(@"固件版本"),
                           subTitleKey:self.versionSTR?:@"-",
                           selectType  : @(3)
                           }];
    [dateArray addObject:@{titleKey   : LOCSTR(@"信号强度"),
                           subTitleKey:self.signalSTR?:@"-",
                           selectType  : @(4)
                           }];
    [dateArray addObject:@{titleKey   : LOCSTR(@"设备电量"),
                           subTitleKey:self.batterySTR?:@"-",
                           selectType  : @(5)
                           }];
    WEAK
    NSMutableArray *array = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateArray] mutableCopy];
    self.collectionView.scrollEnabled = NO;
    self.addSection(0).sectionInsets(UIEdgeInsetsMake(10, 0, 0, 0));
    self.addCells(@"DeviceInfoViewCell")
    .toSection(0).withDataModelArray(array)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
            case 0:
            {//设备名称
                self.deviceNameModel = model;
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCSTR(@"提示") message:LOCSTR(@"修改设备名称") preferredStyle:UIAlertControllerStyleAlert];
                        [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"取消") style:UIAlertActionStyleDefault handler:nil]];
                        [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            STRONG
                            UITextField *TextField = alertController.textFields.firstObject;
                            
                            NSString *moneyStr = TextField.text;
                            if ([NSString isNullOrNilWithObject:moneyStr] || [NSString isFullSpaceEmpty:moneyStr]) {
                                [MBProgressHUD showMessage:LOCSTR(@"请输入设备名称") icon:@""];
                            }else {

                                if (moneyStr.length >20) {
                                    [MBProgressHUD showError:LOCSTR(@"名称不能超过20个字符")];
                                }else {
                                    [[TIoTCoreRequestObject shared] post:AppUpdateDeviceInFamily Param:@{@"ProductID":self.model.ProductId,@"DeviceName":self.model.DeviceName,@"AliasName":moneyStr} success:^(id responseObject) {
                                        STRONG
                                        [MBProgressHUD showMessage:LOCSTR(@"设备名称修改成功") icon:@""];
                                        self.deviceNameModel.itemSubName = moneyStr;
                                        self.deviceNameSTR = moneyStr;
                                        [[NSNotificationCenter defaultCenter] postNotificationName:DeviceInformation object:nil];
                                        [self reloadView];
                                    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                                        [MBProgressHUD showError:reason];
                                        [MethodTool judgeUserSignoutWithReturnToken:dic];

                                    }];

                                }
                            }

                        }]];

                        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                            STRONG
                            textField.placeholder = LOCSTR(@"请输入设备名称");
                            textField.text = self.deviceNameSTR;
                        }];

                        [self presentViewController:alertController animated:true completion:nil];
            }
                break;
            case 1:
            {//Wifi名称

            }
                break;
            case 2:
            {//Mac地址
            
            }
                break;
            case 3:
            {//设备初始化
                
            }
                break;
            case 4:
            {//信号强度
                
            }
                break;
            case 5:
            {//电量
                
            }
                break;
            default:
                break;
        }
    });
}

@end
