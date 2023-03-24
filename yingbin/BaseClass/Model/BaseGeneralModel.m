//
//  BaseGeneralModel.m
//  yingbin
//
//  Created by slxk on 2021/4/21.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseGeneralModel.h"

@implementation BaseGeneralModel

@end
BaseGeneralModel *createCommonModel(NSInteger tag, id titleModel, id placeholderModel,id value, BOOL select, id type,id model)
{
    BaseGeneralModel *commonModel = [[BaseGeneralModel alloc] init];
    commonModel.tag = tag;
    commonModel.itemName = titleModel;
    commonModel.itemSubName = value;
    commonModel.placeholderName = placeholderModel;
    commonModel.selected = select;
    commonModel.type = type;
    commonModel.model = model;
    return commonModel;
}
