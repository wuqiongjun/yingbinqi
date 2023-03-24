//
//  AddDeviceWiFiVC.m
//  yingbin
//
//  Created by slxk on 2021/6/29.
//  Copyright © 2021 wq. All rights reserved.
//

#import "AddDeviceWiFiVC.h"
#import "TIoTConnectStepTipView.h"
#import "TIoTCoreUtil.h"
#import <CoreLocation/CoreLocation.h>
#import <UIImageView+WebCache.h>
#import "TIoTCoreAddDevice.h"
#import "TIoTCoreRequestObject.h"
#import "NSObject+additions.h"
#import "TIoTCoreRequestAction.h"
#import "GCDAsyncUdpSocket.h"
#import "TIoTCoreUserManage.h"
#import <NetworkExtension/NEHotspotConfigurationManager.h>

@interface AddDeviceWiFiVC ()<CLLocationManagerDelegate,TIoTCoreAddDeviceDelegate,UITextFieldDelegate>

@property (nonatomic, strong)UIView *bgOneView;
@property (nonatomic, strong)UIView *bgTwoView;
@property (nonatomic, strong)UIView *bgThreeView;
@property (nonatomic, strong)UIView *bgFourView;
@property (nonatomic, strong)UIView *bgfiveView;
@property (nonatomic, strong)UIView *bgSuccessView;
@property (nonatomic, strong)UIView *bgLoserView;
@property (nonatomic, strong)UITextField *nameField;
@property (nonatomic, strong)UITextField *passField;
@property (nonatomic, strong)UITextField *nameWifiField;
@property (nonatomic, strong)UITextField *passWifiField;
@property (nonatomic, strong)UILabel *titleTwoLabel;
@property (nonatomic, strong)NSMutableDictionary *wifiInfo;

@property (nonatomic, strong)NSMutableDictionary *oneWifiInfo;

//----------------------- soft ap-------------------------
@property (nonatomic, strong) TIoTCoreSoftAP   *softAP;

@property (nonatomic, strong)TIoTConnectStepTipView *connectStepTipView;
@property (nonatomic, strong)NSArray *connectStepArray;
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic, copy) NSString *networkToken;
@property (nonatomic, strong) dispatch_source_t timer2;
@property (nonatomic, strong) dispatch_source_t tokenTimer;
@property (nonatomic) NSUInteger sendTokenCount;
@property (nonatomic) NSUInteger sendCount2;
@property (nonatomic, assign) BOOL isTokenbindedStatus;

@property (nonatomic, strong)UITextField *deviceNameField;//设备名称
@property (nonatomic, strong)NSDictionary *deviceDic;//添加成功返回数据

@end

@implementation AddDeviceWiFiVC

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //去重
    if (self.softAP) {
        [self.softAP stopAddDevice];
    }
    onceToken = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = LOCSTR(@"热点配网");
    [self createOneSubviews];
    [self createTwoSubviews];
    [self createThreeSubviews];
    [self createFourSubviews];
    [self createfiveSubviews];
    [self createLoserView];
    [self createSuccessView];

    self.bgOneView.hidden = NO;
    self.bgTwoView.hidden = YES;
    self.bgThreeView.hidden = YES;
    self.bgFourView.hidden = YES;
    self.bgfiveView.hidden = YES;
    self.bgLoserView.hidden = YES;
    self.bgSuccessView.hidden = YES;
    
    [self getWifiInfos];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationwillenterforegound) name:UIApplicationWillEnterForegroundNotification object:nil];
    
//    [self getSoftApAndSmartConfigToken];

    
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
        self.nameField.text = self.wifiInfo[@"name"];
        self.nameWifiField.text = self.wifiInfo[@"name"];
        [self onWifiName];
    }
}
-(void)onWifiName{
    if ([self.nameField.text containsString:@"zobe"]) {
        self.titleTwoLabel.text = LOCSTR(@"当前手机连接wifi为设备热点wifi，请切换为路由器wifi");
        self.titleTwoLabel.textColor = UIColor.redColor;
    }else{
        self.titleTwoLabel.text = LOCSTR(@"请输入WiFi密码");
        self.titleTwoLabel.textColor = KColor666666;
    }
}
- (void)applicationwillenterforegound
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
            [self.wifiInfo removeAllObjects];
            [self.wifiInfo setDictionary:[TIoTCoreUtil getWifiSsid]];
            self.nameField.text = self.wifiInfo[@"name"];
            self.nameWifiField.text = self.wifiInfo[@"name"];
            
            [self onWifiName];
            
        } else {
            [self.locationManager requestWhenInUseAuthorization];
        }
    });
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
        self.nameField.text = self.wifiInfo[@"name"];
        self.nameWifiField.text = self.wifiInfo[@"name"];
        [self onWifiName];
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
            self.bgFourView.hidden = YES;
            self.bgfiveView.hidden = YES;
            self.bgSuccessView.hidden = NO;
            self.bgLoserView.hidden = YES;

            self.navigationItem.rightBarButtonItem = self.saveButtonItem;
            [self modifyName:self.deviceNameField.text popView:NO];

        }
        else//配网失败
        {
            
            //去重
            if (self.softAP) {
                [self.softAP stopAddDevice];
            }
            onceToken = 0;
            [MBProgressHUD showError:LOCSTR(result.errMsg)];
            self.bgOneView.hidden = YES;
            self.bgTwoView.hidden = YES;
            self.bgThreeView.hidden = YES;
            self.bgFourView.hidden = YES;
            self.bgfiveView.hidden = YES;
            self.bgSuccessView.hidden = YES;
            self.bgLoserView.hidden = NO;
            
        }
        
    });
}
#pragma mark SoftAp config

