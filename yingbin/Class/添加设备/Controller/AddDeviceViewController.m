//
//  AddDeviceViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/23.
//  Copyright © 2021 wq. All rights reserved.
//

#import "AddDeviceViewController.h"
#import "TIoTCoreUtil.h"
#import <CoreLocation/CoreLocation.h>
#import <UIImageView+WebCache.h>
#import "TIoTCoreAddDevice.h"
#import "TIoTCoreRequestObject.h"
#import "NSObject+additions.h"
#import "TIoTCoreRequestAction.h"
#import "GCDAsyncUdpSocket.h"
#import "TIoTCoreUserManage.h"
#import "TIoTConnectStepTipView.h"
#import "AddDeviceWiFiVC.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>


@interface AddDeviceViewController ()<CLLocationManagerDelegate,TIoTCoreAddDeviceDelegate,UITextFieldDelegate>

@property (nonatomic, strong)UIView *bgOneView;
@property (nonatomic, strong)UIView *bgTwoView;
@property (nonatomic, strong)UIView *bgThreeView;
@property (nonatomic, strong)UIView *bgFourView;
@property (nonatomic, strong)UIView *bgfiveView;//错误界面
@property (nonatomic, strong)UITextField *userNameField;
@property (nonatomic, strong)UITextField *passField;
@property (nonatomic, strong)UIButton *passHideButton;
@property (nonatomic, strong)UIButton *lijipeizhibutton;

@property (nonatomic, strong) NSMutableDictionary *wifiInfo;
@property (strong, nonatomic) CLLocationManager *locationManager;
//@property (strong, nonatomic) UILabel *res;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic) NSUInteger sendCount;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic,strong) TIoTCoreSmartConfig *sc;
@property (nonatomic, strong) TIoTCoreSoftAP *softAp;
@property (nonatomic, copy) NSString *networkToken;
@property (nonatomic) NSUInteger sendCount2;
@property (nonatomic, assign) BOOL isTokenbindedStatus;

@property (nonatomic, strong)UITextField *deviceNameField;//设备名称
@property (nonatomic, strong)NSDictionary *deviceDic;//添加成功返回数据

@property (nonatomic, strong) TIoTConnectStepTipView *connectStepTipView;
@property (nonatomic, strong) NSArray *connectStepArray;

@property (strong, nonatomic) GCDAsyncUdpSocket *socket;


@end

@implementation AddDeviceViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //去重
    if (self.sc) {
        [self.sc stopAddDevice];
    }
    if (self.softAp) {
        [self.softAp stopAddDevice];
    }
    onceToken = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"一键配网");
    
    
    [self createOneSubviews];
    [self createTwoSubviews];
    [self createThreeSubviews];
    [self createFourSubviews];
    [self createfiveSubviews];

    self.bgOneView.hidden = NO;
    self.bgTwoView.hidden = YES;
    self.bgThreeView.hidden = YES;
    self.bgFourView.hidden = YES;
    self.bgfiveView.hidden = YES;

    
    [self getWifiInfos];
//    [self getSoftApAndSmartConfigToken];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationwillenterforegound) name:UIApplicationWillEnterForegroundNotification object:nil];

}


- (void)getWifiInfos
{
    float version = [[UIDevice currentDevice].systemVersion floatValue];
    if (version >= 13) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    else
    {
        [self.wifiInfo removeAllObjects];
        [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
        self.userNameField.text = self.wifiInfo[@"name"];
//        self.passField.text = self.wifiInfo[@"bssid"];
    }
}

- (void)applicationwillenterforegound
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self.wifiInfo removeAllObjects];
            [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
            self.userNameField.text = self.wifiInfo[@"name"];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    });
}

#pragma mark -

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (NSMutableDictionary *)wifiInfo{
    if (_wifiInfo == nil) {
        _wifiInfo = [NSMutableDictionary dictionary];
    }
    return _wifiInfo;
}

- (void)connectFaildResult:(NSString *)message {
    TIoTCoreResult *result = [TIoTCoreResult new];
    result.code = 6000;
    result.errMsg = message;
    [self onResult:result];
}

- (void)compareSuccessResult {
    TIoTCoreResult *result = [TIoTCoreResult new];
    result.code = 0;
    [self onResult:result];
}
#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.wifiInfo removeAllObjects];
        [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
        self.userNameField.text = self.wifiInfo[@"name"];
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        [manager requestWhenInUseAuthorization];
    }
    else
    {
        
    }
}

#pragma mark - QCAddDeviceDelegate

