//
//  DeviceViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "DeviceViewController.h"
#import "DeviceViewCell.h"
#import "CMPageTitleContentView.h"

#import "TIoTCoreFoundation.h"
#import "TRTCCalling.h"
#import "TIoTCoreUtil.h"
#import "TIoTCoreRequestObject.h"
#import "TIoTCoreAppEnvironment.h"

#import "AddDeviceHomeVC.h"
#import "SetUpViewController.h"
#import "TIoTTRTCUIManage.h"
#import "UIExPickerView.h"

@interface DeviceViewController ()<UITableViewDelegate,UITableViewDataSource,pickerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *deviceList;
@property (nonatomic, strong) NSArray *familyList;
@property (nonatomic, strong) NSArray *roomList;
@property (nonatomic, strong) NSString *currentFamilyId;
@property (nonatomic, strong) NSString *currentRoomId;

@property (nonatomic, copy) NSArray *deviceIds;


@property (nonatomic, strong) CMPageTitleContentView *familyTitlesView;
@property (nonatomic, strong) CMPageTitleContentView *roomTitlesView;

@property (nonatomic, strong) UIButton *addbutton;

@property (nonatomic, assign) NSInteger offset;//设备数据偏移量

@property (nonatomic, strong) NSMutableArray *shareDataArr;
@property (nonatomic, strong) NSMutableArray *shareDevicesArray; //分享设备原始数据拆分后的数组

@property (nonatomic, assign)int state;


 /*
  用于首页列表展示感应模式（暂时隐藏）
  */
@property (nonatomic, strong) NSMutableDictionary *deviceInfoModel;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, assign) BOOL isAllLoadMoreFinished;
@property (nonatomic, strong) UIView *refreshBackView;
@property (nonatomic, strong) UILabel *footer_label;
@property (nonatomic, strong) NSMutableArray *currentArray;

@property (nonatomic, assign)NSInteger selectIndex;//点击了那个cell
@property (nonatomic, assign)NSInteger playModeIndexSelect;//播放模式选中下标
@property (nonatomic, strong)NSArray *playModeArray;

@end

@implementation DeviceViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"设备";
    [self.view addSubview:self.tableView];
    
    /*
     用于首页列表展示感应模式（暂时隐藏）
     */
    UILabel *tips_label = [[UILabel alloc]init];
    tips_label.text = LOCSTR(@"已经到底了");
    tips_label.textAlignment = NSTextAlignmentCenter;
    tips_label.frame = CGRectMake(0, 0, KScreenW, 40);
    tips_label.hidden = YES;
    self.footer_label = tips_label;
    [self.view addSubview:self.refreshBackView];
    self.page = 1;
     

    
    [self setupRefreshView];

    [self getFamilyList];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFamilyList) name:DeviceInformation object:nil];//绑定分享过来的设备
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketConnected) name:socektConnectSucess object:nil];//socket链接成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceReport:) name:reportDevice object:nil];//设备上报信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground) name:appEnterForeground object:nil];//app进入前台
    
    
}

- (void)appEnterForeground {
//    [[TIoTWebSocketManage shared] SRWebSocketOpen];
//    [self getFamilyList];
    //进入前台需要轮训下trtc状态，防止漏接现象//轮训设备状态，查看trtc设备是否要呼叫我
    [[TIoTTRTCUIManage sharedManager] repeatDeviceData:self.deviceList];

}
/*
message:{
    action = DeviceChange;
    params =     {
        DeviceId = "56UED5AJ29/dev0001";
        Payload = "";
        Seq = 1623899762491;
        SubType = Offline;
        Time = "2021-06-17T11:16:02+08:00";
        Topic = "";
        Type = StatusChange;
    };
    push = 1;
}
 */