- (void)createSoftAPWith:(NSString *)ip {

    NSString *apSsid = self.wifiInfo[@"name"];
    NSString *apPwd = @"";
    
    self.softAP = [[TIoTCoreSoftAP alloc] initWithSSID:apSsid PWD:apPwd];
    self.softAP.delegate = self;
    self.softAP.gatewayIpString = ip;
    __weak __typeof(self)weakSelf = self;
    self.softAP.udpFaildBlock = ^{
        [weakSelf connectFaildResult:[NSString stringWithFormat:@"udp%@",LOCSTR(@"连接失败")]];
    };
    [self.softAP startAddDevice];
}

#pragma mark - private mathod
- (void)getSoftApAndSmartConfigToken {
    WEAK
    [[TIoTCoreRequestObject shared] post:AppCreateDeviceBindToken Param:@{} success:^(id responseObject) {
        STRONG
        
        if (![NSObject isNullOrNilWithObject:responseObject[@"Token"]]) {
            self.networkToken = responseObject[@"Token"];
            [self.oneWifiInfo setObject:self.networkToken forKey:@"token"];
        }
        
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MethodTool judgeUserSignoutWithReturnToken:dic];

    }];
}

#pragma mark - TIoTCoreAddDeviceDelegate 代理方法 (与TCSocketDelegate一一对应)

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"连接成功");
    //设备收到WiFi的ssid/pwd/token，正在上报，此时2秒内，客户端没有收到设备回复，如果重复发送5次，都没有收到回复，则认为配网失败，Wi-Fi 设备有异常
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.tokenTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //定时器延迟时间
    NSTimeInterval delayTime = 2.0f;
    
    //定时器间隔时间
    NSTimeInterval timeInterval = 2.0f;
    
    //设置开始时间
    dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
    
    dispatch_source_set_timer(self.tokenTimer, startDelayTime, timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.tokenTimer, ^{
        
        if (self.sendTokenCount >= 5) {
            dispatch_source_cancel(self.tokenTimer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self connectFaildResult:@"模组有问题"];
            });
            return ;
        }
        
        NSString *Ssid = self.oneWifiInfo[@"name"];
        NSString *Pwd = self.oneWifiInfo[@"pwd"];
        NSString *Token = self.oneWifiInfo[@"token"];
        NSDictionary *dic = @{@"cmdType":@(1),@"ssid":Ssid,@"password":Pwd,@"token":Token};
        [sock sendData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] withTimeout:-1 tag:10];
        self.sendTokenCount ++;
    });
    dispatch_resume(self.tokenTimer);

}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"发送成功");
    //手机与设备连接成功,收到设备的udp数据
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectStepTipView.step < 1) {
            self.connectStepTipView.step = 1;
        }
    });
}

- (void)softApuUdpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"发送失败 %@", error);
}

- (void)softApUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSError *JSONParsingError;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&JSONParsingError];
    NSLog(@"嘟嘟嘟 %@",dictionary);
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
                [self connectWiFiCheckTokenStateWithCirculationWithDeviceData:dictionary];

            }else {
                //deviceReplay 为 Cuttent_Error
                NSLog(@"soft配网过程中失败，需要重新配网");
                [self connectFaildResult:@"模组有问题"];
            }
            
        }else {
            NSLog(@"dictionary==%@----soft链路设备success",dictionary);
            [self connectWiFiCheckTokenStateWithCirculationWithDeviceData:dictionary];

        }
        
    }

}
- (void)connectWiFiCheckTokenStateWithCirculationWithDeviceData:(NSDictionary *)data {
    if (@available(iOS 11.0, *)) { //去连接wifi
        NSLog(@"---------------wifiInfo :%@", self.wifiInfo);
        NSString *Ssid = self.wifiInfo[@"name"];
        NSString *Pwd = self.wifiInfo[@"pwd"];
        NEHotspotConfiguration * configuration = [[NEHotspotConfiguration alloc] initWithSSID:Ssid passphrase:Pwd isWEP:NO];
        
        [[NEHotspotConfigurationManager sharedManager] applyConfiguration:configuration completionHandler:^(NSError * _Nullable error) {
            if (nil == error) {
                NSLog(@">=iOS 11 Connected!!");
            } else {
                NSLog (@">=iOS 11 connect WiFi Error :%@", error);
            }
        }];
    }
    
        [self checkTokenStateWithCirculationWithDeviceData:data];
}
#pragma mark - token 2秒轮询查看设备状态
- (void)checkTokenStateWithCirculationWithDeviceData:(NSDictionary *)data {
    if (self.tokenTimer) {
        dispatch_source_cancel(self.tokenTimer);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer2, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer2, ^{
          
            if (self.sendCount2 >= 100) {
                dispatch_source_cancel(self.timer2);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self connectFaildResult:@"模组有问题"];
                    NSLog(@"---模组有问题------");
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
    WEAK
    [[TIoTCoreRequestObject shared] post:AppGetDeviceBindTokenState Param:@{@"Token":self.networkToken} success:^(id responseObject) {
        STRONG
        //State:Uint Token 状态，1：初始生产，2：可使用状态
        NSLog(@"AppGetDeviceBindTokenState---responseobject=%@",responseObject);
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
        NSLog(@"AppGetDeviceBindTokenState---reason=%@---error=%@",reason,error);
        [MethodTool judgeUserSignoutWithReturnToken:dic];
    }];
}

#pragma mark - 判断token返回后（设备状态为2），绑定设备
- (void)bindingDevidesWithData:(NSDictionary *)deviceData {
    if (![NSObject isNullOrNilWithObject:deviceData[@"productId"]]) {
        NSString *roomId = @"0";
        WEAK
        [[TIoTCoreRequestObject shared] post:AppTokenBindDeviceFamily Param:@{@"ProductId":deviceData[@"productId"],@"DeviceName":deviceData[@"deviceName"],@"Token":self.networkToken,@"FamilyId":[TIoTCoreUserManage shared].familyId ? [TIoTCoreUserManage shared].familyId:@"",@"RoomId":roomId} success:^(id responseObject) {
            STRONG
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
            STRONG
            [self connectFaildResult:@"绑定设备失败"];
            NSLog(@"---11-------绑定设备失败");
            [MethodTool judgeUserSignoutWithReturnToken:dic];
        }];
    }else {
        [self connectFaildResult:@"绑定设备失败"];
        NSLog(@"------绑定设备失败");

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

#pragma mark - 第一个View - 长按6s
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
    
    UILabel *line_centre = self.bgOneView
    .addLabel(1)
    .backgroundColor(KColor(240, 241, 242, 1))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgOneView);
        make.top.mas_equalTo(35);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *two_l = self.bgOneView
    .addLabel(0)
    .backgroundColor(KColor(240, 241, 242, 1))
    .text(@"2")
    .font(KFont(16))
    .textColor(KColor(138, 142, 148, 1))
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(line_centre.mas_left).mas_offset(-15);
        make.centerY.mas_equalTo(line_centre);
        make.size.mas_equalTo(30);
    })
    .view;
    two_l.layer.cornerRadius = 15;
    two_l.layer.masksToBounds = YES;
    
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
    
    
    UILabel *three_l = self.bgOneView
    .addLabel(2)
    .backgroundColor(KColor(240, 241, 242, 1))
    .text(@"3")
    .font(KFont(16))
    .textColor(KColor(138, 142, 148, 1))
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_centre.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l.layer.cornerRadius = 15;
    three_l.layer.masksToBounds = YES;
    
    UILabel *line_right_four = self.bgOneView
    .addLabel(1)
    .backgroundColor(KColor(240, 241, 242, 1))
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(line_centre);
        make.left.mas_equalTo(three_l.mas_right).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *three_l_four = self.bgOneView
    .addLabel(2)
    .backgroundColor(KColor(240, 241, 242, 1))
    .text(@"4")
    .font(KFont(16))
    .textColor(KColor(138, 142, 148, 1))
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_right_four.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l_four.layer.cornerRadius = 15;
    three_l_four.layer.masksToBounds = YES;
    
    UILabel *titleLabel = self.bgOneView
    .addLabel(5)
    .text(LOCSTR(@"将设备设置为热点配网模式"))
    .font(KBFont(17))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(one_l.mas_bottom).mas_offset(50);
        make.left.mas_equalTo(15);
    })
    .view;
    
    UILabel *titleTwoLabel = self.bgOneView
    .addLabel(5)
    .text(LOCSTR(@"1、 接通设备电源。\n\n2、 长按右边的音乐键（如下图所示），切换设备配网模式到 热点配网，（不同设备操作方式有所不同）。\n\n3、语音提示进入配网状态。"))
    .font(KFont(13))
    .textColor(KColor666666)
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(23);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    })
    .view;