/// 可选实现
/// @param result 返回的调用结果
- (void)onResult:(TIoTCoreResult *)result
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD dismissInView:nil];
        if (result.code == 0) {//配网成功

            self.bgOneView.hidden = YES;
            self.bgTwoView.hidden = YES;
            self.bgThreeView.hidden = YES;
            self.bgFourView.hidden = NO;
            self.bgfiveView.hidden = YES;

            self.navigationItem.rightBarButtonItem = self.saveButtonItem;
            [self modifyName:self.deviceNameField.text popView:NO];

        }
        else//配网失败
        {
            //去重
            if (self.sc) {
                [self.sc stopAddDevice];
            }
            onceToken = 0;
            
            [MBProgressHUD showError:LOCSTR(result.errMsg)];
            self.bgOneView.hidden = YES;
            self.bgTwoView.hidden = YES;
            self.bgThreeView.hidden = YES;
            self.bgFourView.hidden = YES;
            self.bgfiveView.hidden = NO;

        }

    });
}
    
#pragma mark SoftAp config
    
- (void)createSoftAPWith:(NSString *)ip {

    NSString *apSsid = self.userNameField.text;
    NSString *apPwd = self.passField.text;
    
    self.softAp = [[TIoTCoreSoftAP alloc]initWithSSID:apSsid PWD:apPwd];
    self.softAp.delegate = self;
    self.softAp.gatewayIpString = ip;
    
    self.softAp.udpFaildBlock = ^{
        
        [self connectFaildResult:[NSString stringWithFormat:@"udp%@",LOCSTR(@"连接失败")]];
        WCLog(@"-----udp 连接失败----");
    };
    [self.softAp startAddDevice];
}

#pragma mark - private mathod
- (void)getSoftApAndSmartConfigToken {
    
    [[TIoTCoreRequestObject shared] post:AppCreateDeviceBindToken Param:@{} success:^(id responseObject) {
        
//        WCLog(@"AppCreateDeviceBindToken----responseObject==%@",responseObject);
        
        if (![NSObject isNullOrNilWithObject:responseObject[@"Token"]]) {
            self.networkToken = responseObject[@"Token"];
            [self tapConfirm];

        }
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MethodTool judgeUserSignoutWithReturnToken:dic];

        WCLog(@"AppCreateDeviceBindToken--reason==%@--error=%@",reason,reason);
    }];
}

                   
#pragma mark TIoTCoreAddDeviceDelegate 代理方法 (与TCSocketDelegate一一对应)
- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    WCLog(@"连接成功");
    
        //设备收到WiFi的ssid/pwd/token，正在上报，此时2秒内，客户端没有收到设备回复，如果重复发送5次，都没有收到回复，则认为配网失败，Wi-Fi 设备有异常
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        //定时器延迟时间
        NSTimeInterval delayTime = 2.0f;
        
        //定时器间隔时间
        NSTimeInterval timeInterval = 2.0f;
        
        //设置开始时间
        dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
        
        dispatch_source_set_timer(self.timer, startDelayTime, timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer, ^{
            
            if (self.sendCount >= 5) {
                dispatch_source_cancel(self.timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self connectFaildResult:@"模组有问题"];
                });
                return ;
            }
            
            NSLog(@"-----Token=%@--",self.networkToken);

            [sock sendData:[NSJSONSerialization dataWithJSONObject:@{@"cmdType":@(0),@"token":self.networkToken,@"region":[TIoTCoreUserManage shared].userRegion} options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
            self.sendCount ++;
        });
        dispatch_resume(self.timer);

}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    WCLog(@"发送成功");
    //手机与设备连接成功,收到设备的udp数据
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectStepTipView.step < 1) {
            self.connectStepTipView.step = 1;
        }
    });
}

- (void)softApuUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    WCLog(@"发送失败 %@", error);
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];
    WCLog(@"嘟嘟嘟 %@",dictionary);
    //手机与设备连接成功,收到设备的udp数据
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectStepTipView.step < 2) {
            self.connectStepTipView.step = 2;
        }
    });
    
    if ([dictionary[@"cmdType"] integerValue] == 2) {
        //设备已经收到WiFi的ssid/psw/token，正在进行连接WiFi并上报，此时客户端根据token 2秒轮询一次（总时长100s）检测设备状态,然后在绑定设备。
        //如果deviceReply返回的是Current_Error，则配网绑定过程中失败，需要退出配网操作;Previous_Error则为上一次配网的出错日志，只需要上报，不影响当此操作。
        if (![NSObject isNullOrNilWithObject:dictionary[@"deviceReply"]])  {
            if ([dictionary[@"deviceReply"] isEqualToString:@"Previous_Error"]) {
                [self checkTokenStateWithCirculationWithDeviceData:dictionary];
            }else {
                //deviceReplay 为 Cuttent_Error
                WCLog(@"soft配网过程中失败，需要重新配网");
                [self connectFaildResult:@"模组有问题"];
            }
            
        }else {
            WCLog(@"dictionary==%@----soft链路设备success",dictionary);
            [self checkTokenStateWithCirculationWithDeviceData:dictionary];
        }
        
    }

}

