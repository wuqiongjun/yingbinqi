//
//  MethodTool.m
//  yingbin
//
//  Created by slxk on 2021/4/13.
//  Copyright © 2021 wq. All rights reserved.
//

#import "MethodTool.h"
#import "LoginViewController.h"
#import "locallyMusicModel.h"
#include <CommonCrypto/CommonDigest.h>

#define kCode @"code"
#define kMsg @"msg"
#define kData @"data"

NSString  * const kInvalidParameterValueInvalidAccessToken = @"InvalidParameterValue.InvalidAccessToken";

@implementation MethodTool

+ (BOOL)checkLoginWithVc:(UIViewController *)Vc{
    
    return YES;
}

+ (UIImage *)imageWithOriginal:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
+ (void)pushWebVcFrom:(UIViewController *)Vc URL:(NSString *)URL title:(NSString *)title{
    
    WebViewController *webVc = [WebViewController new];
    webVc.url = URL;
    webVc.navTitle = title;
    [Vc.navigationController pushViewController:webVc animated:YES];
}
///验证是否是空字符串
+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
+ (void)presentVc:(UIViewController *)vc
            Title:(NSString *)title
          message:(NSString *)message
cancelButtonTitle:(NSString *)cancelButtonTitle
defineButtonTitle:(NSString *)defineButtonTitle
otherButtonTitles:(NSArray *)otherButtonTitles
    actionHandler:(void (^)(NSInteger buttonIndex))actionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(alertController) weakController = alertController;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSInteger index = [weakController.actions indexOfObject:action];
        if (actionHandler) {
            actionHandler(index);
        }
    }];
    [alertController addAction:cancelAction];
    
    if (defineButtonTitle.length > 0) {
        UIAlertAction *defineAction = [UIAlertAction actionWithTitle:defineButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSInteger index = [weakController.actions indexOfObject:action];
            if (actionHandler) {
                actionHandler(index);
            }
        }];
        [alertController addAction:defineAction];
    }
    
    for (NSString *title in otherButtonTitles) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (actionHandler) {
                NSInteger index = [weakController.actions indexOfObject:action];
                actionHandler(index);
            }
        }];
        [alertController addAction:action];
    }
    [vc presentViewController:alertController animated:YES completion:nil];
}
//获取当前时间戳
+ (NSString *)getNowTimeTimestamp{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;

    [formatter setDateStyle:NSDateFormatterMediumStyle];

    [formatter setTimeStyle:NSDateFormatterShortStyle];

    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

    //设置时区,这个对于时间的处理有时很重要

    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];

    [formatter setTimeZone:timeZone];

    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];

    return timeSp;

}
//获取当前的时间
+(NSString*)getCurrentTimes{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];

    //现在时间,你可以输出来看下是什么格式

    NSDate *datenow = [NSDate date];

    //----------将nsdate按formatter格式转成nsstring

    NSString *currentTimeString = [formatter stringFromDate:datenow];


    return currentTimeString;

}
+(NSString*)getCurrentTimesHHSS{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

    [formatter setDateFormat:@"HH:mm"];

    //现在时间,你可以输出来看下是什么格式

    NSDate *datenow = [NSDate date];

    //----------将nsdate按formatter格式转成nsstring

    NSString *currentTimeString = [formatter stringFromDate:datenow];


    return currentTimeString;

}

//model转化为字典
+ (NSDictionary *)dicFromObject:(NSObject *)object {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([object class], &count);
 
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:cName];
        NSObject *value = [object valueForKey:name];//valueForKey返回的数字和字符串都是对象
 
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            //string , bool, int ,NSinteger
            [dic setObject:value forKey:name];
 
        } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            //字典或字典
            [dic setObject:[MethodTool arrayOrDicWithObject:(NSArray*)value] forKey:name];
 
        } else if (value == nil) {
            //null
            //[dic setObject:[NSNull null] forKey:name];//这行可以注释掉?????
 
        } else {
            //model
            [dic setObject:[self dicFromObject:value] forKey:name];
        }
    }
 
    return [dic copy];
}


//将可能存在model数组转化为普通数组
+ (id)arrayOrDicWithObject:(id)origin {
    if ([origin isKindOfClass:[NSArray class]]) {
        //数组
        NSMutableArray *array = [NSMutableArray array];
        for (NSObject *object in origin) {
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [array addObject:object];
 
            } else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [array addObject:[self arrayOrDicWithObject:(NSArray *)object]];
 
            } else {
                //model
                [array addObject:[MethodTool dicFromObject:object]];
            }
        }
 
        return [array copy];
 
    } else if ([origin isKindOfClass:[NSDictionary class]]) {
        //字典
        NSDictionary *originDic = (NSDictionary *)origin;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (NSString *key in originDic.allKeys) {
            id object = [originDic objectForKey:key];
 
            if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
                //string , bool, int ,NSinteger
                [dic setObject:object forKey:key];
 
            } else if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSDictionary class]]) {
                //数组或字典
                [dic setObject:[self arrayOrDicWithObject:object] forKey:key];
 
            } else {
                //model
                [dic setObject:[MethodTool dicFromObject:object] forKey:key];
            }
        }
 
        return [dic copy];
    }
 
    return [NSNull null];
}

