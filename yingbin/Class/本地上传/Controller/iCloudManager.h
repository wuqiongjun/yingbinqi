//
//  iCloudManager.h
//  yingbin
//
//  Created by slxk on 2021/6/15.
//  Copyright © 2021 wq. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^downloadBlock)(id obj);

@interface iCloudManager : NSObject

+ (BOOL)iCloudEnable;

+ (void)downloadWithDocumentURL:(NSURL*)url callBack:(downloadBlock)block;

@end

NS_ASSUME_NONNULL_END
