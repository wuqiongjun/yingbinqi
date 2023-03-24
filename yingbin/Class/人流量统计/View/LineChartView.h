//
//  LineChartView.h
//  yingbin
//
//  Created by slxk on 2021/8/9.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LineChartView : UIView

- (id)initWithFrame:(CGRect)frame xTitleArray:(NSArray*)xTitleArray yValueArray:(NSArray*)yValueArray yMax:(CGFloat)yMax yMin:(CGFloat)yMin;

@end

NS_ASSUME_NONNULL_END
