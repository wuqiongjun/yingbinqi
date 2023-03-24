//
//  BofangViewModel.h
//  yingbin
//
//  Created by slxk on 2021/5/31.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface BofangViewModel : BaseViewModel

@property (nonatomic, strong)NSString *TimerId;
@property (nonatomic, strong)NSString *TimerName;
@property (nonatomic, strong)NSString *ProductId;
@property (nonatomic, strong)NSString *DeviceName;
@property (nonatomic, strong)NSString *Days;
@property (nonatomic, strong)NSString *TimePoint;
@property (nonatomic, strong)NSString *Repeat;
@property (nonatomic, strong)NSString *Data;
@property (nonatomic, assign)NSInteger Status;
@property (nonatomic, assign)NSInteger CreateTime;
@property (nonatomic, assign)NSInteger UpdateTime;



@end

NS_ASSUME_NONNULL_END
