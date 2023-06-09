//
//  MyDocument.m
//  yingbin
//
//  Created by slxk on 2021/6/4.
//  Copyright © 2021 wq. All rights reserved.
//

#import "MyDocument.h"

@implementation MyDocument

//读取icloud数据调用，响应openWithCompletionHandler
- (BOOL)loadFromContents:(id)contents ofType:(nullable NSString *)typeName error:(NSError **)outError __TVOS_PROHIBITED
{
    self.myData = [contents copy];
    return true;
}

//保存数据、修改数据到icloud，响应save
- (nullable id)contentsForType:(NSString *)typeName error:(NSError **)outError __TVOS_PROHIBITED
{
    if (!self.myData) {
        self.myData = [[NSData alloc] init];
    }
    return self.myData;
}



@end
