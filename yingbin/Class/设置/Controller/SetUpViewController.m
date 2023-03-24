//
//  SetUpViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/23.
//  Copyright © 2021 wq. All rights reserved.
//

#import "SetUpViewController.h"
#import "BofangSetVC.h"
#import "YingBinQuViewController.h"
#import "DeviceInfoViewController.h"
#import "DeviceShareVC.h"
#import "UIExPickerView.h"
#import "locallyMusicModel.h"
#import "DeviceInitVC.h"
#import "PeopleFlowStatisticsVC.h"
@interface SetUpViewController ()<pickerDelegate>

@property (nonatomic, strong)NSMutableDictionary *Response;

@property (nonatomic, strong)NSArray *volumeArray;//音量调节数组
@property (nonatomic, strong)NSArray *playModeArray;//播放模式数组
@property (nonatomic, strong)NSArray *lampSwitchArray;//待机指示灯数组/感应指示灯数组

@property (nonatomic, assign)NSInteger volunmeIndexSelect;//音量调节选中下标
@property (nonatomic, assign)NSInteger DaiJjindexSelect;
@property (nonatomic, assign)NSInteger PlayIndexSelect;

@property (nonatomic, strong)BaseGeneralModel *volunmeModel;
@property (nonatomic, strong)BaseGeneralModel *DaiJjiModel;
@property (nonatomic, strong)BaseGeneralModel *PlayModel;

@property (nonatomic, strong)NSMutableArray *arrayOne;
@property (nonatomic, strong)NSMutableArray *arrayTwo;
@property (nonatomic, strong)NSMutableArray *arrayFour;


@property (nonatomic, strong)NSMutableDictionary *deviceInfoModel;

@property (nonatomic, strong)DeviceViewModel *model;

@end

@implementation SetUpViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"设置");
    
    self.model = [UserManageCenter sharedUserManageCenter].deviceModel;

    [self getAppGetDeviceData];

    [self getAppCheckFirmwareUpdate];
    
    [self createSubviews];
    

}
-(void)createSubviews{
    
//    UIView *bgoneView = self.view
//    .addView(0)
//    .backgroundColor(UIColor.whiteColor)
//    .masonry(^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(12.0f);
//        make.right.mas_equalTo(-12);
//        make.top.mas_equalTo(10);
//        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 162+54+54));
//    })
//    .view;
//    bgoneView.layer.cornerRadius = 9;
//    [self.view sendSubviewToBack:bgoneView];
//
//    UIView *bgfourView = self.view
//    .addView(0)
//    .backgroundColor(UIColor.whiteColor)
//    .masonry(^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(12.0f);
//        make.right.mas_equalTo(-12);
//        make.top.mas_equalTo(bgoneView.mas_bottom).mas_offset(10);
//        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 216));
//    })
//    .view;
//    bgfourView.layer.cornerRadius = 9;
//    [self.view sendSubviewToBack:bgfourView];
//
//    UIView *bgtwoView = self.view
//    .addView(0)
//    .backgroundColor(UIColor.whiteColor)
//    .masonry(^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(12.0f);
//        make.right.mas_equalTo(-12);
//        make.top.mas_equalTo(bgfourView.mas_bottom).mas_offset(10);
//        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 216));
//    })
//    .view;
//    bgtwoView.layer.cornerRadius = 9;
//    [self.view sendSubviewToBack:bgtwoView];
    
   
    

    
    NSMutableArray *dateOneArray = [NSMutableArray array];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"播放设置"),
                           imgNameKey : @"icon_set_1",
                           selectType  : @(0)
                           }];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"音量调节"),
                          imgNameKey : @"icon_set_2",
                          selectType  : @(1)
    }];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"人流量统计"),
                           imgNameKey : @"icon_tongji",
                           selectType  : @(4)
                           }];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"重置人流量"),
                           imgNameKey : @"icon_qingling",
                           selectType  : @(3)
                           }];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"迎宾曲"),
                           imgNameKey : @"icon_set_3",
                           selectType  : @(2)
                           }];
    WEAK
    self.arrayOne = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateOneArray] mutableCopy];
