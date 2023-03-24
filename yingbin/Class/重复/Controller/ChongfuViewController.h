//
//  ChongfuViewController.h
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChongfuViewController : BaseViewController

@property (nonatomic,strong) void (^repeatResult)(NSArray *repeats);

@property (nonatomic, strong)NSString *days;

@end

NS_ASSUME_NONNULL_END
