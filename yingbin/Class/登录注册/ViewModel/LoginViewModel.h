//
//  LoginViewModel.h
//  yingbin
//
//  Created by slxk on 2021/4/12.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewModel : BaseViewModel

KCOPY NSString *phone;
KCOPY NSString *code;
KCOPY NSString *n_pwd;
/// 区号
KCOPY NSString *zone;

KCOPY NSString *zc_pwd;


//修改密码
KCOPY NSString *oldPwd;
KCOPY NSString *pwd;

@end

NS_ASSUME_NONNULL_END
