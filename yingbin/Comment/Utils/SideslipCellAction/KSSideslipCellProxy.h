//
//  KSSideslipCellProxy.h
//  yingbin
//
//  Created by slxk on 2021/6/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/**
    代理累，负责拦截tableView与其代理者的事件。关键作用是在有动作时收起扩展按钮
 */
@interface KTSideslipCellProxy : NSProxy<UITableViewDelegate,UIScrollViewDelegate,NSObject>

@property (nonatomic,weak) UITableView *target;

@end

NS_ASSUME_NONNULL_END
