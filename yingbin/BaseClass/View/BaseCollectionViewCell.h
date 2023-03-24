//
//  BaseCollectionViewCell.h
//  yingbin
//
//  Created by slxk on 2021/4/21.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZFlexibleLayoutViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseCollectionViewCell : UICollectionViewCell<ZZFlexibleLayoutViewProtocol>

KCOPY id (^eventAction)(NSInteger type, id data);

@end

NS_ASSUME_NONNULL_END
