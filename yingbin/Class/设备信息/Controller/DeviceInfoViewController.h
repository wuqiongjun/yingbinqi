//
//  DeviceInfoViewController.h
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoViewController : BaseViewController

@property (nonatomic, strong)NSString *deviceNameSTR;
@property (nonatomic, strong)NSString *wifiSTR;
@property (nonatomic, strong)NSString *macSTR;
@property (nonatomic, strong)NSString *versionSTR;
@property (nonatomic, strong)NSString *signalSTR;
@property (nonatomic, strong)NSString *batterySTR;


@property (nonatomic, strong)NSMutableDictionary *Response;//固件版本

@end

NS_ASSUME_NONNULL_END
