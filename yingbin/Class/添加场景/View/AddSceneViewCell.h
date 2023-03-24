//
//  AddSceneViewCell.h
//  yingbin
//
//  Created by slxk on 2021/4/27.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIoTAutoIntelligentModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^cancelBlock)(UIButton *btn);

@interface AddSceneViewCell : UITableViewCell

@property (nonatomic,strong) NSDictionary *dataDic;
@property (nonatomic, strong)TIoTAutoIntelligentModel *model;

@property (nonatomic, copy) cancelBlock cancelBlock;

@end

NS_ASSUME_NONNULL_END