//    UILabel *titleThreeLabel = self.bgOneView
//    .addLabel(5)
//    .text(LOCSTR(@"2、语音提示进入配网状态"))
//    .font(KFont(12))
//    .textColor(KColor666666)
//    .masonry(^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(titleTwoLabel.mas_bottom).mas_offset(18);
//        make.left.mas_equalTo(15);
//    })
//    .view;
    
    UIImageView *imageView = self.bgOneView
    .addImageView(0)
    .image(KImage(@"icon_addtupianWIFI"))
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleTwoLabel.mas_bottom).mas_offset(40);
        make.centerX.mas_equalTo(self.bgOneView);
        make.size.mas_equalTo(CGSizeMake(149, 184));
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
        self.bgLoserView.hidden = YES;
        self.bgSuccessView.hidden = YES;

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

#pragma mark - 第二个View - 输入wifi
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
    
    UILabel *line_centre = self.bgTwoView
    .addLabel(1)
    .backgroundColor(KColor(240, 241, 242, 1))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgTwoView);
        make.top.mas_equalTo(35);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *two_l = self.bgTwoView
    .addLabel(0)
    .backgroundColor(KThemeColor)
    .text(@"2")
    .font(KFont(16))
    .textColor(UIColor.whiteColor)
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(line_centre.mas_left).mas_offset(-15);
        make.centerY.mas_equalTo(line_centre);
        make.size.mas_equalTo(30);
    })
    .view;
    two_l.layer.cornerRadius = 15;
    two_l.layer.masksToBounds = YES;
    
    UILabel *line_left = self.bgTwoView
    .addLabel(3)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(two_l.mas_left).mas_offset(-15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
//    UILabel *one_l = self.bgTwoView
//    .addLabel(4)
//    .backgroundColor(KThemeColor)
//    .text(@"1")
//    .font(KFont(16))
//    .textColor(UIColor.whiteColor)
//    .textAlignment(1)
//    .masonry(^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(two_l);
//        make.right.mas_equalTo(line_left.mas_left).mas_offset(-15);
//        make.size.mas_equalTo(30);
//    })
//    .view;
//    one_l.layer.cornerRadius = 15;
//    one_l.layer.masksToBounds = YES;
    UIImageView *imageView1 = self.bgTwoView
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(line_left.mas_left).mas_offset(-15);
        make.size.mas_equalTo(30);
    })
    .view;
    imageView1.image = KImage(@"icon_gouxuan");
    
    UILabel *three_l = self.bgTwoView
    .addLabel(2)
    .backgroundColor(KColor(240, 241, 242, 1))
    .text(@"3")
    .font(KFont(16))
    .textColor(KColor(138, 142, 148, 1))
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_centre.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l.layer.cornerRadius = 15;
    three_l.layer.masksToBounds = YES;
    
    UILabel *line_right_four = self.bgTwoView
    .addLabel(1)
    .backgroundColor(KColor(240, 241, 242, 1))
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(line_centre);
        make.left.mas_equalTo(three_l.mas_right).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *three_l_four = self.bgTwoView
    .addLabel(2)
    .backgroundColor(KColor(240, 241, 242, 1))
    .text(@"4")
    .font(KFont(16))
    .textColor(KColor(138, 142, 148, 1))
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_right_four.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l_four.layer.cornerRadius = 15;
    three_l_four.layer.masksToBounds = YES;
    
    UILabel *titleLabel = self.bgTwoView
    .addLabel(5)
    .text(LOCSTR(@"设置目标WiFi"))
    .font(KBFont(17))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(three_l_four.mas_bottom).mas_offset(50);
        make.left.mas_equalTo(15);
    })
    .view;
    
    UILabel *titleTwoLabel = self.bgTwoView
    .addLabel(5)
    .text(LOCSTR(@"请输入WiFi密码"))
    .font(KFont(12))
    .textColor(KColor666666)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(23);
        make.left.mas_equalTo(15);
    })
    .view;
    self.titleTwoLabel = titleTwoLabel;
    /*
    UILabel *titleTwoLabel = self.bgTwoView
    .addLabel(5)
    .text(LOCSTR(@"请确保当前WiFi频段为2G/4G，方可配置"))
    .font(KFont(12))
    .textColor(KColor666666)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(23);
        make.left.mas_equalTo(15);
    })
    .view;
    UILabel *titleThreeLabel = self.bgTwoView
    .addLabel(5)
    .text(LOCSTR(@"若当前WiFi频段为5G，"))
    .font(KFont(12))
    .textColor(KColor666666)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleTwoLabel.mas_bottom).mas_offset(18);
        make.left.mas_equalTo(15);
    })
    .view;
    UILabel *titleThreeLabel_H = self.bgTwoView
    .addLabel(5)
    .text(LOCSTR(@"请去设置中心切换2G、4G频段"))
    .font(KFont(12))
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleThreeLabel);
        make.left.mas_equalTo(titleThreeLabel.mas_right);
    })
    .view;
    titleThreeLabel_H.textColor = UIColor.redColor;
    */
    UILabel *line_top = self.bgTwoView
    .addLabel(5)
    .backgroundColor(KColorE5E5E5)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleTwoLabel.mas_bottom).mas_offset(60);
        make.left.mas_equalTo(23);
        make.right.mas_equalTo(-23);
        make.height.mas_equalTo(0.5);
    })
    .view;
    
    self.nameField = self.bgTwoView
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
    self.nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIView *userNameLine = self.bgTwoView
    .addView(5)
    .backgroundColor(KColorE5E5E5)
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.nameField.mas_bottom);
        make.left.right.mas_equalTo(self.nameField);
        make.height.mas_equalTo(0.5);
    })
    .view;
    
    //创建左侧视图
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_xiaowifi"]];
    UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 60)];//宽度根据需求进行设置，高度必须大于 textField 的高度
    lv.backgroundColor = [UIColor clearColor];
    iv.center = lv.center;
    [lv addSubview:iv];
    self.nameField.leftViewMode = UITextFieldViewModeAlways;
    self.nameField.leftView = lv;
    
    UIButton *wifiButton = [[UIButton alloc] init];
    [wifiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 60));
    }];
    wifiButton.backgroundColor = [UIColor clearColor];
    wifiButton.selected = YES;
    [wifiButton setImage:[UIImage imageNamed:@"icon_wifi_sanjiao"] forState:UIControlStateNormal];
    [wifiButton addTarget:self action:@selector(wifiButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.nameField.rightViewMode = UITextFieldViewModeAlways;
    self.nameField.rightView = wifiButton;
    
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
    .text([[NSUserDefaults standardUserDefaults] objectForKey:@"DEVWIFIPASSS"])
    .masonry(^(MASConstraintMaker *make){
        make.left.right.mas_equalTo(self.nameField);
        make.top.mas_equalTo(self.nameField.mas_bottom);
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
    
    UIButton *passHideButton = [[UIButton alloc] init];
    [passHideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 60));
    }];
    passHideButton.backgroundColor = [UIColor clearColor];
    passHideButton.selected = YES;
    [passHideButton setImage:[UIImage imageNamed:@"icon_pass_no"] forState:UIControlStateSelected];
    [passHideButton setImage:[UIImage imageNamed:@"icon_pass_yes"] forState:UIControlStateNormal];
    [passHideButton addTarget:self action:@selector(passHideClick:) forControlEvents:UIControlEventTouchUpInside];
    self.passField.rightViewMode = UITextFieldViewModeAlways;
    self.passField.rightView = passHideButton;
    
    
    WEAK
    UIButton *nextBtn = self.bgTwoView
    .addButton(0)
    .title(LOCSTR(@"下一步"))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        
        if([MethodTool isBlankString:self.passField.text]){
            [MBProgressHUD showError:LOCSTR(@"请输入密码")];
            return;
        }
        if ([MethodTool isBlankString:self.nameField.text]) {
            [MBProgressHUD showError:LOCSTR(@"请输入wifi账号")];
            return;
        }
        if ([self.nameField.text containsString:@"zobe"]) {
            [MBProgressHUD showError:LOCSTR(@"当前手机连接wifi为设备热点wifi，\n请切换为路由器wifi")];
            return;
        }
        
        self.bgOneView.hidden = YES;
        self.bgTwoView.hidden = YES;
        self.bgThreeView.hidden = NO;
        self.bgFourView.hidden = YES;
        self.bgfiveView.hidden = YES;
        self.bgLoserView.hidden = YES;
        self.bgSuccessView.hidden = YES;
        
        [self.oneWifiInfo removeAllObjects];
        [self.oneWifiInfo setObject:self.nameField.text forKey:@"name"];
        [self.oneWifiInfo setObject:self.passField.text forKey:@"pwd"];
        [self.oneWifiInfo setObject:self.wifiInfo[@"bssid"] forKey:@"bssid"];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.passField.text forKey:@"DEVWIFIPASSS"];

        
    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.bgTwoView.mas_bottom).mas_offset(-20);
        make.centerX.mas_equalTo(self.bgTwoView);
        make.left.mas_offset(23);
        make.right.mas_offset(-23);
        make.height.mas_offset(44);
        
    })
    .view;
    nextBtn.layer.cornerRadius = 5;
}

