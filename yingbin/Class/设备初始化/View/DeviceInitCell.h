//
//  DeviceInitCell.h
//  yingbin
//
//  Created by slxk on 2021/6/11.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInitCell : UITableViewCell

@property (nonatomic, strong)NSMutableDictionary *dic;
@property (nonatomic, strong)UIButton *btn;


KCOPY void (^selectSuccess)( UIButton *btn);

@end

NS_ASSUME_NONNULL_END
