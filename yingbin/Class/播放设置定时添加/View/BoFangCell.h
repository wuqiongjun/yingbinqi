//
//  BoFangCell.h
//  yingbin
//
//  Created by slxk on 2021/6/9.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BoFangCell : UITableViewCell

@property (nonatomic, strong)NSString *nameStr;
@property (nonatomic, assign)NSInteger integer;

KCOPY void (^btnSelected)(NSInteger btn);

@end

NS_ASSUME_NONNULL_END
