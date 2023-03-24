//
//  AddSceneViewController.h
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"
#import "TIoTAutoIntelligentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddSceneViewController : BaseViewController

@property (nonatomic, strong) NSDictionary *paramDic; //从场景主页传入场景参数

@property (nonatomic, strong) NSDictionary *autoSceneInfoDic; //场景主页，自动智能列表中获取的被选中场景

@property (nonatomic, assign) BOOL isSceneDetail;   //场景详情编辑页面，yes 从智能主页进入 no 普通入口进入

@property (nonatomic, strong) TIoTAutoIntelligentModel *addConditionModel;

@property (nonatomic, strong) TIoTAutoIntelligentModel *addActionModel;

@property (nonatomic, strong) NSMutableArray *dataNameArr;//所有场景的名字

@end

NS_ASSUME_NONNULL_END
