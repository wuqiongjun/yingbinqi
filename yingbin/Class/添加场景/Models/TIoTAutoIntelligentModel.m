//
//  TIoTAutoIntelligentModel.m
//  yingbin
//
//  Created by slxk on 2021/5/7.
//  Copyright © 2021 wq. All rights reserved.
//

#import "TIoTAutoIntelligentModel.h"

@implementation TIoTAutoIntelligentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"Timer":[AutoIntelliConditionTimerProperty class],
             @"Property":[AutoIntelliConditionDeviceProperty class],
//             @"propertyModel":[TIoTPropertiesModel class],
    };
}

@end

@implementation AutoIntelliConditionDeviceProperty

@end


@implementation AutoIntelliConditionTimerProperty

@end