#pragma mark - token 2秒轮询查看设备状态
- (void)checkTokenStateWithCirculationWithDeviceData:(NSDictionary *)data {
    dispatch_source_cancel(self.timer);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer2, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer2, ^{
          
            if (self.sendCount2 >= 100) {
                dispatch_source_cancel(self.timer2);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self connectFaildResult:@"设备状态查询失败"];
                    WCLog(@"---设备状态查询失败------");
                });
                return ;
            }
            if (self.isTokenbindedStatus == NO) {
                [self getDevideBindTokenStateWithData:data];
            }
            
            self.sendCount2 ++;
        });
        dispatch_resume(self.timer2);

    });
}
//{
//    DeviceName = dev0001;
//    ProductId = 56UED5AJ29;
//    RequestId = "8CDEFCE5-1608-4B4E-8EB8-94F502BC4EA3";
//    State = 2;
//}
static dispatch_once_t onceToken;

#pragma mark - 获取设备绑定token状态
- (void)getDevideBindTokenStateWithData:(NSDictionary *)deviceData {
    
    [[TIoTCoreRequestObject shared] post:AppGetDeviceBindTokenState Param:@{@"Token":self.networkToken} success:^(id responseObject) {
        
        //State:Uint Token 状态，1：初始生产，2：可使用状态
        WCLog(@"AppGetDeviceBindTokenState---responseobject=%@",responseObject);
        self.deviceDic = responseObject;
        if ([responseObject[@"State"] isEqual:@(1)]) {
            self.isTokenbindedStatus = NO;
        }else if ([responseObject[@"State"] isEqual:@(2)]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.connectStepTipView.step < 3) {
                    self.connectStepTipView.step = 3;
                }
            });
            self.isTokenbindedStatus = YES;
            [self releaseAlloc];
            dispatch_once(&onceToken, ^{
                [self bindingDevidesWithData:deviceData];
            });
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        WCLog(@"AppGetDeviceBindTokenState---reason=%@---error=%@",reason,error);
        [MethodTool judgeUserSignoutWithReturnToken:dic];
    }];
}

#pragma mark - 判断token返回后（设备状态为2），绑定设备
- (void)bindingDevidesWithData:(NSDictionary *)deviceData {
    if (![NSObject isNullOrNilWithObject:deviceData[@"productId"]]) {
        NSString *roomId = @"0";
        
        [[TIoTCoreRequestObject shared] post:AppTokenBindDeviceFamily Param:@{@"ProductId":deviceData[@"productId"],@"DeviceName":deviceData[@"deviceName"],@"Token":self.networkToken,@"FamilyId":[TIoTCoreUserManage shared].familyId ? [TIoTCoreUserManage shared].familyId:@"",@"RoomId":roomId} success:^(id responseObject) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.connectStepTipView.step < 4) {
                    self.connectStepTipView.step = 4;
                }
            });
//            {
//                DeviceName = dev0006;
//                ProductId = 56UED5AJ29;
//                RequestId = "BF826B60-BF34-45F8-92FF-F30369E64C87";
//                State = 2;
//            }
            [self releaseAlloc];
            self.deviceNameField.text = self.deviceDic[@"DeviceName"];
            [self compareSuccessResult];
        } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
            
            [self connectFaildResult:@"绑定设备失败"];
            WCLog(@"---11-------绑定设备失败");
            [MethodTool judgeUserSignoutWithReturnToken:dic];
        }];
    }else {
        [self connectFaildResult:@"绑定设备失败"];
        WCLog(@"------绑定设备失败");

    }

}

#pragma mark - 保存-修改设备别名名称
- (void)saveItemClick:(UIBarButtonItem *)btn{
    if ([NSString isNullOrNilWithObject:self.deviceNameField.text] || [NSString isFullSpaceEmpty:self.deviceNameField.text]) {
        [MBProgressHUD showMessage:LOCSTR(@"请输入设备名称") icon:@""];
    }else {
        if ([self.deviceNameField.text isEqualToString:self.deviceDic[@"DeviceName"]]) {
            [self backVC];
        }else{
            if (self.deviceNameField.text.length >20) {
                [MBProgressHUD showError:LOCSTR(@"名称不能超过20个字符")];
            }else {
                [self modifyName:self.deviceNameField.text popView:YES];
            }
        }
        
    }
}
- (void)modifyName:(NSString *)name popView:(BOOL)popbool
{
    WEAK
    [[TIoTCoreRequestObject shared] post:AppUpdateDeviceInFamily Param:@{@"ProductID":self.deviceDic[@"ProductId"],@"DeviceName":self.deviceDic[@"DeviceName"],@"AliasName":name} success:^(id responseObject) {
        STRONG
        [[NSNotificationCenter defaultCenter] postNotificationName:DeviceInformation object:nil];
        if (popbool) {
            [self backVC];
        }
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];
    }];
}
    
    
-(void)backVC{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"DeviceViewController")]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}
#pragma mark - 第一个View
-(void)createOneSubviews{
    self.bgOneView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(-(k_Height_SafetyArea+20));
    })
    .view;
    self.bgOneView.layer.cornerRadius = 9;
