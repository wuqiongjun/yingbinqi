//
//  CoreArchiveHeader.h
//  KUSDOM
//
//  Created by 李祥 on 2017/12/8.
//  Copyright © 2017年 KUSDOM. All rights reserved.
//

#ifndef CoreArchiveHeader_h
#define CoreArchiveHeader_h
/** 自动存储宏定义 */
#define CoreArchiver_SingCACHE_PATH(name) [[NSString cachesFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.arc",name]]

#define CoreArchiver_ArrayCACHE_PATH(name) [[NSString cachesFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"Array%@.arc",name]]
// .h
#define CoreArchiver_MODEL_H \
+(BOOL)saveSingleModel:(id)model forKey:(NSString *)key;\
+(instancetype)readSingleModelForKey:(NSString *)key;\
+(BOOL)saveListModel:(NSArray *)ListModel forKey:(NSString *)key;\
+(NSArray *)readListModelForKey:(NSString *)key;\

// .m
#define CoreArchiver_MODEL_M \
MJCodingImplementation\
+(BOOL)saveSingleModel:(id)model forKey:(NSString *)key{\
NSString *pathKey = key==nil?NSStringFromClass(self):key;\
return [CoreArchive archiveRootObject:model toFile:CoreArchiver_SingCACHE_PATH(pathKey)];\
}\
+(instancetype)readSingleModelForKey:(NSString *)key{\
NSString *pathKey = key==nil?NSStringFromClass(self):key;\
return [CoreArchive unarchiveObjectWithFile:CoreArchiver_SingCACHE_PATH(pathKey)];\
}\
+(BOOL)saveListModel:(NSArray *)ListModel forKey:(NSString *)key{\
NSString *pathKey = key==nil?NSStringFromClass(self):key;\
return [CoreArchive archiveRootObject:ListModel toFile:CoreArchiver_ArrayCACHE_PATH(pathKey)];\
}\
+(NSArray *)readListModelForKey:(NSString *)key{\
NSString *pathKey = key==nil?NSStringFromClass(self):key;\
return [CoreArchive unarchiveObjectWithFile:CoreArchiver_ArrayCACHE_PATH(pathKey)];\
}\


// .h
#define singleton_interface(class) + (instancetype)shared##class;

// .m
#define singleton_implementation(class) \
static class *_instance; \
\
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
\
return _instance; \
} \
\
+ (instancetype)shared##class \
{ \
if (_instance == nil) { \
_instance = [[class alloc] init]; \
} \
\
return _instance; \
}\


#endif /* CoreArchiveHeader_h */
