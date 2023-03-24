//
//  TIoTWebSocketManage.m
//  yingbin
//
//  Created by slxk on 2021/6/16.
//  Copyright © 2021 wq. All rights reserved.
//

#import "TIoTWebSocketManage.h"
//#import "TIoTAppEnvironment.h"
//#import "UIViewController+GetController.h"
#import "UIViewController+GetController.h"
#import "BaseNavigationController.h"
#import "LoginViewController.h"
#import "TIoTCoreRequestObj.h"
#import "ReachabilityManager.h"
#import "TIoTCoreSocketCover.h"
#import "TIoTCoreDeviceSet.h"
#import "TIOTTRTCModel.h"
#import "TIoTTRTCSessionManager.h"
#import "TIoTTRTCUIManage.h"
#import "TIoTCoreSocketManager.h"
#import "TIoTCoreAppEnvironment.h"


#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define WeakSelf(type)  __weak typeof(type) weak##type = type;

static NSString *registDeviceReqID = @"5001";
static NSString *heartBeatReqID = @"5002";

@interface TIoTWebSocketManage ()<QCSocketManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *reqArray;

@end

@implementation TIoTWebSocketManage

+(instancetype)shared{
    static TIoTWebSocketManage *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self instanceSocketManager];
        [self registerNetworkNotifications];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)instanceSocketManager {
    
    [TIoTCoreSocketManager shared].socketedRequestURL = [TIoTCoreAppEnvironment shareEnvironment].wsUrl;
//    [TIoTCoreSocketManager shared].socketedRequestURL = [NSString stringWithFormat:@"%@?uin=%@",[TIoTCoreAppEnvironment shareEnvironment].wsUrl,TIoTAPPConfig.GlobalDebugUin];
    [TIoTCoreSocketManager shared].delegate = self;
    
    //TRTC UI Delegate
    [TIoTTRTCSessionManager sharedManager].uidelegate = TIoTTRTCUIManage.sharedManager;
}

- (void)registerNetworkNotifications{
    
    [[NetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(NetworkReachabilityStatus status) {
        switch (status) {
            case NetworkReachabilityStatusUnknown:
                NSLog(@"状态不知道");
                break;
            case NetworkReachabilityStatusNotReachable:
                NSLog(@"没网络");
                break;
            case NetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                [self SRWebSocketOpen];
                break;
            case NetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"移动网络");
                [self SRWebSocketOpen];
                break;
            default:
                break;
        }
    }];
    
    [[NetworkReachabilityManager sharedManager] startMonitoring];
    
}

/// 订阅
- (void)registerDevicecActive:(NSNotification *)noti {
    
    NSArray *deviceIds = noti.object;
    
    [[TIoTWebSocketManage shared] sendActiveData:deviceIds withRequestURL:@"ActivePush" complete:^(BOOL sucess, NSDictionary * _Nonnull data) {
        if (sucess) {

        }
    }];
}

-(void)SRWebSocketOpen{
    
    [[TIoTCoreSocketManager shared] socketOpen];
    
}

-(void)SRWebSocketClose{
    
    [[TIoTCoreSocketManager shared] socketClose];
    [self destoryHeartBeat];
}

#pragma mark - QCSocketManagerDelegate delegete
- (void)socketDidOpen:(TIoTCoreSocketManager *)manager {
    
    WCLog(@"************************** socket 连接成功************************** ");
//    [HXYNotice addHeartBeatListener:self reaction:@selector(initHeartBeat:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initHeartBeat:) name:HeartBeatNoti object:nil];

//    [HXYNotice addActivePushListener:self reaction:@selector(registerDevicecActive:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerDevicecActive:) name:addActivePush object:nil];

//    [HXYNotice addSocketConnectSucessPost];
    [[NSNotificationCenter defaultCenter] postNotificationName:socektConnectSucess object:nil];

}

- (void)socket:(TIoTCoreSocketManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"------%@-----",error);
}

- (void)socket:(TIoTCoreSocketManager *)manager didReceiveMessage:(id)message {
    [self handleReceivedMessage:message];
}

