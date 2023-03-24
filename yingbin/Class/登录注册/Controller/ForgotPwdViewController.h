//
//  ForgotPwdViewController.h
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ForgotPwdViewController : BaseViewController

KSTRONG LoginViewModel *viewModel;
KCOPY void (^registeredSuccess)(NSString *account,NSString *password);
KSTRONG NSString *title_str;
@end

NS_ASSUME_NONNULL_END