#pragma mark - 第三个View - 提示切换wifi
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
    
    UILabel *line_centre = self.bgThreeView
    .addLabel(1)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgThreeView);
        make.top.mas_equalTo(35);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
//    UILabel *two_l = self.bgThreeView
//    .addLabel(0)
//    .backgroundColor(KThemeColor)
//    .text(@"2")
//    .font(KFont(16))
//    .textColor(UIColor.whiteColor)
//    .textAlignment(1)
//    .masonry(^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(line_centre.mas_left).mas_offset(-15);
//        make.centerY.mas_equalTo(line_centre);
//        make.size.mas_equalTo(30);
//    })
//    .view;
//    two_l.layer.cornerRadius = 15;
//    two_l.layer.masksToBounds = YES;
    
    UIImageView *two_l = self.bgThreeView
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(line_centre.mas_left).mas_offset(-15);
        make.centerY.mas_equalTo(line_centre);
        make.size.mas_equalTo(30);
    })
    .view;
    two_l.image = KImage(@"icon_gouxuan");
    
    UILabel *line_left = self.bgThreeView
    .addLabel(3)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(two_l.mas_left).mas_offset(-15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
//    UILabel *one_l = self.bgThreeView
//    .addLabel(4)
//    .backgroundColor(KThemeColor)
//    .text(@"1")
//    .font(KFont(16))
//    .textColor(UIColor.whiteColor)
//    .textAlignment(1)
//    .masonry(^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(two_l);
//        make.right.mas_equalTo(line_left.mas_left).mas_offset(-15);
//        make.size.mas_equalTo(30);
//    })
//    .view;
//    one_l.layer.cornerRadius = 15;
//    one_l.layer.masksToBounds = YES;
    
    UIImageView *one_l = self.bgThreeView
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(line_left.mas_left).mas_offset(-15);
        make.size.mas_equalTo(30);
    })
    .view;
    one_l.image = KImage(@"icon_gouxuan");
    
    
    UILabel *three_l = self.bgThreeView
    .addLabel(2)
    .backgroundColor(KThemeColor)
    .text(@"3")
    .font(KFont(16))
    .textColor(UIColor.whiteColor)
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_centre.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l.layer.cornerRadius = 15;
    three_l.layer.masksToBounds = YES;
    
    UILabel *line_right_four = self.bgThreeView
    .addLabel(1)
    .backgroundColor(KColor(240, 241, 242, 1))
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(line_centre);
        make.left.mas_equalTo(three_l.mas_right).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *three_l_four = self.bgThreeView
    .addLabel(2)
    .backgroundColor(KColor(240, 241, 242, 1))
    .text(@"4")
    .font(KFont(16))
    .textColor(KColor(138, 142, 148, 1))
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_right_four.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l_four.layer.cornerRadius = 15;
    three_l_four.layer.masksToBounds = YES;
    
    UILabel *titleLabel = self.bgThreeView
    .addLabel(5)
    .text(LOCSTR(@"将手机WIFI连接设备热点"))
    .font(KBFont(17))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(three_l_four.mas_bottom).mas_offset(50);
        make.left.mas_equalTo(15);
    })
    .view;
    
    UILabel *titleTwoLabel = self.bgThreeView
    .addLabel(5)
    .text(LOCSTR(@"请前往手机WiFi设置界面，连接下图片所示设备WiFi"))
    .font(KFont(13))
    .textColor(KColor666666)
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(23);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    })
    .view;

    UIImageView *imageView = self.bgThreeView
    .addImageView(0)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleTwoLabel.mas_bottom).mas_offset(30);
        make.centerX.mas_equalTo(self.bgThreeView);
        make.size.mas_equalTo(CGSizeMake(300, 250));
    })
    .view;
    imageView.image = KImage(@"icon_wifieg");

    WEAK
    UIButton *nextBtn = self.bgThreeView
    .addButton(0)
    .title(LOCSTR(@"下一步"))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        self.bgOneView.hidden = YES;
        self.bgTwoView.hidden = YES;
        self.bgThreeView.hidden = YES;
        self.bgFourView.hidden = NO;
        self.bgfiveView.hidden = YES;
        self.bgLoserView.hidden = YES;
        self.bgSuccessView.hidden = YES;
        
        [self getSoftApAndSmartConfigToken];

    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.bgThreeView.mas_bottom).mas_offset(-20);
        make.centerX.mas_equalTo(self.bgThreeView);
        make.left.mas_offset(23);
        make.right.mas_offset(-23);
        make.height.mas_offset(44);
        
    })
    .view;
    nextBtn.layer.cornerRadius = 5;
}