//    [self.view sendSubviewToBack:bgOneView];
    
    UILabel *two_l = self.bgOneView
    .addLabel(0)
    .backgroundColor(KColor(240, 241, 242, 1))
    .text(@"2")
    .font(KFont(16))
    .textColor(KColor(138, 142, 148, 1))
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(12.0f);
//        make.right.mas_equalTo(-12);
//        make.top.mas_equalTo(20);
//        make.bottom.mas_equalTo(-(k_Height_SafetyArea+20));
        make.centerX.mas_equalTo(self.bgOneView);
        make.top.mas_equalTo(20);
        make.size.mas_equalTo(30);
    })
    .view;
    two_l.layer.cornerRadius = 15;
    two_l.layer.masksToBounds = YES;
    
    UILabel *line_right = self.bgOneView
    .addLabel(1)
    .backgroundColor(KColor(240, 241, 242, 1))
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(two_l.mas_right).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *three_l = self.bgOneView
    .addLabel(2)
    .backgroundColor(KColor(240, 241, 242, 1))
    .text(@"3")
    .font(KFont(16))
    .textColor(KColor(138, 142, 148, 1))
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_right.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l.layer.cornerRadius = 15;
    three_l.layer.masksToBounds = YES;
    
    UILabel *line_left = self.bgOneView
    .addLabel(3)
    .backgroundColor(KColor(240, 241, 242, 1))
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(two_l.mas_left).mas_offset(-15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *one_l = self.bgOneView
    .addLabel(4)
    .backgroundColor(KThemeColor)
    .text(@"1")
    .font(KFont(16))
    .textColor(UIColor.whiteColor)
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(line_left.mas_left).mas_offset(-15);
        make.size.mas_equalTo(30);
    })
    .view;
    one_l.layer.cornerRadius = 15;
    one_l.layer.masksToBounds = YES;
    
    UILabel *titleLabel = self.bgOneView
    .addLabel(5)
    .text(LOCSTR(@"请按步骤进行操作"))
    .font(KBFont(17))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(one_l.mas_bottom).mas_offset(50);
        make.left.mas_equalTo(15);
    })
    .view;
    
    UILabel *titleTwoLabel = self.bgOneView
    .addLabel(5)
    .text(LOCSTR(@"1、长按迎宾广告机左边的音量键6秒，如下图所示"))
    .font(KFont(13))
    .textColor(KColor666666)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(23);
        make.left.mas_equalTo(15);
    })
    .view;
    UILabel *titleThreeLabel = self.bgOneView
    .addLabel(5)
    .text(LOCSTR(@"2、语音提示进入配网状态"))
    .font(KFont(13))
    .textColor(KColor666666)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleTwoLabel.mas_bottom).mas_offset(18);
        make.left.mas_equalTo(15);
    })
    .view;
    
    UIImageView *imageView = self.bgOneView
    .addImageView(0)
    .image(KImage(@"icon_addtupian"))
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleThreeLabel.mas_bottom).mas_offset(64);
        make.centerX.mas_equalTo(self.bgOneView);
        make.size.mas_equalTo(CGSizeMake(125, 139));
    })
    .view;
    WEAK
    UIButton *button = self.bgOneView
    .addButton(0)
    .title(LOCSTR(@"下一步"))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        self.bgOneView.hidden = YES;
        self.bgTwoView.hidden = NO;
        self.bgThreeView.hidden = YES;
        self.bgFourView.hidden = YES;
        self.bgfiveView.hidden = YES;

    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.bgOneView.mas_bottom).mas_offset(-20);
        make.centerX.mas_equalTo(imageView);
        make.left.mas_offset(23);
        make.right.mas_offset(-23);
        make.height.mas_offset(44);
        
    })
    .view;
    button.layer.cornerRadius = 5;
    

}
#pragma mark - 第二个View
-(void)createTwoSubviews{
    self.bgTwoView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(-(k_Height_SafetyArea+20));
    })
    .view;
    self.bgTwoView.layer.cornerRadius = 9;
    
    UILabel *two_l = self.bgTwoView
    .addLabel(0)
    .backgroundColor(KThemeColor)
    .text(@"2")
    .font(KFont(16))
    .textColor(UIColor.whiteColor)
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgTwoView);
        make.top.mas_equalTo(20);
        make.size.mas_equalTo(30);
    })
    .view;
    two_l.layer.cornerRadius = 15;
    two_l.layer.masksToBounds = YES;
    
    UILabel *line_right = self.bgTwoView
    .addLabel(1)
    .backgroundColor(KColor(240, 241, 242, 1))
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(two_l.mas_right).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *three_l = self.bgTwoView
    .addLabel(2)
    .backgroundColor(KColor(240, 241, 242, 1))
    .text(@"3")
    .font(KFont(16))
    .textColor(KColor(138, 142, 148, 1))
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_right.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l.layer.cornerRadius = 15;
    three_l.layer.masksToBounds = YES;
    
    UILabel *line_left = self.bgTwoView
    .addLabel(3)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(two_l.mas_left).mas_offset(-15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UIImageView *imageView1 = self.bgTwoView
    .addImageView(1)
    .image(KImage(@"icon_gouxuan"))
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(line_left.mas_left).mas_offset(-15);
        make.size.mas_equalTo(30);
    })
    .view;
    
    UILabel *titleLabel = self.bgTwoView
    .addLabel(5)
    .text(LOCSTR(@"设备网络配置"))
    .font(KBFont(17))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView1.mas_bottom).mas_offset(50);
        make.left.mas_equalTo(15);
    })
    .view;
    
    UILabel *titleTwoLabel = self.bgTwoView
    .addLabel(5)
    .text(LOCSTR(@"请确保当前WiFi频段为2.4G，方可配置"))
    .font(KFont(13))
    .textColor(KColor666666)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(23);
        make.left.mas_equalTo(15);
    })
    .view;
    UILabel *titleThreeLabel = self.bgTwoView
    .addLabel(5)
    .text(LOCSTR(@"若当前WiFi频段为5G，"))
    .font(KFont(13))
    .textColor(KColor666666)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleTwoLabel.mas_bottom).mas_offset(18);
        make.left.mas_equalTo(15);
    })
    .view;
    UILabel *titleThreeLabel_H = self.bgTwoView
    .addLabel(5)
    .text(LOCSTR(@"请去设置中心切换2.4G频段"))
    .font(KFont(13))
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleThreeLabel);
        make.left.mas_equalTo(titleThreeLabel.mas_right);
    })
    .view;
    titleThreeLabel_H.textColor = UIColor.redColor;
    
    UILabel *line_top = self.bgTwoView
    .addLabel(5)
    .backgroundColor(KColorE5E5E5)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleThreeLabel.mas_bottom).mas_offset(58);
        make.left.mas_equalTo(23);
        make.right.mas_equalTo(-23);
        make.height.mas_equalTo(0.5);
    })
    .view;
    
    self.userNameField = self.bgTwoView
    .addTextField(7)
    .font(KPingFangFont(15))
    .placeholder(LOCSTR(@"请输入WIFI"))
    .backgroundColor(UIColor.clearColor)
    .textColor(UIColor.blackColor)
    .keyboardType(UIKeyboardTypeDefault)
    .clearButtonMode(UITextFieldViewModeWhileEditing)
    .textAlignment(NSTextAlignmentLeft)
    .delegate(self)
    .masonry(^(MASConstraintMaker *make){
        make.left.right.mas_equalTo(line_top);
        make.top.mas_equalTo(line_top.mas_bottom);
        make.height.mas_equalTo(54);
    })
    .view;
    self.userNameField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIView *userNameLine = self.bgTwoView
    .addView(5)
    .backgroundColor(KColorE5E5E5)
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.userNameField.mas_bottom);
        make.left.right.mas_equalTo(self.userNameField);
        make.height.mas_equalTo(0.5);
    })
    .view;
    
    //创建左侧视图
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_xiaowifi"]];
    UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 60)];//宽度根据需求进行设置，高度必须大于 textField 的高度
    lv.backgroundColor = [UIColor clearColor];
    iv.center = lv.center;
    [lv addSubview:iv];
    self.userNameField.leftViewMode = UITextFieldViewModeAlways;
    self.userNameField.leftView = lv;
    
    UIButton *wifiButton = [[UIButton alloc] init];
    [wifiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 60));
    }];
    wifiButton.backgroundColor = [UIColor clearColor];
    wifiButton.selected = YES;
    [wifiButton setImage:[UIImage imageNamed:@"icon_wifi_sanjiao"] forState:UIControlStateNormal];
    [wifiButton addTarget:self action:@selector(wifiButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.userNameField.rightViewMode = UITextFieldViewModeAlways;
    self.userNameField.rightView = wifiButton;
    
    self.passField = self.bgTwoView
    .addTextField(7)
    .delegate(self)
    .font(KPingFangFont(15))
    .placeholder(LOCSTR(@"请输入密码"))
    .backgroundColor(UIColor.clearColor)
    .textColor(UIColor.blackColor)
    .keyboardType(UIKeyboardTypeDefault)
    .clearButtonMode(UITextFieldViewModeWhileEditing)
    .textAlignment(NSTextAlignmentLeft)
    .secureTextEntry(YES)
    .text([[NSUserDefaults standardUserDefaults] objectForKey:@"WIFIPASSS"])
    .masonry(^(MASConstraintMaker *make){
        make.left.right.mas_equalTo(self.userNameField);
        make.top.mas_equalTo(self.userNameField.mas_bottom);
        make.height.mas_equalTo(54);
    })
    .view;
    self.passField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIView *passNameLine = self.bgTwoView
    .addView(5)
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.passField.mas_bottom);
        make.left.right.mas_equalTo(userNameLine);
        make.height.mas_equalTo(0.5);
    })
    .view;
    passNameLine.backgroundColor =KColorE5E5E5;
    
    UIImageView *ivi = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_xiaosuo"]];
    UIView *lvv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 60)];
    lvv.backgroundColor = [UIColor clearColor];
    ivi.center = lvv.center;
    [lvv addSubview:ivi];
    self.passField.leftViewMode = UITextFieldViewModeAlways;
    self.passField.leftView = lvv;
    
    self.passHideButton = [[UIButton alloc] init];
    [self.passHideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 60));
    }];
    self.passHideButton.backgroundColor = [UIColor clearColor];
    self.passHideButton.selected = YES;
    [self.passHideButton setImage:[UIImage imageNamed:@"icon_pass_no"] forState:UIControlStateSelected];
    [self.passHideButton setImage:[UIImage imageNamed:@"icon_pass_yes"] forState:UIControlStateNormal];
    [self.passHideButton addTarget:self action:@selector(passHideClick:) forControlEvents:UIControlEventTouchUpInside];
    self.passField.rightViewMode = UITextFieldViewModeAlways;
    self.passField.rightView = self.passHideButton;
    
    
    WEAK
    self.lijipeizhibutton = self.bgTwoView
    .addButton(0)
    .title(LOCSTR(@"立即配置"))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        if ([MethodTool isBlankString:self.userNameField.text]) {
            [MBProgressHUD showError:LOCSTR(@"请输入wifi账号")];
            return;
        }if([MethodTool isBlankString:self.passField.text]){
            [MBProgressHUD showError:LOCSTR(@"请输入密码")];
            return;
        }if ([MethodTool isBlankString:self.wifiInfo[@"bssid"]]) {
            [MBProgressHUD showError:LOCSTR(@"未获取到必要参数")];
            return;
        }
                
        self.bgOneView.hidden = YES;
        self.bgTwoView.hidden = YES;
        self.bgThreeView.hidden = NO;
        self.bgFourView.hidden = YES;
        self.bgfiveView.hidden = YES;

        [self getSoftApAndSmartConfigToken];