//    self.collectionView.scrollEnabled = NO;
    self.addSection(0).sectionInsets(UIEdgeInsetsMake(10, 0, 0, 0));
    self.addCells(@"SetUpViewCell")
    .toSection(0).withDataModelArray(self.arrayOne)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
            case 0:
            {//播放设置
                if (![MethodTool isBlankString:self.model.FamilyId]) {
                    BofangSetVC *vc = [[BofangSetVC alloc]init];
                    PushVC(vc);
                }
                else{
                    [MBProgressHUD showMessage:LOCSTR(@"用户对该设备无权限") icon:@""];
                }
                
            }
                break;
            case 1:
            {//音量调节
                
                UIExPickerView *pView = [[UIExPickerView alloc ] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH) titleStr:LOCSTR(@"音量设置") indexSelect:self.volunmeIndexSelect arr:self.volumeArray devModel:self.model];
                pView.delegate = self;
                self.volunmeModel = model;
                [self.view addSubview:pView];

            }
                break;
            case 2:
            {//迎宾曲
                if (![MethodTool isBlankString:self.model.FamilyId]) {
                    YingBinQuViewController *vc = [[YingBinQuViewController alloc]init];
                    PushVC(vc);
                }
                else{
                    [MBProgressHUD showMessage:LOCSTR(@"用户对该设备无权限") icon:@""];
                }
                
                
            }
                break;
            case 3:
            {//重置人流量
                [TLUIUtility showAlertWithTitle:LOCSTR(@"确定要重置人流量么？")message:LOCSTR(@"重置后人流量重新统计") cancelButtonTitle:LOCSTR(@"取消") otherButtonTitles:@[@"确定"] actionHandler:^(NSInteger buttonIndex) {
                    STRONG
                    if (buttonIndex == 1) {
                        NSDictionary *tmpDic = @{
                            @"ProductId":self.model.ProductId?:@"",
                            @"DeviceName":self.model.DeviceName?:@"",
                            @"Data":[NSString objectToJson:@{@"Counter":@0}]?:@""};
                        [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
                            [MBProgressHUD showMessage:LOCSTR(@"重置成功") icon:@""];
                            [[NSNotificationCenter defaultCenter] postNotificationName:DeviceInformation object:nil];
                        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                            [MBProgressHUD showError:reason];
                            [MethodTool judgeUserSignoutWithReturnToken:dic];
                        }];
                    }
                }];
                
                
            }
                break;
            case 4:
            {//人流量统计
                PeopleFlowStatisticsVC *vc = [[PeopleFlowStatisticsVC alloc]init];
                PushVC(vc);
            }
            default:
                break;
        }
    });
    
    
    NSMutableArray *datefourArray = [NSMutableArray array];
    [datefourArray addObject:@{titleKey   : LOCSTR(@"待机指示灯"),
                           imgNameKey : @"icon_set_daiji",
                           selectType  : @(0)
                           }];
    [datefourArray addObject:@{titleKey   : LOCSTR(@"播放指示灯"),
                           imgNameKey : @"icon_set_play",
                           selectType  : @(1)
                           }];

    self.arrayFour = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:datefourArray] mutableCopy];
    self.addSection(1).sectionInsets(UIEdgeInsetsMake(10, 0, 0, 0));
    self.addCells(@"SetUpViewCell")
    .toSection(1).withDataModelArray(self.arrayFour)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
            case 0:
            {//待机指示灯
                UIExPickerView *pView = [[UIExPickerView alloc ] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH) titleStr:LOCSTR(@"待机指示灯设置") indexSelect:self.DaiJjindexSelect arr:self.lampSwitchArray devModel:self.model];
                self.DaiJjiModel = model;
                pView.delegate = self;
                [self.view addSubview:pView];
            }
                break;
            case 1:
            {//感应指示灯
                UIExPickerView *pView = [[UIExPickerView alloc ] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH) titleStr:LOCSTR(@"播放指示灯设置") indexSelect:self.PlayIndexSelect arr:self.lampSwitchArray devModel:self.model];
                self.PlayModel = model;
                pView.delegate = self;
                [self.view addSubview:pView];
            }
                break;
            default:
                break;
        }
    });
    
    
    
    NSMutableArray *dateTwoArray = [NSMutableArray array];
