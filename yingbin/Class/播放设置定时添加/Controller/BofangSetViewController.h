//
//  BofangSetViewController.h
//  yingbin
//
//  Created by slxk on 2021/4/23.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface BofangSetViewController : BaseViewController

@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, assign) NSInteger integer;
@property (nonatomic, strong) NSMutableDictionary *model;

@end

NS_ASSUME_NONNULL_END