//        [self tapConfirm];
        
        /*
        self.sc = [[TIoTCoreSmartConfig alloc] initWithSSID:self.userNameField.text PWD:self.passField.text BSSID:self.wifiInfo[@"bssid"]];
        self.sc.delegate = self;
        WEAK
        self.sc.updConnectBlock = ^(NSString * _Nonnull ipaAddrData) {
            STRONG
            [self createSoftAPWith:ipaAddrData];
            
        };
        self.sc.connectFaildBlock = ^{
            STRONG
            [self connectFaildResult:LOCSTR(@"连接失败")];
        };
       //开始配网流程
        [self.sc startAddDevice];
        */
        [[NSUserDefaults standardUserDefaults] setObject:self.passField.text forKey:@"WIFIPASSS"];
        
    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.bgTwoView.mas_bottom).mas_offset(-20);
        make.centerX.mas_equalTo(self.bgTwoView);
        make.left.mas_offset(23);
        make.right.mas_offset(-23);
        make.height.mas_offset(44);
        
    })
    .view;
    self.lijipeizhibutton.layer.cornerRadius = 5;
}

//创建smartConfig
- (void)createSmartConfig {
        
        NSLog(@"--self.userNameField=%@------self.passField=%@-------thone=%@-----bssid=%@",self.userNameField.text,self.passField.text,self.networkToken,self.wifiInfo[@"bssid"]);
    self.sc = [[TIoTCoreSmartConfig alloc] initWithSSID:self.userNameField.text PWD:self.passField.text BSSID:self.wifiInfo[@"bssid"]];
    self.sc.delegate = self;
}
- (void)tapConfirm{

    [self createSmartConfig];
    __weak __typeof(self)weakSelf = self;
    self.sc.updConnectBlock = ^(NSString * _Nonnull ipaAddrData) {
        [weakSelf createSoftAPWith:ipaAddrData];
    };
    self.sc.connectFaildBlock = ^{
        [weakSelf connectFaildResult:LOCSTR(@"连接失败")];
        WCLog(@"------连接失败--");
    };
    [self.sc startAddDevice];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.userNameField) {
        return  NO;
    }
    return YES;
}
#pragma mark - 第三个View
-(void)createThreeSubviews{
    self.bgThreeView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(-(k_Height_SafetyArea+20));
    })
    .view;
    self.bgThreeView.layer.cornerRadius = 9;
    
    UIImageView *two_l = self.bgThreeView
    .addImageView(1)
    .image(KImage(@"icon_gouxuan"))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgTwoView);
        make.top.mas_equalTo(20);
        make.size.mas_equalTo(30);
    })
    .view;
    
    UILabel *line_right = self.bgThreeView
    .addLabel(1)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(two_l.mas_right).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *three_l = self.bgThreeView
    .addLabel(2)
    .backgroundColor(KThemeColor)
    .text(@"3")
    .font(KFont(16))
    .textColor(UIColor.whiteColor)
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_right.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l.layer.cornerRadius = 15;
    three_l.layer.masksToBounds = YES;
    
    UILabel *line_left = self.bgThreeView
    .addLabel(3)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(two_l.mas_left).mas_offset(-15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    

    UIImageView *one_l = self.bgThreeView
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(line_left.mas_left).mas_offset(-15);
        make.size.mas_equalTo(30);
    })
    .view;
    one_l.image = KImage(@"icon_gouxuan");
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"new_distri_connect"];
    [self.bgThreeView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(two_l.mas_bottom).mas_offset(50);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(125);
        make.height.mas_equalTo(151);
    }];
    
    self.connectStepTipView = [[TIoTConnectStepTipView alloc] initWithTitlesArray:self.connectStepArray];
    [self.bgThreeView addSubview:self.connectStepTipView];
    [self.connectStepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).mas_offset(40);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(166);
        make.height.mas_equalTo(114);
    }];
    
    [self performSelector:@selector(clock4Timer:) withObject:@(1) afterDelay:0.5f];

}
- (void)clock4Timer:(NSNumber *)count {
    if (count.intValue > 4) {
        return;
    } else {
        self.connectStepTipView.step = count.intValue;
    }
}