//收到上报
- (void)deviceReport:(NSNotification *)notification{
    
    NSDictionary *dic = notification.userInfo;
    /*
     {
         clientToken = "dev0002-60886";
         method = report;
         params =     {
             Counter = 113;
             Detect = 1;
         };
     }
     */
    NSDictionary *payloadDic = [NSString base64Decode:dic[@"Payload"]];
    if ([dic.allKeys containsObject:@"SubType"]) {

        for (int i = 0; i < self.deviceList.count; i++) {
            DeviceViewModel *model = self.deviceList[i];
            NSDictionary *paramsDic = payloadDic[@"params"];
            if ([model.DeviceId isEqualToString:dic[@"DeviceId"]]) {
                if ([dic[@"SubType"] isEqualToString:@"Offline"]) {
//                    WCLog(@"message:%@-----%@",dic,payloadDic);

                    model.Online = 0;
                }else if([dic[@"SubType"] isEqualToString:@"Online"]){
//                    WCLog(@"message:%@-----%@",dic,payloadDic);

                    model.Online = 1;
                }
                if ([dic[@"SubType"] isEqualToString:@"Report"] && [paramsDic.allKeys containsObject:@"Counter"]) {
//                    WCLog(@"message:%@-----%@",dic,payloadDic);

                    model.deviceSetInfo[@"Counter"][@"Value"] = paramsDic[@"Counter"];
                }
                [self.deviceList replaceObjectAtIndex:i withObject:model];
                [UIView performWithoutAnimation:^{
                    [self.tableView reloadData];
                }];
                return;
            }
            
        }
    }
    
}
//socket链接成功
-(void)socketConnected{
    [self appEnterForeground];
}


/**  集成刷新控件 */
- (void)setupRefreshView
{
    // 下拉刷新
    WEAK
    self.tableView.mj_header = [TIoTRefreshHeader headerWithRefreshingBlock:^{
        STRONG
        [self getFamilyList];
    }];
    
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
}


#pragma mark - 请求数据

//获取家庭列表
- (void)getFamilyList
{

    WEAK
    [[TIoTCoreFamilySet shared] getFamilyListWithOffset:0 limit:0 success:^(id  _Nonnull responseObject) {
        STRONG
        self.familyList = responseObject[@"FamilyList"];

        if (self.familyList.count > 0) {
//            NSArray *names = [self.familyList valueForKey:@"FamilyName"];
//            [self addViewWithType:1 names:names];
//            {
//                CreateTime = 1618817038;
//                FamilyId = "f_2e6bd3c9824c497588fdce1c5ce48d6f";
//                FamilyName = "mobile_8615919832167";
//                FamilyType = 0;
//                Role = 1;
//                UpdateTime = 1619180983;
//            }
            self.currentFamilyId = self.familyList[0][@"FamilyId"];
            [TIoTCoreUserManage shared].familyId = self.currentFamilyId;
            [self getDeviceList];

            [[NSUserDefaults standardUserDefaults] setValue:self.familyList[0][@"FamilyId"] forKey:@"firstFamilyId"];
        }else{//没有家庭的创建家庭
            NSDictionary *tmpDic = @{
                @"Name":@"我的家",
                @"RequestId":[[NSUUID UUID] UUIDString],
            };
            WEAK
            [[TIoTCoreRequestObject shared] post:AppCreateFamily Param:tmpDic success:^(id responseObject) {
                STRONG
                self.currentFamilyId = responseObject[@"Data"][@"FamilyId"];
                [TIoTCoreUserManage shared].familyId = self.currentFamilyId;
                [self getDeviceList];
            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            }];
        }
        



    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        [MethodTool judgeUserSignoutWithReturnToken:dic];
        [self.tableView.mj_header endRefreshing];
        [self refreshUI];
    }];
    
}

