//
//  SelectDeviceNextVC.h
//  yingbin
//
//  Created by slxk on 2021/5/7.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"
#import "TIoTAutoIntelligentModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^actionBlock)(TIoTAutoIntelligentModel *timerModel);

@interface SelectDeviceNextVC : BaseViewController

@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, strong)TIoTAutoIntelligentModel *model;

@property (nonatomic, copy) actionBlock actionBlock; //修改完返回block

@end

NS_ASSUME_NONNULL_END
