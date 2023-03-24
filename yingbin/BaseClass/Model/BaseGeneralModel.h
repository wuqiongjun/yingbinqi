//
//  BaseGeneralModel.h
//  yingbin
//
//  Created by slxk on 2021/4/21.
//  Copyright © 2021 wq. All rights reserved.
//

#import <Foundation/Foundation.h>

#define titleKey @"itemName"
#define subTitleKey @"itemSubName"
#define imgNameKey @"itemImageName"
#define imgSelectNameKey @"itemSelectImageName"
#define selectType @"type"
#define selectedKey @"selected"
#define titleColorKey @"itemNameColor"
#define titleSelectColorKey @"itemSelectNameColor"
#define placeholderKey @"placeholderName"
#define tagKey @"tag"

NS_ASSUME_NONNULL_BEGIN

@interface BaseGeneralModel : NSObject

KCOPY NSString *itemName;
KCOPY NSString *itemSubName;
KCOPY NSString *itemImageName;
KCOPY NSString *itemSelectImageName;
KSTRONG UIColor *itemNameColor;
KSTRONG UIColor *itemSelectNameColor;
KSTRONG NSNumber *type;
KASSIGN BOOL selected;
KASSIGN NSInteger tag;
KCOPY NSString *placeholderName;
KCOPY NSString *placeholder;
KCOPY NSString *phone;
KSTRONG NSNumber *amount;
KASSIGN NSInteger width;

KSTRONG id model;

@end

BaseGeneralModel *createCommonModel(NSInteger tag, id titleModel, id placeholderModel,id value, BOOL select, id type,id model);


NS_ASSUME_NONNULL_END