//获取设备列表
- (void)getDeviceList
{
    WEAK
    [[TIoTCoreDeviceSet shared] getDeviceListWithFamilyId:self.currentFamilyId roomId:self.currentRoomId ?: @"" offset:0 limit:0 success:^(id  _Nonnull responseObject) {
        STRONG
        
        NSArray *array = [NSArray yy_modelArrayWithClass:DeviceViewModel.class json:responseObject];
        [self.deviceList removeAllObjects];
        self.deviceList = [NSMutableArray arrayWithArray:array];
        [UserManageCenter sharedUserManageCenter].deviceList = self.deviceList;
        self.deviceIds = [self.deviceList valueForKey:@"DeviceId"];
        if (self.deviceIds && self.deviceIds.count > 0) {
            //监听收到数据变化
            [[TIoTCoreDeviceSet shared] activePushWithDeviceIds:self.deviceIds complete:^(BOOL success, id data) {

            }];
        }
        [self onDeviceInformation];
        
        /*
        NSArray *array = [NSArray yy_modelArrayWithClass:DeviceViewModel.class json:responseObject];
        self.currentArray = [NSMutableArray arrayWithArray:array];
        [self getAppGetDeviceData];
        
        if (self.page < 2) {
            self.deviceList = self.currentArray;
            NSLog(@"------22--%@",self.deviceList);

        } else {
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.deviceList];
            [array addObjectsFromArray:self.currentArray];
            self.deviceList = array;
            self.isAllLoadMoreFinished = (self.currentArray.count == 0);
            NSLog(@"------33--%@",self.deviceList);

        }
        [self refreshUI];
        
        if (!self.deviceList || self.deviceList.count == 0) {
            self.footer_label.hidden = YES;
        } else {
            self.footer_label.hidden = !self.isAllLoadMoreFinished;
        }
         */

    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
        [self refreshUI];
    }];
    
    [self.tableView.mj_header endRefreshing];


}
/*
 用于首页列表展示感应模式（暂时隐藏）
 获取设备数据模型
 */
-(void)getAppGetDeviceData{
    
    if (self.deviceList.count <= 0) {
        [self refreshUI];
    }else{
        WEAK
        // 1. 队列
        dispatch_queue_t q = dispatch_queue_create("bingXing", DISPATCH_QUEUE_CONCURRENT);
        // 2. 同步执行
        for (int i = 0; i < self.deviceList.count; i++) {
            dispatch_sync(q, ^{
                STRONG
                DeviceViewModel *model = self.deviceList[i];
                [[TIoTCoreRequestObject shared] post:AppGetDeviceData Param:@{@"ProductId":model.ProductId?:@"",@"DeviceName":model.DeviceName?:@""} success:^(id responseObject) {
                    STRONG
                    
                    model.deviceSetInfo = [NSString jsonToObject:responseObject[@"Data"]];
                    [self.deviceList replaceObjectAtIndex:i withObject:model];
                    [self refreshUI];
                } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                    [self refreshUI];
                }];
            });
        }
    }

}


//{
//    "UserID":"250921057949585408",
//    "FromUserID":"249555369632731136",
//    "ProductId":"56UED5AJ29",
//    "DeviceName":"dev0001",
//    "DeviceId":"56UED5AJ29/dev0001",
//    "AliasName":"规划局",
//    "IconUrl":"https://main.qcloudimg.com/raw/1c69eb04f93e925436a3ee9d4896068e.png",
//    "IconUrlGrid":"https://main.qcloudimg.com/raw/1c69eb04f93e925436a3ee9d4896068e.png",
//    "GatewayDeviceId":"",
//    "DeviceType":0,
//    "CreateTime":"2021-05-15T14:21:23+08:00"
//}
/*
 
  1.接收分享设备
 */
-(void)onDeviceInformation{
    WEAK
    [[TIoTCoreRequestObject shared] post:AppListUserShareDevices Param:@{@"Offset":@0,@"Limit":@1000000} success:^(id responseObject) {
        STRONG
        NSArray *array = [NSArray yy_modelArrayWithClass:DeviceViewModel.class json:responseObject[@"ShareDevices"]];
        [self.shareDataArr removeAllObjects];
        self.shareDataArr = [NSMutableArray arrayWithArray:array];

        [self updateSharedDeviceStatus];
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [self refreshUI];
    }];
}

//"Response": {
//    "DeviceStatuses": [{
//        "DeviceId": "22F9Y6II7O/light1",
//        "ProductId": "22F9Y6II7O",
//        "DeviceName": "light1",
//        "Online": 0 //0 在线；1：离线
//    }],
//    "RequestId": "req_1"
//}
//}
/*
 
  2.获取分享设备状态
 */