#pragma mark - 第四个View - 输入连接热点
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
    
    UILabel *line_centre = self.bgFourView
    .addLabel(1)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgFourView);
        make.top.mas_equalTo(35);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
//    UILabel *two_l = self.bgFourView
//    .addLabel(0)
//    .backgroundColor(KThemeColor)
//    .text(@"2")
//    .font(KFont(16))
//    .textColor(UIColor.whiteColor)
//    .textAlignment(1)
//    .masonry(^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(line_centre.mas_left).mas_offset(-15);
//        make.centerY.mas_equalTo(line_centre);
//        make.size.mas_equalTo(30);
//    })
//    .view;
//    two_l.layer.cornerRadius = 15;
//    two_l.layer.masksToBounds = YES;
    UIImageView *two_l = self.bgFourView
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(line_centre.mas_left).mas_offset(-15);
        make.centerY.mas_equalTo(line_centre);
        make.size.mas_equalTo(30);
    })
    .view;
    two_l.image = KImage(@"icon_gouxuan");
    
    UILabel *line_left = self.bgFourView
    .addLabel(3)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(two_l.mas_left).mas_offset(-15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
//    UILabel *one_l = self.bgFourView
//    .addLabel(4)
//    .backgroundColor(KThemeColor)
//    .text(@"1")
//    .font(KFont(16))
//    .textColor(UIColor.whiteColor)
//    .textAlignment(1)
//    .masonry(^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(two_l);
//        make.right.mas_equalTo(line_left.mas_left).mas_offset(-15);
//        make.size.mas_equalTo(30);
//    })
//    .view;
//    one_l.layer.cornerRadius = 15;
//    one_l.layer.masksToBounds = YES;
    UIImageView *one_l = self.bgFourView
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(line_left.mas_left).mas_offset(-15);
        make.size.mas_equalTo(30);
    })
    .view;
    one_l.image = KImage(@"icon_gouxuan");
    
    
