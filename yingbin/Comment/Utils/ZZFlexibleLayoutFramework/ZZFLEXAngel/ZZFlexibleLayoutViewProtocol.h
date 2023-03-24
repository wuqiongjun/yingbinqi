//
//  ZZFlexibleLayoutViewProtocol.h
//  ZZFlexibleLayoutFrameworkDemo
//
//  Created by 李祥 on 2016/12/27.
//  Copyright © 2016年 李祥. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 所有要加入ZZFlexibleLayoutViewController、ZZFLEXAngel的view/cell都要实现此协议
 */

@protocol ZZFlexibleLayoutViewProtocol <NSObject>

@optional;
/**
 * 获取cell/view大小
 */
+ (CGSize)viewSizeByDataModel:(id)dataModel;
/**
 * 获取cell/view高度
 */
+ (CGFloat)viewHeightByDataModel:(id)dataModel;


/**
 *  设置cell/view的数据源
 */
- (void)setViewDataModel:(id)dataModel;

/**
 *  设置cell/view的delegate对象
 */
- (void)setViewDelegate:(id)delegate;

/**
 *  设置cell/view的actionBlock
 */
- (void)setViewEventAction:(id (^)(NSInteger actionType, id data))eventAction;

/**
 * 当前视图的indexPath，所在section元素数（目前仅cell调用）
 */
- (void)viewIndexPath:(NSIndexPath *)indexPath sectionItemCount:(NSInteger)count;


@end
