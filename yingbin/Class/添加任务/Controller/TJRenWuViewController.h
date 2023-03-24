//
//  TJRenWuViewController.h
//  yingbin
//
//  Created by slxk on 2021/4/26.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"
#import "TIoTAutoIntelligentModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^AutoUpdateBlock)(TIoTAutoIntelligentModel *model);

@interface TJRenWuViewController : BaseViewController

@property (nonatomic, strong)NSString *deviceNameStr;
@property (nonatomic, strong)NSMutableArray *itemsArray;
@property (nonatomic,strong) void (^addRenWuSuccess)(NSMutableArray *listArray,NSString *nameStr);
@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, strong)TIoTAutoIntelligentModel *model;

@property (nonatomic, copy) AutoUpdateBlock autoUpdateBlock; //修改完返回block

@end

NS_ASSUME_NONNULL_END