//    UILabel *three_l = self.bgFourView
//    .addLabel(2)
//    .backgroundColor(KThemeColor)
//    .text(@"3")
//    .font(KFont(16))
//    .textColor(UIColor.whiteColor)
//    .textAlignment(1)
//    .masonry(^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(two_l);
//        make.left.mas_equalTo(line_centre.mas_right).mas_offset(15);
//        make.size.mas_equalTo(30);
//    })
//    .view;
//    three_l.layer.cornerRadius = 15;
//    three_l.layer.masksToBounds = YES;
    UIImageView *three_l = self.bgFourView
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_centre.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l.image = KImage(@"icon_gouxuan");
    
    
    UILabel *line_right_four = self.bgFourView
    .addLabel(1)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(line_centre);
        make.left.mas_equalTo(three_l.mas_right).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
//    UILabel *line_right_four_1 = self.bgFourView
//    .addLabel(1)
//    .backgroundColor(KColor(240, 241, 242, 1))
//    .masonry(^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(line_centre);
//        make.left.mas_equalTo(line_right_four.mas_right);
//        make.size.mas_equalTo(CGSizeMake(17, 1));
//    })
//    .view;
    
    UILabel *three_l_four = self.bgFourView
    .addLabel(2)
    .backgroundColor(KThemeColor)
    .text(@"4")
    .font(KFont(16))
    .textColor(UIColor.whiteColor)
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_right_four.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l_four.layer.cornerRadius = 15;
    three_l_four.layer.masksToBounds = YES;
    
    UILabel *titleLabel = self.bgFourView
    .addLabel(5)
    .text(LOCSTR(@"将手机WIFI连接设备热点"))
    .font(KBFont(17))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(three_l_four.mas_bottom).mas_offset(50);
        make.left.mas_equalTo(15);
    })
    .view;
    
//    UILabel *titletwoLabel = self.bgFourView
//    .addLabel(5)
//    .text(LOCSTR(@"操作方式"))
//    .font(KBFont(15))
//    .textColor(KColor333333)
//    .masonry(^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(10);
//        make.left.mas_equalTo(15);
//    })
//    .view;
    
    UILabel *titleTwoLabel = self.bgFourView
    .addLabel(5)
    .text(LOCSTR(@"1.点击WiFi名称右侧的下拉按钮，前往手机WiFi设置界面选择zobe_xxx设备热点后，返回APP"))
    .font(KFont(13))
    .textColor(KColor666666)
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(20);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    })
    .view;
    UILabel *titleThreeLabel = self.bgFourView
    .addLabel(5)
    .text(LOCSTR(@"2.点击立即配置，开始配网。"))
    .font(KFont(13))
    .textColor(KColor666666)
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleTwoLabel.mas_bottom).mas_offset(18);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    })
    .view;
//    UILabel *titleThreeLabel_H = self.bgFourView
//    .addLabel(5)
//    .text(LOCSTR(@"3、填写设备密码，若设备热点无密码则无需填写。"))
//    .font(KFont(13))
//    .textColor(KColor666666)
//    .masonry(^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(titleThreeLabel.mas_bottom).mas_offset(18);
//        make.left.mas_equalTo(titleThreeLabel);
//    })
//    .view;
    
    UILabel *line_top = self.bgFourView
    .addLabel(5)
    .backgroundColor(KColorE5E5E5)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleThreeLabel.mas_bottom).mas_offset(50);
        make.left.mas_equalTo(23);
        make.right.mas_equalTo(-23);
        make.height.mas_equalTo(0.5);
    })
    .view;
    
    self.nameWifiField = self.bgFourView
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
    self.nameWifiField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIView *userNameLine = self.bgFourView
    .addView(5)
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.nameWifiField.mas_bottom);
        make.left.right.mas_equalTo(self.nameWifiField);
        make.height.mas_equalTo(0.5);
    })
    .view;
    userNameLine.backgroundColor = KColorE5E5E5;
    
    //创建左侧视图
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_xiaowifi"]];
    UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 60)];//宽度根据需求进行设置，高度必须大于 textField 的高度
    lv.backgroundColor = [UIColor clearColor];
    iv.center = lv.center;
    [lv addSubview:iv];
    self.nameWifiField.leftViewMode = UITextFieldViewModeAlways;
    self.nameWifiField.leftView = lv;
    
    UIButton *wifiButton = [[UIButton alloc] init];
    [wifiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 60));
    }];
    wifiButton.backgroundColor = [UIColor clearColor];
    wifiButton.selected = YES;
    [wifiButton setImage:[UIImage imageNamed:@"icon_wifi_sanjiao"] forState:UIControlStateNormal];
    [wifiButton addTarget:self action:@selector(wifiButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.nameWifiField.rightViewMode = UITextFieldViewModeAlways;
    self.nameWifiField.rightView = wifiButton;
    
    /*
    self.passWifiField = self.bgFourView
    .addTextField(7)
    .delegate(self)
    .font(KPingFangFont(15))
    .placeholder(LOCSTR(@"请输入密码(非必填)"))
    .backgroundColor(UIColor.clearColor)
    .textColor(UIColor.blackColor)
    .keyboardType(UIKeyboardTypeDefault)
    .clearButtonMode(UITextFieldViewModeWhileEditing)
    .textAlignment(NSTextAlignmentLeft)
    .secureTextEntry(YES)
    .masonry(^(MASConstraintMaker *make){
        make.left.right.mas_equalTo(self.nameWifiField);
        make.top.mas_equalTo(self.nameWifiField.mas_bottom);
        make.height.mas_equalTo(54);
    })
    .view;
    self.passWifiField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIView *passNameLine = self.bgFourView
    .addView(5)
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.passWifiField.mas_bottom);
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
    self.passWifiField.leftViewMode = UITextFieldViewModeAlways;
    self.passWifiField.leftView = lvv;
    
    UIButton *passHideButton = [[UIButton alloc] init];
    [passHideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 60));
    }];
    passHideButton.backgroundColor = [UIColor clearColor];
    passHideButton.selected = YES;
    [passHideButton setImage:[UIImage imageNamed:@"icon_pass_no"] forState:UIControlStateSelected];
    [passHideButton setImage:[UIImage imageNamed:@"icon_pass_yes"] forState:UIControlStateNormal];
    [passHideButton addTarget:self action:@selector(passHideClick:) forControlEvents:UIControlEventTouchUpInside];
    self.passWifiField.rightViewMode = UITextFieldViewModeAlways;
    self.passWifiField.rightView = passHideButton;
    */
    
    WEAK
    UIButton *lijipeizhibutton = self.bgFourView
    .addButton(0)
    .title(LOCSTR(@"立即配置"))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        if ([MethodTool isBlankString:self.nameWifiField.text]) {
            [MBProgressHUD showError:LOCSTR(@"请输入wifi账号")];
            return;
        }
        if ([MethodTool isBlankString:self.wifiInfo[@"bssid"]]) {
            [MBProgressHUD showError:LOCSTR(@"未获取到必要参数")];
            return;
        }
        if (![self.nameWifiField.text containsString:@"zobe"]) {
            [MBProgressHUD showError:LOCSTR(@"请选择设备热点wifi")];
            return;
        }
        [self.wifiInfo setObject:self.nameWifiField.text forKey:@"name"];

        self.bgOneView.hidden = YES;
        self.bgTwoView.hidden = YES;
        self.bgThreeView.hidden = YES;
        self.bgFourView.hidden = YES;
        self.bgfiveView.hidden = NO;
        self.bgLoserView.hidden = YES;
        self.bgSuccessView.hidden = YES;

        [self createSoftAPWith:[NSString getGateway]];

        
    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.bgFourView.mas_bottom).mas_offset(-20);
        make.centerX.mas_equalTo(self.bgFourView);
        make.left.mas_offset(23);
        make.right.mas_offset(-23);
        make.height.mas_offset(44);
        
    })
    .view;
    lijipeizhibutton.layer.cornerRadius = 5;
}

