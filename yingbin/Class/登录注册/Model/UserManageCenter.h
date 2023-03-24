//
//  UserManageCenter.h
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"
#import "DeviceViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface UserManageCenter : NSObject

singleton_interface(UserManageCenter)


//版本检查
@property (nonatomic,strong) NSMutableDictionary *versionDic;

//首页设备列表
@property (nonatomic,strong) NSMutableArray *deviceList;


//进设置的设备model
@property (nonatomic, strong)DeviceViewModel *deviceModel;

//自定义歌曲list
@property (nonatomic, strong)NSMutableArray *devicePlayList;

//感应播放场景
@property (nonatomic, strong)NSMutableArray *DAPSenseList;
//广告场景
@property (nonatomic, strong)NSMutableArray *ASenseList;
//仅播放场景
@property (nonatomic, strong)NSMutableArray *PSenseList;

//人流历史记录
@property (nonatomic, strong)NSMutableArray *CountHistoryList;

+ (void)logout;


@end

NS_ASSUME_NONNULL_END
