//
//  BaseViewModel.h
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewModel : NSObject

KWEAK id<CommonProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
