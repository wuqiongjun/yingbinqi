//
//  ChangjingViewCell.h
//  yingbin
//
//  Created by slxk on 2021/4/23.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ChangjingViewCell : UITableViewCell

KCOPY void (^isSwitchSuccess)(UISwitch *sender,NSDictionary *dic);

@property (nonatomic,strong) NSDictionary *dataDic;

@end

NS_ASSUME_NONNULL_END