#pragma mark - 第五个View - 配网中
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
    
    UILabel *line_centre = self.bgfiveView
    .addLabel(1)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgfiveView);
        make.top.mas_equalTo(35);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *two_l = self.bgfiveView
    .addLabel(0)
    .backgroundColor(KThemeColor)
    .text(@"2")
    .font(KFont(16))
    .textColor(UIColor.whiteColor)
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(line_centre.mas_left).mas_offset(-15);
        make.centerY.mas_equalTo(line_centre);
        make.size.mas_equalTo(30);
    })
    .view;
    two_l.layer.cornerRadius = 15;
    two_l.layer.masksToBounds = YES;
    
    UILabel *line_left = self.bgfiveView
    .addLabel(3)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.right.mas_equalTo(two_l.mas_left).mas_offset(-15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *one_l = self.bgfiveView
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
    
    
    UILabel *three_l = self.bgfiveView
    .addLabel(2)
    .backgroundColor(KThemeColor)
    .text(@"3")
    .font(KFont(16))
    .textColor(UIColor.whiteColor)
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_centre.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l.layer.cornerRadius = 15;
    three_l.layer.masksToBounds = YES;
    
    UILabel *line_right_four = self.bgfiveView
    .addLabel(1)
    .backgroundColor(KThemeColor)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(line_centre);
        make.left.mas_equalTo(three_l.mas_right).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    })
    .view;
    
    UILabel *three_l_four = self.bgfiveView
    .addLabel(2)
    .backgroundColor(KThemeColor)
    .text(@"4")
    .font(KFont(16))
    .textColor(UIColor.whiteColor)
    .textAlignment(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(two_l);
        make.left.mas_equalTo(line_right_four.mas_right).mas_offset(15);
        make.size.mas_equalTo(30);
    })
    .view;
    three_l_four.layer.cornerRadius = 15;
    three_l_four.layer.masksToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"new_distri_connect"];
    [self.bgfiveView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(two_l.mas_bottom).mas_offset(50);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(125);
        make.height.mas_equalTo(151);
    }];
    
    self.connectStepTipView = [[TIoTConnectStepTipView alloc] initWithTitlesArray:self.connectStepArray];
    [self.bgfiveView addSubview:self.connectStepTipView];
    [self.connectStepTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).mas_offset(40);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(166);
        make.height.mas_equalTo(114);
    }];
    
    [self performSelector:@selector(clock4Timer:) withObject:@(1) afterDelay:0.5f];

}

#pragma mark - 成功界面
-(void)createSuccessView{
    self.bgSuccessView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(-(k_Height_SafetyArea+20));
    })
    .view;
    self.bgSuccessView.layer.cornerRadius = 9;
    
    UIImageView *ImagView = self.bgSuccessView
    .addImageView(5)
    .image(KImage(@"icon_daduihao"))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgSuccessView);
        make.top.mas_offset(47);
        make.size.mas_equalTo(57);
    })
    .view;
    
    UILabel *wifi_label = self.bgSuccessView
    .addLabel(10)
    .text(LOCSTR(@"添加成功"))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ImagView);
        make.top.mas_equalTo(ImagView.mas_bottom).mas_offset(36);
    })
    .view;
    wifi_label.font = KFont(18);
    

    UIView *bgVIew = self.bgSuccessView
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

