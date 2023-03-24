//
//  MethodTool.h
//  yingbin
//
//  Created by slxk on 2021/4/13.
//  Copyright © 2021 wq. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MethodTool : NSObject


+ (BOOL)checkLoginWithVc:(UIViewController *)Vc;
+ (UIImage *)imageWithOriginal:(NSString *)imageName;
+ (void)pushWebVcFrom:(UIViewController *)Vc URL:(NSString *)URL title:(NSString *)title;
+ (BOOL)isBlankString:(NSString *)string;
+ (void)presentVc:(UIViewController *)vc
            Title:(NSString *)title
          message:(NSString *)message
cancelButtonTitle:(NSString *)cancelButtonTitle
defineButtonTitle:(NSString *)defineButtonTitle
otherButtonTitles:(NSArray *)otherButtonTitles
    actionHandler:(void (^)(NSInteger buttonIndex))actionHandler;
//10位当前时间戳
+ (NSString *)getNowTimeTimestamp;
//获取当前的时间小时和分钟
+(NSString*)getCurrentTimesHHSS;
//获取当前的时间
+(NSString*)getCurrentTimes;
+ (NSDictionary *)dicFromObject:(NSObject *)object;

+ (NSString *)getName:(NSInteger )index;

//判断是纯数字
+ (BOOL)isPureInt:(NSString *)string;

//计算文件Hash值   MD5
+ (NSString *)computeHashForFile:(NSURL *)fileURL;
+ (NSString *)computeHashForData:(NSData *)inputData;

+ (NSString *)playModeName:(NSInteger )index;

+(BOOL)detectionIsPasswordQualified:(NSString *)patternStr;

+ (void)judgeUserSignoutWithReturnToken:(NSDictionary *)descriptionDic;

+ (BOOL)isContainsEmoji:(NSString *)string;

//时间戳转时间
+(NSString *)timestampTime:(NSInteger)timestamp andFormatter:(NSString *)format;
@end

NS_ASSUME_NONNULL_END