- (void)socket:(TIoTCoreSocketManager *)manager didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    WCLog(@"************************** socket连接断开************************** ");
    [self SRWebSocketClose];
    
}


- (void)deviceReceivedData:(NSDictionary *)data{
    BOOL sucess = YES;
    if (![NSObject isNullOrNilWithObject:data[@"data"]]) {
        sucess = YES;
    }
    else{
        sucess = NO;
    }
    
    NSString *reqID = [NSString stringWithFormat:@"%@",data[@"reqId"]];
    TIoTCoreRequestObj *reqObj = self.reqArray[reqID];
    
    if (reqObj.sucess) {
        reqObj.sucess(sucess, data[@"data"]);
        [self.reqArray removeObjectForKey:reqID];
    }
}

//监听到的设备上报信息
- (void)deviceInfo:(NSDictionary *)deviceInfo{
//    [HXYNotice addReportDevicePost:deviceInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:reportDevice object:nil userInfo:deviceInfo];
    /*
    //检测是否TRTC设备，是否在呼叫中
    NSDictionary *payloadDic = [NSString base64Decode:deviceInfo[@"Payload"]];
    NSLog(@"----111---%@",payloadDic);
    NSLog(@"----222---%@",[TIoTCoreUserManage shared].userId);
    TIOTtrtcPayloadModel *model = [TIOTtrtcPayloadModel yy_modelWithJSON:payloadDic];
    model.params.deviceName = deviceInfo[@"DeviceId"];
    if (model.params._sys_userid.length < 1) {
        model.params._sys_userid = deviceInfo[@"DeviceId"];
    }

    
    if ([payloadDic.allKeys containsObject:@"params"]) {
        NSDictionary *paramsDic = payloadDic[@"params"];
        if (paramsDic[@"_sys_audio_call_status"]) {
            [TIoTCoreUserManage shared].sys_call_status = model.params._sys_audio_call_status;
        }else if (paramsDic[@"_sys_video_call_status"]) {
            [TIoTCoreUserManage shared].sys_call_status = model.params._sys_video_call_status;
        }
    }
    
    if ([model.method isEqualToString:@"report"]) {
        if (model.params._sys_audio_call_status.intValue == 1 || model.params._sys_video_call_status.intValue == 1) {
            
            
            if ([TIoTTRTCUIManage sharedManager].isActiveStatus == YES && (![NSString isNullOrNilWithObject:[TIoTTRTCUIManage sharedManager].deviceID] && [[TIoTTRTCUIManage sharedManager].deviceID isEqualToString:model.params.deviceName])) {
                //用户1和用户2（不同账号）同时呼叫设备,deviceA 接听，则会上报对应callstatus属性为1 和 先接收到的比方说是用户1的userid，对应的用户1会调用App::IotRTC::CallDevice加入房间，另一个用户2收到的上报消息查看userid不是自己，则提示对方正忙…，并退出
                if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                    //TRTC设备需要通话，开始通话,防止不是trtc设备的通知
                    [[TIoTTRTCUIManage sharedManager] preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                        
                        [MBProgressHUD showError:reason];
                    }];
                }else {
                    [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                        [MBProgressHUD showError:reason];
                    }];
                }
            }else {
                
                if ([model.params._sys_userid isEqualToString:model.params.deviceName]) {
                    [[TIoTTRTCUIManage sharedManager] preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {

                        [MBProgressHUD showError:reason];
                    }];
                }else {
                    NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
                    for (NSString *userIdString in userIdArray) {
                        model.params._sys_userid = userIdString?:@"";
                        if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                            [[TIoTTRTCUIManage sharedManager] preEnterRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {

                                [MBProgressHUD showError:reason];
                            }];
                        }
                        
                    }
                }
                
            }
        }else if (model.params._sys_audio_call_status.intValue == 2 || model.params._sys_video_call_status.intValue == 2) {
            
            NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
            for (NSString *userIdString in userIdArray) {

                model.params._sys_userid = userIdString?:@"";
                [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                    [MBProgressHUD showError:reason];
                }];
            }
            
        }else if (model.params._sys_audio_call_status.intValue == 0 || model.params._sys_video_call_status.intValue == 0) {
            NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
            for (NSString *userIdString in userIdArray) {

                model.params._sys_userid = userIdString?:@"";
                if ([TIoTTRTCUIManage sharedManager].isEnterError == NO) {
                    if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                        
                        if ([[TIoTTRTCUIManage sharedManager].deviceID isEqualToString:model.params.deviceName]) {
                            [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                                [MBProgressHUD showError:reason];
                            }];
                        }
                        
                    }else if ([model.params._sys_userid isEqualToString:model.params.deviceName]) {   //返回socket params 里没有userid时候（设备端主动呼叫，未接听，设备主动挂断）
                           //防止case 3 中另一个设备 呼叫正在调起通话页面的APP
                            [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                                [MBProgressHUD showError:reason];
                            }];
                        
                    }
                    
                }

            }
            
            
        }
        
    }
    
    
    //异常
    if ([deviceInfo[@"SubType"] isEqualToString:@"Offline"]) {
        
        NSArray *userIdArray = [model.params._sys_userid componentsSeparatedByString:@";"];
        for (NSString *userIdString in userIdArray) {

            model.params._sys_userid = userIdString?:@"";
            if ([model.params._sys_userid isEqualToString:[TIoTCoreUserManage shared].userId]) {
                [[TIoTTRTCUIManage sharedManager] preLeaveRoom:model.params failure:^(NSString * _Nullable reason, NSError * _Nullable error, NSDictionary * _Nullable dic) {
                    [MBProgressHUD showError:reason];
                }];
            }

        }
    }
     */

}

