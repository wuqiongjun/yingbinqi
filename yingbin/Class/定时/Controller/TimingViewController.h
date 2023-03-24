//
//  TimingViewController.h
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"
#import "TIoTAutoIntelligentModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^AutoIntelAddTimerBlock)(TIoTAutoIntelligentModel *timerModel);
typedef void(^AutoUpdateTimerBlock)(TIoTAutoIntelligentModel *modifiedTimerModel);

@interface TimingViewController : BaseViewController

@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, strong)TIoTAutoIntelligentModel *model;

@property (nonatomic, copy) AutoIntelAddTimerBlock autoIntelAddTimerBlock;
@property (nonatomic, copy) AutoUpdateTimerBlock updateTimerBlock; //修改完返回block

@end

NS_ASSUME_NONNULL_END
