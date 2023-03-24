//
//  CommonProtocol.h
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CommonProtocol <NSObject>


@required
- (void)showLoadingProgress;
- (void)dismissLoadingProgress;
- (void)showTip:(NSString *)text;
- (void)showMidTip:(NSString *)text;

@optional

- (void)showLoadingText:(NSString *)text;
- (void)finish_edit;

@end

NS_ASSUME_NONNULL_END