- (void)handleReceivedMessage:(id)message{
    NSDictionary *dic = [NSString jsonToObject:message];
//    WCLog(@"message:%@",dic);
    NSString *reqId = [NSString stringWithFormat:@"%@",dic[@"reqId"]];
    if ([NSObject isNullOrNilWithObject:dic[@"reqId"]])
    {
        if ([dic[@"action"] isEqualToString:@"DeviceChange"]) {
            [self deviceInfo:dic[@"params"]];
            return;
        }
    }
    
    if ([heartBeatReqID isEqualToString:reqId]) {//心跳回包
        return;
    }
    
    if ([registDeviceReqID isEqualToString:reqId]) {//
        [self deviceReceivedData:dic];
        return;
    }
    
    
    
    BOOL sucess = YES;
    NSDictionary *result = nil;
    
    if (![NSObject isNullOrNilWithObject:dic[@"data"]]) {
        if (dic[@"data"][@"Response"][@"Error"]) {
            [MBProgressHUD showError:dic[@"data"][@"Response"][@"Error"][@"Message"]];
            sucess = NO;
            result = dic[@"data"][@"Response"][@"Error"];
        }
        if ([dic[@"data"][@"result"] isEqualToString:@"hello world"]) {
            return;
        }
    }
    else{
        [MBProgressHUD showError:dic[@"error_message"]];
        sucess = NO;
        result = dic;
    }
    
    
    NSString *reqIDStr = [NSString stringWithFormat:@"%@",reqId];
    TIoTCoreRequestObj *reqObj = self.reqArray[reqIDStr];
    if(reqObj.sucess){
        if (sucess) {
            if ([NSObject isNullOrNilWithObject:dic[@"data"][@"Response"][@"Data"]]) {
                
                reqObj.sucess(sucess,sucess ? dic[@"data"][@"Response"] : [NSDictionary dictionary]);
            }
            else{
                reqObj.sucess(sucess,sucess ? dic[@"data"][@"Response"][@"Data"] : [NSDictionary dictionary]);
            }
        }
        else{
            reqObj.sucess(sucess, result);
        }
        [self.reqArray removeObjectForKey:reqIDStr];
    }
    
}