//    [dateTwoArray addObject:@{titleKey   : LOCSTR(@"播放模式设置"),
//                           imgNameKey : @"icon_set_4",
//                           subTitleKey: LOCSTR(@"感应播放"),
//                           selectType  : @(0)
//                           }];
    [dateTwoArray addObject:@{titleKey   : LOCSTR(@"设备分享"),
                           imgNameKey : @"icon_set_4",
                           selectType  : @(1)
                           }];
    [dateTwoArray addObject:@{titleKey   : LOCSTR(@"设备解绑"),
                          imgNameKey : @"icon_set_5",
                          selectType  : @(2)
    }];
    [dateTwoArray addObject:@{titleKey   : LOCSTR(@"设备信息"),
                           imgNameKey : @"icon_set_6",
                           selectType  : @(3)
                           }];
    [dateTwoArray addObject:@{titleKey   : LOCSTR(@"设备初始化"),
                           imgNameKey : @"icon_set_7",
                           selectType  : @(4)
                           }];
    self.arrayTwo = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateTwoArray] mutableCopy];
//    self.collectionView.scrollEnabled = NO;
    self.addSection(2).sectionInsets(UIEdgeInsetsMake(10, 0, 0, 0));
    self.addCells(@"SetUpViewCell")
    .toSection(2).withDataModelArray(self.arrayTwo)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
                
            case 0:
            {//播放模式设置
//                UIExPickerView *pView = [[UIExPickerView alloc ] initWithFrame:CGRectMake(0, self.view.frame.size.height-270, self.view.frame.size.width, 270) titleStr:LOCSTR(@"播放模式设置") indexSelect:self.playModeIndexSelect arr:self.playModeArray devModel:self.model];
//                pView.delegate = self;
//                [self.view addSubview:pView];
            }
                break;
                 
            case 1:
            {//设备分享
                if (![MethodTool isBlankString:self.model.FamilyId]) {
                    DeviceShareVC *vc = [DeviceShareVC new];
                    PushVC(vc);                }
                else{
                    [MBProgressHUD showMessage:LOCSTR(@"用户对该设备无权限") icon:@""];
                }
                
            }
                break;
            case 2:
            {//设备解绑
                WEAK
                [TLUIUtility showAlertWithTitle:[MethodTool isBlankString:self.model.FamilyId]?LOCSTR(@"确定要解绑分享的设备吗？"):LOCSTR(@"确定要解绑设备吗？") message:LOCSTR(@"解绑后数据无法直接恢复") cancelButtonTitle:LOCSTR(@"取消") otherButtonTitles:@[@"解绑"] actionHandler:^(NSInteger buttonIndex) {
                    STRONG
                    if (buttonIndex == 1) {
                        
                        if ([MethodTool isBlankString:self.model.FamilyId]) {
                            
                            NSDictionary *tmpDic = @{
                                @"ProductId":self.model.ProductId?:@"",
                                @"DeviceName":self.model.DeviceName?:@"",
                                @"RequestId":[[NSUUID UUID] UUIDString],
                            };
                            [[TIoTCoreRequestObject shared] post:@"AppRemoveUserShareDevice" Param:tmpDic success:^(id responseObject) {
                                STRONG
                                [MBProgressHUD showSuccess:LOCSTR(@"解绑成功")];
                                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceInformation object:nil];
                                [self.navigationController popViewControllerAnimated:YES];
                            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                                [MBProgressHUD showError:reason];
                                [MethodTool judgeUserSignoutWithReturnToken:dic];
                            }];
                            
                        }else{
                            
                            [[TIoTCoreDeviceSet shared] deleteDeviceWithFamilyId:self.model.FamilyId productId:self.model.ProductId andDeviceName:self.model.DeviceName success:^(id  _Nonnull responseObject) {
                                STRONG
                                [MBProgressHUD showSuccess:LOCSTR(@"解绑成功")];
                                [[NSNotificationCenter defaultCenter] postNotificationName:DeviceInformation object:nil];
                                [self.navigationController popViewControllerAnimated:YES];
                            } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                                [MBProgressHUD showError:reason];
                                [MethodTool judgeUserSignoutWithReturnToken:dic];
                            }];
                        }
                        
                    }
                }];
            }
                break;
            case 3:
            {//设备信息
                DeviceInfoViewController *vc = [[DeviceInfoViewController alloc]init];
                vc.Response = self.deviceInfoModel;
                PushVC(vc);
            }
                break;
            case 4:
            {//设备初始化
                DeviceInitVC *vc = [[DeviceInitVC alloc]init];
                PushVC(vc);
            }
                break;
            default:
                break;
        }
    });
    
    
    NSMutableArray *dateTherrArray = [NSMutableArray array];
    [dateTherrArray addObject:@{titleKey   : LOCSTR(@"固件升级"),
                           imgNameKey : @"icon_set_8",
                           selectType  : @(0)
                           }];

    NSMutableArray *arrayTherr = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateTherrArray] mutableCopy];
    self.addSection(3).sectionInsets(UIEdgeInsetsMake(10, 0, 0, 0));
    self.addCells(@"SetUpViewCell")
    .toSection(3).withDataModelArray(arrayTherr)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
            case 0:
            {//固件升级
                
                if (![MethodTool isBlankString:self.model.FamilyId]) {
                    WEAK
                    NSDictionary *tmpDic = @{
                        @"ProductId":self.model.ProductId?:@"",
                        @"DeviceName":self.model.DeviceName?:@"",
                        @"RequestId":[[NSUUID UUID] UUIDString]
                    };
                    [[TIoTCoreRequestObject shared] post:@"AppCheckFirmwareUpdate" Param:tmpDic success:^(id responseObject) {
                        STRONG
                        self.Response = responseObject;
                        NSComparisonResult comparingResults = [self.Response[@"CurrentVersion"] compare:self.Response[@"DstVersion"] options:NSCaseInsensitiveSearch];

                        if (comparingResults == NSOrderedAscending) {
                            NSLog(@"升序");//（说明当前版本较低）
            
                            [TLUIUtility showAlertWithTitle:LOCSTR(@"提示") message:[NSString stringWithFormat:@"%@ %@",LOCSTR(@"固件可升级到版本"),self.Response[@"DstVersion"]] cancelButtonTitle:LOCSTR(@"取消") otherButtonTitles:@[@"确定"] actionHandler:^(NSInteger buttonIndex) {
                                
                                if (buttonIndex == 1) {
                                    NSDictionary *tmpDic = @{
                                        @"ProductId":self.model.ProductId?:@"",
                                        @"DeviceName":self.model.DeviceName?:@"",
                                        @"RequestId":[[NSUUID UUID] UUIDString]
                                    };
                                    [[TIoTCoreRequestObject shared] post:@"AppPublishFirmwareUpdateMessage" Param:tmpDic success:^(id responseObject) {
                                        [MBProgressHUD showMessage:LOCSTR(@"升级成功") icon:@""];
                                    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                                        [MBProgressHUD showError:reason];
                                    }];
                                }
                            }];
                        }else {
                            [MBProgressHUD showMessage:LOCSTR(@"已是最高版本") icon:@""];
                        }
                    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                        [MBProgressHUD showError:reason];
                        [MethodTool judgeUserSignoutWithReturnToken:dic];
                    }];
                    
                }
                else{
                    [MBProgressHUD showMessage:LOCSTR(@"用户对该设备无权限") icon:@""];
                }
                
            }
            default:
                break;
        }
    });
}
//查询固件是否需要升级
-(void)getAppCheckFirmwareUpdate{
    WEAK
    NSDictionary *tmpDic = @{
        @"ProductId":self.model.ProductId?:@"",
        @"DeviceName":self.model.DeviceName?:@"",
        @"RequestId":[[NSUUID UUID] UUIDString]
    };
    [[TIoTCoreRequestObject shared] post:@"AppCheckFirmwareUpdate" Param:tmpDic success:^(id responseObject) {
        STRONG
        self.Response = responseObject;
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
//        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];
    }];
}

