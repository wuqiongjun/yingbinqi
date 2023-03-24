//
//  TIoTRefreshFooter.h
//  yingbin
//
//  Created by slxk on 2021/5/11.
//  Copyright © 2021 wq. All rights reserved.
//

#import "MJRefreshAutoFooter.h"

#define kXDPRefreshFooterFailure LOCSTR(@"加载失败，点击重新加载") 

NS_ASSUME_NONNULL_BEGIN

@interface TIoTRefreshFooter : MJRefreshAutoFooter

- (void)showFailStatus;

- (void)setTitle:(NSString *)title forState:(MJRefreshState)state;

- (NSString *)titleForState:(MJRefreshState)state;

@end

NS_ASSUME_NONNULL_END
