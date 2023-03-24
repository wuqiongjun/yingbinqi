//
//  ZZTableViewChainModel.m
//  zhuanzhuan
//
//  Created by 李祥 on 2017/10/24.
//  Copyright © 2017年 KUSDOM. All rights reserved.
//

#import "ZZTableViewChainModel.h"

#define     ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(methodName, ZZParamType)      ZZFLEX_CHAIN_IMPLEMENTATION(methodName, ZZParamType, ZZTableViewChainModel *, UITableView)
#define     ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(methodName, ZZParamType)      ZZFLEX_CHAIN_IMPLEMENTATION(methodName, ZZParamType, ZZTableViewChainModel *, UITableView)

@implementation ZZTableViewChainModel

ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(delegate, id<UITableViewDelegate>)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(dataSource, id<UITableViewDataSource>)

ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(rowHeight, CGFloat)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(sectionHeaderHeight, CGFloat)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(sectionFooterHeight, CGFloat)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(estimatedRowHeight, CGFloat)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(estimatedSectionHeaderHeight, CGFloat)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(estimatedSectionFooterHeight, CGFloat)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(separatorInset, UIEdgeInsets)


ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(editing, BOOL)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(allowsSelection, BOOL)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(allowsMultipleSelection, BOOL)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(allowsSelectionDuringEditing, BOOL)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(allowsMultipleSelectionDuringEditing, BOOL)

ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(separatorStyle, UITableViewCellSeparatorStyle)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(separatorColor, UIColor *)

ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(tableHeaderView, UIView *)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(tableFooterView, UIView *)

ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(sectionIndexBackgroundColor, UIColor *)
ZZFLEX_CHAIN_TABLEVIEW_IMPLEMENTATION(sectionIndexColor, UIColor *)

#pragma mark - UIScrollView
ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(contentSize, CGSize)
ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(contentOffset, CGPoint)
ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(contentInset, UIEdgeInsets)

ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(bounces, BOOL)
ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(alwaysBounceVertical, BOOL)
ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(alwaysBounceHorizontal, BOOL)

ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(pagingEnabled, BOOL)
ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(scrollEnabled, BOOL)

ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(showsHorizontalScrollIndicator, BOOL)
ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(showsVerticalScrollIndicator, BOOL)

ZZFLEX_CHAIN_SCROLLVIEW_IMPLEMENTATION(scrollsToTop, BOOL)

@end

ZZFLEX_EX_IMPLEMENTATION(UITableView, ZZTableViewChainModel)
