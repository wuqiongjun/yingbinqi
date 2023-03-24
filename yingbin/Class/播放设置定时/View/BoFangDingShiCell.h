//
//  BoFangDingShiCell.h
//  yingbin
//
//  Created by slxk on 2021/5/17.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BoFangDingShiCell : UITableViewCell

@property (nonatomic, strong) NSMutableDictionary *model;
@property (nonatomic, assign) NSInteger integer;
KCOPY void (^isSwitchClick)( UISwitch *button,NSMutableDictionary *dic);

@property (nonatomic, assign) BOOL fromTimeVCBool;
KCOPY void (^isBtnClick)(UIButton *button);


@end
NS_ASSUME_NONNULL_END