#pragma mark - 第四个View
-(void)createFourSubviews{
    self.bgFourView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(-(k_Height_SafetyArea+20));
    })
    .view;
    self.bgFourView.layer.cornerRadius = 9;
    
    UIImageView *ImagView = self.bgFourView
    .addImageView(5)
    .image(KImage(@"icon_daduihao"))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgFourView);
        make.top.mas_offset(47);
        make.size.mas_equalTo(57);
    })
    .view;
    
    UILabel *wifi_label = self.bgFourView
    .addLabel(10)
    .text(LOCSTR(@"添加成功"))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ImagView);
        make.top.mas_equalTo(ImagView.mas_bottom).mas_offset(36);
    })
    .view;
    wifi_label.font = KFont(18);
    

    UIView *bgVIew = self.bgFourView
    .addView(5)
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ImagView);
        make.top.mas_equalTo(wifi_label.mas_bottom).mas_offset(74);
        make.left.right.mas_offset(0);
        make.height.mas_offset(54);
    })
    .view;
    
    UILabel *line_top = bgVIew
    .addLabel(8)
    .backgroundColor(KColorE5E5E5)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgVIew);
        make.right.mas_offset(-23);
        make.left.mas_offset(23);
        make.height.mas_offset(0.5);
    })
    .view;

    UILabel *title_Name = bgVIew
    .addLabel(10)
    .text(LOCSTR(@"设备名称"))
    .textColor(KColor333333)
    .font(KFont(14))
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bgVIew);
        make.left.mas_offset(23);
    })
    .view;

    UIImageView *title_image = bgVIew
    .addImageView(10)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(title_Name);
        make.right.mas_offset(-23);
        make.size.mas_offset(13);
    })
    .view;
    title_image.image = KImage(@"icon_jiantou");

    //设备名称
    self.deviceNameField = bgVIew
    .addTextField(10)
    .textColor([UIColor grayColor])
    .placeholder(LOCSTR(@"请输入设备名称"))
    .textAlignment(NSTextAlignmentRight)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bgVIew);
        make.right.mas_equalTo(title_image.mas_left).mas_offset(-8);
        make.left.mas_equalTo(title_Name.mas_right).mas_offset(5);
    })
    .view;
    
    UILabel *line_bottom = bgVIew
    .addLabel(8)
    .masonry(^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(bgVIew.mas_bottom).mas_offset(-0.5);
        make.right.left.mas_equalTo(line_top);
        make.height.mas_offset(0.5);
    })
    .view;
    line_bottom.backgroundColor = KColorE5E5E5;
}
#pragma mark - 第五个View（错误页面）
-(void)createfiveSubviews{
    self.bgfiveView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(-(k_Height_SafetyArea+20));
    })
    .view;
    self.bgfiveView.layer.cornerRadius = 9;
    
    UIImageView *ImagView = self.bgfiveView
    .addImageView(5)
    .image(KImage(@"icon_log_error"))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgfiveView);
        make.top.mas_offset(47);
        make.size.mas_equalTo(57);
    })
    .view;
    
    UILabel *wifi_label = self.bgfiveView
    .addLabel(10)
    .text(LOCSTR(@"配网失败"))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ImagView);
        make.top.mas_equalTo(ImagView.mas_bottom).mas_offset(30);
    })
    .view;
    wifi_label.font = KFont(18);
    
    UILabel *label = self.bgfiveView
    .addLabel(1)
    .textColor(KColor999999)
    .numberOfLines(0)
    .font(KFont((14)))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ImagView);
        make.top.mas_equalTo(wifi_label.mas_bottom).mas_offset(40);
    })
    .view;
    label.text = LOCSTR(@"1.确认设备处于一键配网模式（指示灯慢闪）\n\n2.核对家庭WiFi密码是否正确\n\n3.确认路由设备是否为2.4GWiFi频段");
    
    WEAK
    UIButton *button = self.bgfiveView
    .addButton(0)
    .title(LOCSTR(@"重试"))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        