- (void)updateSharedDeviceStatus{
    NSArray *arr = [self.shareDataArr valueForKey:@"DeviceId"];
    if (arr.count > 0) {
        DeviceViewModel *model = self.shareDataArr[0];
        NSDictionary *dic = @{@"ProductId":model.ProductId,@"DeviceIds":arr};
        WEAK
        [[TIoTCoreRequestObject shared] post:AppGetDeviceStatuses Param:dic success:^(id responseObject) {
            NSArray *statusArr = responseObject[@"DeviceStatuses"];
            STRONG
            NSMutableArray *tmpArr = [NSMutableArray array];
            for (DeviceViewModel *tmpDic in self.shareDataArr) {
                
                NSString *deviceId = tmpDic.DeviceId;
                for (NSDictionary *statusDic in statusArr) {
                    if ([deviceId isEqualToString:statusDic[@"DeviceId"]]) {
                        NSString *onLineSing = [NSString stringWithFormat:@"%@",statusDic[@"Online"]?:@""];
                        if (!([NSString isNullOrNilWithObject:onLineSing] || onLineSing.integerValue < 0)) {
                            DeviceViewModel *dic = [DeviceViewModel new];
                            dic = tmpDic;
                            dic.Online = [statusDic[@"Online"] intValue];
                            [tmpArr addObject:dic];
                            [self.deviceList addObject:dic];
                            break;
                        }
                        
                    }
                }

            }

            self.shareDataArr = tmpArr;
            [self getAppGetDeviceData];
            

        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            [self refreshUI];
        }];
    }else{
        [self getAppGetDeviceData];

    }
    
    
    [self appEnterForeground];

}

