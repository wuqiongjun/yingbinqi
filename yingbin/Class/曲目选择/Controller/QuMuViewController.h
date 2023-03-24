//
//  QuMuViewController.h
//  yingbin
//
//  Created by slxk on 2021/5/19.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QuMuViewController : BaseViewController

@property (nonatomic,strong) void (^selectMusic)(NSMutableArray *array);

@property (nonatomic, strong)NSMutableArray *songDevArray;
@end

NS_ASSUME_NONNULL_END
