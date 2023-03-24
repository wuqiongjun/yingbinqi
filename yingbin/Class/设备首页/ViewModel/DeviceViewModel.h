//
//  DeviceViewModel.h
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceViewModel : BaseViewModel

@property (nonatomic, strong)NSString *ProductId;
@property (nonatomic, strong)NSString *DeviceName;
@property (nonatomic, strong)NSString *DeviceId;
@property (nonatomic, strong)NSString *AliasName;
@property (nonatomic, assign)NSInteger UserID;
@property (nonatomic, assign)NSInteger RoomId;
@property (nonatomic, strong)NSString *IconUrl;
@property (nonatomic, assign)NSInteger CreateTime;
@property (nonatomic, assign)NSInteger UpdateTime;
@property (nonatomic, strong)NSString *FamilyId;
@property (nonatomic, assign)NSInteger Online;

@property (nonatomic, strong)NSString *FromUserID;

@property (nonatomic, strong)NSMutableDictionary *deviceSetInfo;

@end

NS_ASSUME_NONNULL_END
