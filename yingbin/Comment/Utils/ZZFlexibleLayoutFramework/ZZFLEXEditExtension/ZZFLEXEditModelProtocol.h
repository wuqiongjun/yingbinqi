//
//  ZZFLEXEditModelProtocol.h
//  zhuanzhuan
//
//  Created by 李祥 on 2017/8/15.
//  Copyright © 2017年 KUSDOM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZZFLEXEditModelProtocol <NSObject>

@required;
/// 检查输入合法性
- ()checkInputlegitimacy;

- (void)excuteCompleteAction;


@end
