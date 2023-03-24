//
//  DeviceViewCell.h
//  yingbin
//
//  Created by slxk on 2021/4/22.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceViewCell : UITableViewCell

@property (nonatomic, strong)DeviceViewModel *model;

KCOPY void (^isButtonClick)( UIButton *button,NSInteger intger);

@end

NS_ASSUME_NONNULL_END
