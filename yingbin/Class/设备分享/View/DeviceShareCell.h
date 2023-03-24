//
//  DeviceShareCell.h
//  yingbin
//
//  Created by slxk on 2021/5/15.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CancelShareBtnBlock)(UIButton *btn);

@interface DeviceShareCell : UITableViewCell

@property (nonatomic, strong)NSMutableDictionary *dataDic;

@property (nonatomic, strong)DeviceViewModel *model;

@property (nonatomic, copy) CancelShareBtnBlock CancelShareBtnBlock;

@end

NS_ASSUME_NONNULL_END