//        //去重
//        if (self.sc) {
//            [self.sc stopAddDevice];
//        }
//        if (self.softAp) {
//            [self.softAp stopAddDevice];
//        }
//        onceToken = 0;
//
//        self.bgOneView.hidden = NO;
//        self.bgTwoView.hidden = YES;
//        self.bgThreeView.hidden = YES;
//        self.bgFourView.hidden = YES;
//        self.bgfiveView.hidden = YES;
        
        [self.navigationController popViewControllerAnimated:YES];

    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.bgfiveView.mas_bottom).mas_offset(-20);
        make.centerX.mas_equalTo(self.bgfiveView);
        make.left.mas_offset(23);
        make.right.mas_offset(-23);
        make.height.mas_offset(44);
        
    })
    .view;
    button.layer.cornerRadius = 5;
    
    UIButton *button1 = self.bgfiveView
    .addButton(0)
    .title(LOCSTR(@"切换到热点配网"))
    .titleColor(KThemeColor)
    .hidden(YES)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        self.bgOneView.hidden = NO;
        self.bgTwoView.hidden = YES;
        self.bgThreeView.hidden = YES;
        self.bgFourView.hidden = YES;
        self.bgfiveView.hidden = YES;
        
        AddDeviceWiFiVC *vc = [AddDeviceWiFiVC new];
        PushVC(vc);
    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.bgfiveView.mas_bottom).mas_offset(-75);
        make.centerX.mas_equalTo(self.bgfiveView);
        make.left.mas_offset(23);
        make.right.mas_offset(-23);
        make.height.mas_offset(44);
        
    })
    .view;
    button1.layer.cornerRadius = 5;
   
}
#pragma mark - 显示与隐藏
-(void)passHideClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        self.passField.secureTextEntry = YES;
    }else{
        self.passField.secureTextEntry = NO;
    }
}

