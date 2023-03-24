//
//  BaseViewController.h
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "ZZFlexibleLayoutViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : ZZFlexibleLayoutViewController<CommonProtocol>


KSTRONG UIBarButtonItem *backButtonItem;
KSTRONG UIBarButtonItem *addButtonItem;
KSTRONG UIBarButtonItem *saveButtonItem;
KSTRONG UIBarButtonItem *ShareDeviceItem;


- (void)goback;
- (void)addItemClick:(UIBarButtonItem *)btn;
- (void)shareDeviceClick:(UIBarButtonItem *)btn;


- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
