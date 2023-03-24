//
//  WQCountryCodeController.h
//  yingbin
//
//  Created by slxk on 2021/4/21.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^returnCountryCodeBlock) (NSString *countryName, NSString *code);

@protocol WQCountryCodeControllerDelegate <NSObject>

@optional

/**
 Delegate 回调所选国家代码

 @param countryName 所选国家
 @param code 所选国家代码
 */
-(void)returnCountryName:(NSString *)countryName code:(NSString *)code;

@end

@interface WQCountryCodeController : BaseViewController

@property (nonatomic, weak) id<WQCountryCodeControllerDelegate> deleagete;

@property (nonatomic, copy) returnCountryCodeBlock returnCountryCodeBlock;

@end

NS_ASSUME_NONNULL_END