#pragma mark - 点击wifi小箭头 切换手机链接的热点
-(void)wifiButtonClick{
    NSURL *url = [NSURL URLWithString:@"App-prefs:root=WIFI"];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
        
    }
}

-(NSArray *)connectStepArray{
    if (!_connectStepArray) {
        _connectStepArray = @[LOCSTR(@"手机与设备连接成功"), LOCSTR(@"向设备发送信息成功"), LOCSTR(@"设备连接云端成功"), LOCSTR(@"初始化成功")];
    }
    return _connectStepArray;
}

                   
- (void)releaseAlloc{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
    self.timer = nil;
    if (self.timer2) {
        dispatch_source_cancel(self.timer2);
    }
    self.timer2 = nil;

}

- (void)dealloc{
    [self releaseAlloc];
}
                   
-(void)goback{
    WEAK
    if (!self.bgOneView.hidden) {//操作步骤
        [self.navigationController popViewControllerAnimated:YES];
    }else if(!self.bgTwoView.hidden){//输入wifi
        self.bgOneView.hidden = NO;
        self.bgTwoView.hidden = YES;
        self.bgThreeView.hidden = YES;
        self.bgFourView.hidden = YES;
        self.bgfiveView.hidden = YES;
    }else if(!self.bgThreeView.hidden){//配网
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCSTR(@"退出添加设备") message:LOCSTR(@"当前正在添加设备，是否退出？") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"取消") style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            STRONG
            
            self.bgOneView.hidden = YES;
            self.bgTwoView.hidden = NO;
            self.bgThreeView.hidden = YES;
            self.bgFourView.hidden = YES;
            self.bgfiveView.hidden = YES;
            [self releaseAlloc];
            //去重
            if (self.sc) {
                [self.sc stopAddDevice];
            }
            if (self.softAp) {
                [self.softAp stopAddDevice];
            }
            onceToken = 0;
            
        }]];
        
        [self presentViewController:alertController animated:true completion:nil];
        
        
    }else if(!self.bgFourView.hidden){//成功
        [self.navigationController popViewControllerAnimated:YES];
    }else if(!self.bgfiveView.hidden){//错误
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