//初始化心跳
- (void)initHeartBeat:(NSNotification *)noti
{
    NSArray *deviceIds = noti.object;
    NSLog(@"---------初始化心跳");

    dispatch_main_async_safe(^{
        [self destoryHeartBeat];

        [[TIoTCoreSocketManager shared] startHeartBeatWith:deviceIds];
    })
}


//取消心跳
- (void)destoryHeartBeat
{
    NSLog(@"---------取消心跳");
    [[TIoTCoreSocketManager shared] stopHeartBeat];
}

//ping
- (void)ping:(NSTimer *)timer {
    NSArray *deviceIds = timer.userInfo;
    NSLog(@"--------ping------");
    if ([TIoTCoreSocketManager shared].socketReadyState == WC_OPEN) {
        NSLog(@"--------ping----WC_OPEN--");
        NSData *data= [NSJSONSerialization dataWithJSONObject:[self heartData:deviceIds] options:NSJSONWritingPrettyPrinted error:nil];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        [[TIoTCoreSocketManager shared] sendData:dataDic];
    }
    
}


//心跳数据
- (NSDictionary *)heartData:(NSArray *)deviceIds {
    NSLog(@"--------发送心跳包----");
    return @{
        @"action":[TIoTCoreAppEnvironment shareEnvironment].action,
        @"reqId":[[NSUUID UUID] UUIDString],
        @"params":@{
            @"Action": @"AppDeviceTraceHeartBeat",
            @"AccessToken":[TIoTCoreUserManage shared].accessToken,
            @"RequestId":@"weichuan-client",
            @"ActionParams": @{
                @"DeviceIds": deviceIds
            }
        }
    };
}

//判断是否重新登录
- (BOOL)needLogin{
    if ([[TIoTCoreUserManage shared].expireAt integerValue] <= [[NSString getNowTimeString] integerValue] && [TIoTCoreUserManage shared].accessToken.length > 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOCSTR(@"温馨提示") message:LOCSTR(@"登录已过期") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:LOCSTR(@"重新登录") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
            [[TIoTCoreUserManage shared] clear];
            [TLNotificationCenter postNotificationName:LoginSuccessNotify object:nil];
            
//            [[TIoTAppEnvironment shareEnvironment] loginOut];
//            BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
//            [UIViewController getCurrentViewController].view.window.rootViewController = nav;
        }];
        [alert addAction:alertA];
        [[UIViewController getCurrentViewController] presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    return NO;
}

//设备监听
- (void)sendActiveData:(NSArray *)deviceIds withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess{
    //每次请求需要判断登录是否失效
    if ([self needLogin]) {
        return;
    }
    
    NSDictionary *dataDic = [[TIoTCoreSocketCover shared] registerDeviceParamterActive:deviceIds withAction:requestURL complete:sucess];
    
    [[TIoTCoreSocketManager shared] sendData:dataDic];
    
}

- (void)sendData:(NSDictionary *)paramDic withRequestURL:(NSString*)requestURL complete:(didReceiveMessage)sucess{
    //每次请求需要判断登录是否失效
    if ([self needLogin]) {
        return;
    }
    
    NSDictionary *dic = @{@"Platform":[TIoTCoreAppEnvironment shareEnvironment].platform,
                          @"Agent":[TIoTCoreAppEnvironment shareEnvironment].platform,
                          @"RequestId":[[NSUUID UUID] UUIDString],
                          @"action":[TIoTCoreAppEnvironment shareEnvironment].action,
                          @"AppKey":[TIoTCoreAppEnvironment shareEnvironment].appKey,
    };
    
    NSDictionary *dataDic = [[TIoTCoreSocketCover shared] sendDataDictionaryWithParamDic:paramDic withArgumentDic:dic withRequestURL:requestURL complete:sucess];
    [[TIoTCoreSocketManager shared] sendData:dataDic];
}

-(WCReadyState)socketReadyState{

    return [TIoTCoreSocketManager shared].socketReadyState;
}

#pragma mark - getter

- (NSMutableDictionary *)reqArray
{
    if (!_reqArray) {
        _reqArray = [NSMutableDictionary dictionary];
    }
    return _reqArray;
}


@end
