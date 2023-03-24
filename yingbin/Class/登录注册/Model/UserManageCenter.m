//
//  UserManageCenter.m
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "UserManageCenter.h"

static NSString *const kUserInfoModel = @"kUserInfoModel";

@implementation UserManageCenter

singleton_implementation(UserManageCenter)

+ (void)logout{
    
    [UserManageCenter sharedUserManageCenter].deviceList = [NSMutableArray arrayWithArray:@[]];
}
@end