/*
 {
 CountHistory =     {人流量历史记录
     LastUpdate = 1628474498836;
     Value =         (
                     {
             count = 129;
             timestamp = 1626786570;
         },
                     {
             count = 588;
             timestamp = 1626875366;
         },
                     {
             count = 661;
             timestamp = 1626959150;
         },
                     {
             count = 116;
             timestamp = 1627010673;
         },
                     {
             count = 0;
             timestamp = 0;
         },
                     {
             count = 0;
             timestamp = 0;
         },
                     {
             count = 0;
             timestamp = 0;
         }
     );
 };
 ASense =     {广告场景
     LastUpdate = 1622709897564;
     Value =         (
                     {
             Days = 1111111;
             EndTime = 124;
             Interval = 11;
             Repeat = 2;
             Songs = "music1.mp3|music2.mp3";
             StartTime = 123;
             Status = 1;
         },
                     {
             Days = 1111111;
             EndTime = 124;
             Interval = 11;
             Repeat = 2;
             Songs = "music1.mp3|music2.mp3";
             StartTime = 123;
             Status = 1;
         }
     );
 };
 DAPSense =     {感应播放场景
          LastUpdate = 1622616727511;
           Value =         (
          );
 };
 PSense =     {仅播放场景
          LastUpdate = 1622616727511;
          Value =         (
          );
 };
 Counter =     {//人流量
     LastUpdate = 1624931878336;
     Value = 50;
 };
    DeviceInfo =     {
        LastUpdate = 1621405545506;
        Value =         {设备信息
            FirmwareVersion = "1.0.3";
            Mac = "aa:bb:cc:dd:ee:ff";
            Rssi = 99;
            WifiName = slxk;
        };
    };
    DeviceSense =     {//定时数组
        LastUpdate = 1621405545506;
        Value =         (
        );
    };
    PlayList =     {
        LastUpdate = 1621405545506;
        Value =         {曲目、用户上传歌曲
            Factory = "0_Bt_Reconnect.mp3,1_Wechat.mp3,2_Welcome_To_Wifi.mp3,3_New_Version_Available.mp3,4_Bt_Success.mp3,5_Freetalk.mp3,6_Upgrade_Done.mp3,7_shutdown.mp3,8_Alarm.mp3,9_Wifi_Success.mp3,10_Under_Smartconfig.mp3,11_Out_Of_Power.mp3,12_server_connect.mp3,13_hello.mp3,14_new_message.mp3,15_Please_Retry_Wifi.mp3,16_please_setting_wifi.mp3,17_Welcome_To_Bt.mp3,18_Wifi_Time_Out.mp3,19_Wifi_Reconnect.mp3,20_server_disconnect.mp3";
            User = "music1.mp3,music2.mp3,music3.mp3";
        };
 Value =         (
                 {
         FN = "file1.mp3";
         SN = test;
     },
                 {
         FN = "file2.mp3";
         SN = test2;
     }
 );
    };
    PlayMode =     {播放模式
        LastUpdate = 1621405545506;
        Value = 3;
    };
    Volume =     {音量
        LastUpdate = 1621406961404;
        Value = 70;
    };
    "power_switch" =     {
        LastUpdate = 1621336420126;
        Value = 1;
    };
}
*/
//获取设备数据模型
-(void)getAppGetDeviceData{
    WEAK
    [[TIoTCoreRequestObject shared] post:AppGetDeviceData Param:@{@"ProductId":self.model.ProductId?:@"",@"DeviceName":self.model.DeviceName?:@""} success:^(id responseObject) {
        STRONG
        self.deviceInfoModel = [NSString jsonToObject:responseObject[@"Data"]];
        
        self.volunmeIndexSelect = [self.deviceInfoModel[@"Volume"][@"Value"] integerValue];

        self.volunmeModel = self.arrayOne[1];
        self.volunmeModel.itemSubName = self.volumeArray[[self.deviceInfoModel[@"Volume"][@"Value"] integerValue]];
        
        if ([[self.deviceInfoModel allKeys] containsObject:@"StanbyLED"]) {
            self.DaiJjiModel = self.arrayFour.firstObject;
            if ([self.deviceInfoModel[@"StanbyLED"][@"Value"] integerValue] == 0) {
                self.DaiJjiModel.itemSubName = self.lampSwitchArray.lastObject;
                self.DaiJjindexSelect = 1;

            }else{
                self.DaiJjiModel.itemSubName = self.lampSwitchArray.firstObject;
                self.DaiJjindexSelect = 0;

            }
        }
        if ([[self.deviceInfoModel allKeys] containsObject:@"PlayLED"]) {
            self.PlayModel = self.arrayFour.lastObject;
            if ([self.deviceInfoModel[@"PlayLED"][@"Value"] integerValue] == 0) {
                self.PlayModel.itemSubName = self.lampSwitchArray.lastObject;
                self.PlayIndexSelect = 1;

            }else{
                self.PlayModel.itemSubName = self.lampSwitchArray.firstObject;
                self.PlayIndexSelect = 0;

            }
        }

        NSArray *array = [NSArray yy_modelArrayWithClass:locallyMusicModel.class json:self.deviceInfoModel[@"PlayList"][@"Value"]];
        [UserManageCenter sharedUserManageCenter].devicePlayList = [NSMutableArray arrayWithArray:array];
        
        [UserManageCenter sharedUserManageCenter].DAPSenseList = self.deviceInfoModel[@"DAPSense"][@"Value"];
        [UserManageCenter sharedUserManageCenter].PSenseList = self.deviceInfoModel[@"PSense"][@"Value"];
        [UserManageCenter sharedUserManageCenter].ASenseList = self.deviceInfoModel[@"ASense"][@"Value"];
        [UserManageCenter sharedUserManageCenter].CountHistoryList = self.deviceInfoModel[@"CountHistory"][@"Value"];
        
        [self reloadView];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MethodTool judgeUserSignoutWithReturnToken:dic];
    }];
}