+ (NSString *)getName:(NSInteger )index{
    switch (index) {
        case 0:
            return LOCSTR(@"播放满足条件的当前曲目");
            break;
        case 1:
            return LOCSTR(@"播放定时一设置的曲目");
            break;
        case 2:
            return LOCSTR(@"播放定时二设置的曲目");
            break;
        case 3:
            return LOCSTR(@"播放定时三设置的曲目");
            break;
        case 4:
            return LOCSTR(@"播放定时四设置的曲目");
            break;
        case 5:
            return LOCSTR(@"播放定时五设置的曲目");
            break;
        case 6:
            return LOCSTR(@"播放定时六设置的曲目");
            break;
        case 7:
            return LOCSTR(@"播放定时七设置的曲目");
            break;
        default:
            break;
    }
    return LOCSTR(@"播放满足条件的当前曲目");
}

+ (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

/*
 计算文件Hash值   MD5
 */
+ (NSString *)computeHashForFile:(NSURL *)fileURL {
    NSString *fileContentsHash;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        NSData *fileContents = [NSData dataWithContentsOfURL:fileURL];
        fileContentsHash = [self computeHashForData:fileContents];
    }
    return fileContentsHash;
}
+ (NSString *)computeHashForData:(NSData *)inputData {
    uint8_t digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(inputData.bytes, (CC_LONG)inputData.length, digest);
    NSMutableString *inputHash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [inputHash appendFormat:@"%02x", digest[i]];
    }
    return inputHash;
}
+ (NSString *)playModeName:(NSInteger )index{
    switch (index) {
        case 0:
            return LOCSTR(@"感应播放");
            break;
        case 1:
            return LOCSTR(@"仅感应");
            break;
        case 2:
            return LOCSTR(@"仅播放");
            break;
        case 3:
            return LOCSTR(@"广告播放");
            break;
        default:
            break;
    }
    return @"";
}
/**
 *  检测用户输入密码是否以字母开头，8,16位数字和字母组合
 *正则匹配用户密码8,16位数字和字母组合
 *  @param pattern 传入需要检测的字符串
 *
 *  @return 返回检测结果 是或者不是
 */
+(BOOL)detectionIsPasswordQualified:(NSString *)patternStr{
    NSString *pattern = @"^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{8,16}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:patternStr];
    return isMatch;
}

/// 根据token code 判断是否退出登录
+ (void)judgeUserSignoutWithReturnToken:(NSDictionary *)descriptionDic{
                                
    if ([descriptionDic[kCode] isEqual:@(-1000)]) {
        if (descriptionDic[kData] != nil) {
            if (descriptionDic[kData][@"Error"] != nil) {
                NSString *errorMsg = descriptionDic[kData][@"Error"][@"Code"];
                if ([errorMsg isEqualToString:kInvalidParameterValueInvalidAccessToken]) {
                    /// token过期，强制用户退出到登录页面
                    [[TIoTCoreUserManage shared] clear];
                    [TLNotificationCenter postNotificationName:LoginSuccessNotify object:nil];
                }
            }
        }
    }
}

/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)isContainsEmoji:(NSString *)string {
     __block BOOL isEomji = NO;
     [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
      ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
          const unichar hs = [substring characterAtIndex:0];
          if (0xd800 <= hs && hs <= 0xdbff) {
              if (substring.length > 1) {
                  const unichar ls = [substring characterAtIndex:1];
                  const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                  if (0x1d000 <= uc && uc <= 0x1f77f) {
                      isEomji = YES;
                  }
              }
          } else if (substring.length > 1) {
              const unichar ls = [substring characterAtIndex:1];
              if (ls == 0x20e3 || ls == 0xfe0f) {
                  isEomji = YES;
              }
          } else {
              if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                  isEomji = YES;
              } else if (0x2B05 <= hs && hs <= 0x2b07) {
                  isEomji = YES;
              } else if (0x2934 <= hs && hs <= 0x2935) {
                  isEomji = YES;
              } else if (0x3297 <= hs && hs <= 0x3299) {
                  isEomji = YES;
              } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                  isEomji = YES;
              }
          }
      }];
     return isEomji;
 }

#pragma mark - 将某个时间戳转化成 时间

+(NSString *)timestampTime:(NSInteger)timestamp andFormatter:(NSString *)format

{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateStyle:NSDateFormatterMediumStyle];

    [formatter setTimeStyle:NSDateFormatterShortStyle];

    //（@"YYYY-MM-dd hh:mm:ss"）设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

    [formatter setDateFormat:@"YYYY-MM-dd"];

    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];

    [formatter setTimeZone:timeZone];

    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];


    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];

    //NSLog(@"&&&&&&&confromTimespStr = : %@",confromTimespStr);

    return confromTimespStr;

}
@end