-(void)refreshUI{
    [self.tableView showDataCount:self.deviceList.count Title:LOCSTR(@"暂无数据呦。。。。。。") image:KImage(@"icon_wushuju")];
    [UIView performWithoutAnimation:^{
        [self.tableView reloadData];
    }];

}
#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WEAK
    DeviceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceViewCell class]) forIndexPath:indexPath];
    cell.isButtonClick = ^(UIButton * _Nonnull button, NSInteger intger) {
        STRONG
        if (intger == 0) {
            //播放 - 用户控制设备
            DeviceViewModel *trtcReport = self.deviceList[indexPath.row];
            NSMutableDictionary *playDic = [NSMutableDictionary new];
            if (button.selected) {
                [playDic setValue:@(1) forKey:@"PlayPause"];
            }else{
                [playDic setValue:@(0) forKey:@"PlayPause"];
            }
            
            NSDictionary *tmpDic = @{
                @"ProductId":trtcReport.ProductId?:@"",
                @"DeviceName":trtcReport.DeviceName?:@"",
                @"Data":[NSString objectToJson:playDic]?:@""};
            
            [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
//                if (button.selected) {
//                    [MBProgressHUD showMessage:LOCSTR(@"开启播放") icon:@""];
//                }else{
                    [MBProgressHUD showMessage:LOCSTR(@"操作成功") icon:@""];
//                }
            } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                [MBProgressHUD showError:reason];
                [MethodTool judgeUserSignoutWithReturnToken:dic];
            }];
        }else if(intger == 1){
            //设置
            SetUpViewController *vc = [[SetUpViewController alloc]init];
            [UserManageCenter sharedUserManageCenter].deviceModel = self.deviceList[indexPath.row];
            PushVC(vc);
        }else if(intger == 2){
            //感应播放切换
            DeviceViewModel *model = self.deviceList[indexPath.row];
            self.selectIndex = indexPath.row;
            self.playModeIndexSelect = [model.deviceSetInfo[@"PlayMode"][@"Value"] integerValue];
            UIExPickerView *pView = [[UIExPickerView alloc ] initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH) titleStr:LOCSTR(@"播放模式设置") indexSelect:self.playModeIndexSelect arr:self.playModeArray devModel:model];
            pView.delegate = self;
            [self.view addSubview:pView];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil  message:LOCSTR(@"设备已离线请检查：\n1.设备是否有电\n2.设备连接的路由器是否正常工作，网络通畅\n3.是否修改了路由器的名称或密码，可以尝试重新连接\n4.设备是否与路由器距离过远、隔墙或有其他遮挡物") preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *b = [UIAlertAction actionWithTitle:LOCSTR(@"知道了") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            
            
            ///设置左对齐
            UILabel *label1 = [alert.view valueForKeyPath:@"_messageLabel"];
            label1.textAlignment = NSTextAlignmentLeft;
            
            [alert addAction:b];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    };

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.deviceList[indexPath.row];
    return cell;
}
//播放模式设置
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    DeviceViewModel *model = self.deviceList[indexPath.row];
//    self.selectIndex = indexPath.row;
//    self.playModeIndexSelect = [model.deviceSetInfo[@"PlayMode"][@"Value"] integerValue];
//    UIExPickerView *pView = [[UIExPickerView alloc ] initWithFrame:CGRectMake(0, self.view.frame.size.height-270, self.view.frame.size.width, 270) titleStr:LOCSTR(@"播放模式设置") indexSelect:self.playModeIndexSelect arr:self.playModeArray devModel:model];
//    pView.delegate = self;
//    [self.view addSubview:pView];
//}
//根据索引取出传入数组的值
-(void)selectIndex:(NSInteger)index title:(NSString *)title devModel:(DeviceViewModel *)model{
    
    model.deviceSetInfo[@"PlayMode"][@"Value"] = @(index);
    NSDictionary *playDic = @{
        @"PlayMode":@(index)?:@""
    };
    NSDictionary *tmpDic = @{
        @"ProductId":model.ProductId?:@"",
        @"DeviceName":model.DeviceName?:@"",
        @"Data":[NSString objectToJson:playDic]?:@""};
    WEAK
    [[TIoTCoreRequestObject shared] post:AppControlDeviceData Param:tmpDic success:^(id responseObject) {
        STRONG
        self.playModeIndexSelect = index;
        [self.deviceList replaceObjectAtIndex:self.selectIndex withObject:model];
        [MBProgressHUD showMessage:LOCSTR(@"设置成功") icon:@""];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.selectIndex inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone];//刷新某一行

    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];
    }];

}
-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
    DeviceViewModel *model = self.deviceList[indexPath.row];
    //删除
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:LOCSTR(@"解绑") handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        WEAK
        [TLUIUtility showAlertWithTitle:[MethodTool isBlankString:model.FamilyId]?LOCSTR(@"确定要解绑分享的设备吗？"):LOCSTR(@"确定要解绑设备吗？") message:LOCSTR(@"解绑后数据无法直接恢复") cancelButtonTitle:LOCSTR(@"取消") otherButtonTitles:@[@"解绑"] actionHandler:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if ([MethodTool isBlankString:model.FamilyId]) {
                    
                    NSDictionary *tmpDic = @{
                        @"ProductId":model.ProductId?:@"",
                        @"DeviceName":model.DeviceName?:@"",
                        @"RequestId":[[NSUUID UUID] UUIDString],
                    };
                    [[TIoTCoreRequestObject shared] post:@"AppRemoveUserShareDevice" Param:tmpDic success:^(id responseObject) {
                        [MBProgressHUD showSuccess:LOCSTR(@"解绑成功")];
                        [self.deviceList removeObjectAtIndex:indexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexPath.row inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone]; //删除某一行,刷新改行下面的行,往前提
                        [UIView performWithoutAnimation:^{
                            [self.tableView reloadData];
                        }];
                        if (self.deviceList.count<=0) {
                            [self refreshUI];
                        }
                    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
                        [MBProgressHUD showError:reason];
                        [MethodTool judgeUserSignoutWithReturnToken:dic];
                    }];
                    
                }else{
                    
                    [[TIoTCoreDeviceSet shared] deleteDeviceWithFamilyId:model.FamilyId productId:model.ProductId andDeviceName:model.DeviceName success:^(id  _Nonnull responseObject) {
                        STRONG
                        [MBProgressHUD showSuccess:LOCSTR(@"解绑成功")];
                        [self.deviceList removeObjectAtIndex:indexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:indexPath.row inSection:0],nil] withRowAnimation:UITableViewRowAnimationNone]; //删除某一行,刷新改行下面的行,往前提
                        [UIView performWithoutAnimation:^{
                            [self.tableView reloadData];
                        }];
                        if (self.deviceList.count<=0) {
                            [self refreshUI];
                        }
                    } failure:^(NSString * _Nullable reason, NSError * _Nullable error,NSDictionary *dic) {
                        [MBProgressHUD showError:reason];
                        [MethodTool judgeUserSignoutWithReturnToken:dic];
                    }];
                }
                
            }
        }];

        completionHandler (YES);
        [self.tableView reloadData];
    }];
    deleteRowAction.image = [UIImage imageNamed:LOCSTR(@"删除")];
    deleteRowAction.backgroundColor = [UIColor redColor];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(27, k_STATUSBAR_HEIGHT, 150, 50)];
    label.font = [UIFont boldSystemFontOfSize:26];
    label.textColor = KColor333333;
    label.text = LOCSTR(@"我的设备");
    [view addSubview:label];
    
    WEAK
    self.addbutton = view
    .addButton(1)
    .image(KImage(@"icon_devAdd"))
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
//添加设备
        AddDeviceHomeVC *vc = [[AddDeviceHomeVC alloc]init];
        PushVC(vc);
        
    })
    .masonry(^(MASConstraintMaker *make){
        make.centerY.mas_equalTo(label);
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    })
    .view;
    

    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60+k_STATUSBAR_HEIGHT;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenW, KScreenH-k_Height_TabBar) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 126;
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.showsHorizontalScrollIndicator=NO;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        /*
         用于首页列表展示感应模式（暂时隐藏）
         
        _tableView.tableFooterView = self.footer_label;
         
        _tableView.sectionFooterHeight = 40;
         */
        [_tableView registerClass:[DeviceViewCell class] forCellReuseIdentifier:NSStringFromClass([DeviceViewCell class])];

    }
    return _tableView;
}
#pragma mark - CMPageTitleContentViewDelegate