#pragma mark - 失败界面
-(void)createLoserView{
    self.bgLoserView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(-(k_Height_SafetyArea+20));
    })
    .view;
    self.bgLoserView.layer.cornerRadius = 9;
    
    UIImageView *ImagView = self.bgLoserView
    .addImageView(5)
    .image(KImage(@"icon_log_error"))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgLoserView);
        make.top.mas_offset(47);
        make.size.mas_equalTo(57);
    })
    .view;
    
    UILabel *wifi_label = self.bgLoserView
    .addLabel(10)
    .text(LOCSTR(@"配网失败"))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ImagView);
        make.top.mas_equalTo(ImagView.mas_bottom).mas_offset(30);
    })
    .view;
    wifi_label.font = KFont(18);
    
    UILabel *label = self.bgLoserView
    .addLabel(1)
    .textColor(KColor999999)
    .numberOfLines(0)
    .font(KFont((14)))
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ImagView);
        make.top.mas_equalTo(wifi_label.mas_bottom).mas_offset(40);
    })
    .view;
    label.text = LOCSTR(@"1.确认设备处于热点模式（指示灯慢闪）\n\n2.确认是否连接到设备热点\n\n3.核对家庭WIFI密码是否正确\n\n4.确认路由设备是否为2.4GWIFI频段");
    
    WEAK
    UIButton *button = self.bgLoserView
    .addButton(0)
    .title(LOCSTR(@"重试"))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
//        self.bgOneView.hidden = NO;
//        self.bgTwoView.hidden = YES;
//        self.bgThreeView.hidden = YES;
//        self.bgFourView.hidden = YES;
//        self.bgfiveView.hidden = YES;
//        self.bgSuccessView.hidden = YES;
//        self.bgLoserView.hidden = YES;
        [self.navigationController popViewControllerAnimated:YES];
    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.bgLoserView.mas_bottom).mas_offset(-20);
        make.centerX.mas_equalTo(self.bgLoserView);
        make.left.mas_offset(23);
        make.right.mas_offset(-23);
        make.height.mas_offset(44);
        
    })
    .view;
    button.layer.cornerRadius = 5;
    
    UIButton *button1 = self.bgLoserView
    .addButton(0)
    .title(LOCSTR(@"切换到一键配网"))
    .titleColor(KThemeColor)
    .hidden(YES)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        [self.navigationController popViewControllerAnimated:YES];
    })
    .masonry(^(MASConstraintMaker *make){
        make.bottom.mas_equalTo(self.bgLoserView.mas_bottom).mas_offset(-75);
        make.centerX.mas_equalTo(self.bgLoserView);
        make.left.mas_offset(23);
        make.right.mas_offset(-23);
        make.height.mas_offset(44);
        
    })
    .view;
    button1.layer.cornerRadius = 5;
   
}

-(void)backVC{
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"DeviceViewController")]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (void)clock4Timer:(NSNumber *)count {
    if (count.intValue > 4) {
        return;
    } else {
        self.connectStepTipView.step = count.intValue;
    }
}

#pragma mark - 点击wifi小箭头 切换手机连接的热点
-(void)wifiButtonClick{
//    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
//
//    }];
    
    NSURL *url = [NSURL URLWithString:@"App-prefs:root=WIFI"];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            
        }];
        
    }

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

-(NSArray *)connectStepArray{
    if (!_connectStepArray) {
        _connectStepArray = @[LOCSTR(@"手机与设备连接成功"), LOCSTR(@"向设备发送信息成功"), LOCSTR(@"设备连接云端成功"), LOCSTR(@"初始化成功")];
    }
    return _connectStepArray;
}

- (NSMutableDictionary *)wifiInfo{
    if (_wifiInfo == nil) {
        _wifiInfo = [NSMutableDictionary dictionary];
    }
    return _wifiInfo;
}
- (NSMutableDictionary *)oneWifiInfo{
    if (_oneWifiInfo == nil) {
        _oneWifiInfo = [NSMutableDictionary dictionary];
    }
    return _oneWifiInfo;
}
- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)releaseAlloc{
    if (self.tokenTimer) {
        dispatch_source_cancel(self.tokenTimer);
    }
    self.tokenTimer = nil;
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
        self.bgLoserView.hidden = YES;
        self.bgSuccessView.hidden = YES;
    }else if(!self.bgThreeView.hidden){//提示
        self.bgOneView.hidden = YES;
        self.bgTwoView.hidden = NO;
        self.bgThreeView.hidden = YES;
        self.bgFourView.hidden = YES;
        self.bgfiveView.hidden = YES;
        self.bgLoserView.hidden = YES;
        self.bgSuccessView.hidden = YES;
    }else if(!self.bgFourView.hidden){//输入设备wifi
        self.bgOneView.hidden = YES;
        self.bgTwoView.hidden = YES;
        self.bgThreeView.hidden = NO;
        self.bgFourView.hidden = YES;
        self.bgfiveView.hidden = YES;
        self.bgLoserView.hidden = YES;
        self.bgSuccessView.hidden = YES;
    }else if(!self.bgfiveView.hidden){//配网
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCSTR(@"退出添加设备") message:LOCSTR(@"当前正在添加设备，是否退出？") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"取消") style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:LOCSTR(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            STRONG
            self.bgOneView.hidden = YES;
            self.bgTwoView.hidden = YES;
            self.bgThreeView.hidden = YES;
            self.bgFourView.hidden = NO;
            self.bgfiveView.hidden = YES;
            self.bgLoserView.hidden = YES;
            self.bgSuccessView.hidden = YES;
            [self releaseAlloc];
            //去重
            //去重
            if (self.softAP) {
                [self.softAP stopAddDevice];
            }
            onceToken = 0;
            
            
        }]];
        
        [self presentViewController:alertController animated:true completion:nil];
        
    }else if(!self.bgLoserView.hidden){//失败
        [self.navigationController popViewControllerAnimated:YES];
    }else if(!self.bgSuccessView.hidden){//成功
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
