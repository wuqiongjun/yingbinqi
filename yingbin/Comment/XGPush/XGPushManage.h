//
//  XGPushManage.h
//  yingbin
//
//  Created by slxk on 2021/7/1.
//  Copyright © 2021 wq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XGPushManage : NSObject

+ (instancetype)sharedXGPushManage;

@property (nonatomic, copy, nullable) NSDictionary *launchOptions;

/// 开启推送服务
- (void)startPushService;

/**
 @brief 停止信鸽推送服务 -stopXGNotification
 @note 调用此方法将导致当前设备不再接受信鸽服务推送的消息.如果再次需要接收信鸽服务的消息推送，则必须需要再次调用startXG:withAppKey:delegate:方法重启信鸽推送服务
 */
- (void)stopPushService;


- (void)reportXGNotificationInfo:(nonnull NSDictionary *)info;

- (void)bindPushToken;

@end

NS_ASSUME_NONNULL_END
