//
//  iCloudManager.m
//  yingbin
//
//  Created by slxk on 2021/6/15.
//  Copyright © 2021 wq. All rights reserved.
//

#import "iCloudManager.h"
#import "MyDocument.h"
@implementation iCloudManager

+ (BOOL)iCloudEnable {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSURL *url = [manager URLForUbiquityContainerIdentifier:nil];

    if (url != nil) {
        return YES;
    }
    
    NSLog(@"iCloud 不可用");
    return NO;
}


+ (void)downloadWithDocumentURL:(NSURL*)url callBack:(downloadBlock)block {
    
    MyDocument *iCloudDoc = [[MyDocument alloc]initWithFileURL:url];
    
    [iCloudDoc openWithCompletionHandler:^(BOOL success) {
        if (success) {
            
            [iCloudDoc closeWithCompletionHandler:^(BOOL success) {
                NSLog(@"关闭成功");
            }];
            
            if (block) {
                block(iCloudDoc.myData);
            }
            
        }
    }];
}

@end