- (void)cm_pageTitleContentView:(CMPageTitleContentView *)view clickWithLastIndex:(NSUInteger)LastIndex Index:(NSUInteger)index Repeat:(BOOL)repeat
{
    if (view == self.familyTitlesView) {
        NSLog(@"家庭==%zi",index);
        
        self.currentFamilyId = self.familyList[index][@"FamilyId"];
        self.currentRoomId = nil;
        [self getDeviceList];
    }
    else
    {
        NSLog(@"房间==%zi",index);
        
        if (index > 0) {
            self.currentRoomId = self.roomList[index - 1][@"RoomId"];
        }
        else
        {
            self.currentRoomId = nil;
        }
        
        [self getDeviceList];
    }
}
/*
 用于首页列表展示感应模式（暂时隐藏）
 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
     self.refreshBackView.bottom = -scrollView.contentOffset.y;
    
    if (self.tableView.contentSize.height <= self.tableView.height) {
//        self.isAllLoadMoreFinished = YES;
//        [self.tableView reloadData];
        return;
    }
    if (scrollView.contentSize.height - scrollView.contentOffset.y < 1000) {
        if (!self.isRequesting && !self.isAllLoadMoreFinished) {
            
            @weakify(self);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                @strongify(self);
                self.page = self.page+1;
                [self getDeviceList];
                
            });
        }
    }
}
 */
#pragma mark - setter

- (void)setCurrentFamilyId:(NSString *)currentFamilyId
{
    _currentFamilyId = currentFamilyId;
}

- (NSMutableArray *)shareDevicesArray {
    if (!_shareDevicesArray) {
        _shareDevicesArray = [NSMutableArray new];
    }
    return _shareDevicesArray;
}

- (NSMutableArray *)shareDataArr
{
    if (!_shareDataArr) {
        _shareDataArr = [NSMutableArray array];
    }
    return _shareDataArr;
}
-(NSMutableArray *)deviceList{
    if (!_deviceList) {
        _deviceList = [NSMutableArray new];
    }
    return _deviceList;
}
-(NSArray *)playModeArray{
    if (!_playModeArray) {
        _playModeArray = @[LOCSTR(@"感应播放"),LOCSTR(@"仅感应"),LOCSTR(@"仅播放"),LOCSTR(@"广告播放")];
    }
    return _playModeArray;
}
@end