//根据索引取出传入数组的值
-(void)selectIndex:(NSInteger)index title:(NSString *)title devModel:(DeviceViewModel *)model{

    [self selectIndex:index title:title];

}

//设置
-(void)selectIndex:(NSInteger)index title:(NSString *)title{
    
    NSString *value = [NSString new];
    NSMutableDictionary *playDic = [NSMutableDictionary new];

    if ([title isEqualToString:LOCSTR(@"音量设置")])
    {
        value = self.volumeArray[index];
        [playDic setObject:@(index) forKey:@"Volume"];
    }
    else if([title containsString:LOCSTR(@"待机")])
    {
        value = self.lampSwitchArray[index];

        if (index == 0) {
            [playDic setObject:@(1) forKey:@"StanbyLED"];

        }else{
            [playDic setObject:@(0) forKey:@"StanbyLED"];

        }
    }
    else if([title containsString:LOCSTR(@"播放")])
    {
        value = self.lampSwitchArray[index];
        if (index == 0) {
            [playDic setObject:@(1) forKey:@"PlayLED"];

        }else{
            [playDic setObject:@(0) forKey:@"PlayLED"];

        }
    }

    NSDictionary *tmpDic = @{
        @"ProductId":self.model.ProductId?:@"",
        @"DeviceName":self.model.DeviceName?:@"",
        @"Data":[NSString objectToJson:playDic]?:@""};
    WEAK
    [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
        STRONG
        if ([title isEqualToString:LOCSTR(@"音量设置")])
        {
            self.volunmeIndexSelect = index;
            self.volunmeModel.itemSubName = value;
        }
        else if([title containsString:LOCSTR(@"待机")])
        {
            
            self.DaiJjindexSelect = index;
            self.DaiJjiModel.itemSubName = value;
        }
        else if([title containsString:LOCSTR(@"播放")])
        {
            self.PlayIndexSelect = index;
            self.PlayModel.itemSubName = value;
        }
        
        [self reloadView];

        [MBProgressHUD showMessage:LOCSTR(@"设置成功") icon:@""];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];
    }];
}
#pragma mark - set

-(NSArray *)volumeArray{
    if (!_volumeArray) {
        _volumeArray = @[LOCSTR(@"60"),LOCSTR(@"70"),LOCSTR(@"80"),LOCSTR(@"90"),LOCSTR(@"100")];
    }
    return _volumeArray;
}


-(NSArray *)lampSwitchArray{
    if (!_lampSwitchArray) {
        _lampSwitchArray = @[LOCSTR(@"开启"),LOCSTR(@"关闭")];
    }
    return _lampSwitchArray;
}



@end
