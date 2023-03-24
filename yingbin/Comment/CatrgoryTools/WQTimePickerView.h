//
//  WQTimePickerView.h
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol TimePickerViewDelegate<NSObject>
@optional

//通过协议将选中的时间返回
-(void)timePickerViewDidSelectRow:(NSString *)Hour MIN:(NSString *)min tag:(NSString *)tag;

@end

@interface WQTimePickerView : UIView

@property (nonatomic, weak) id<TimePickerViewDelegate> delegate;

@property (nonatomic, copy) NSString *selectedHour;

@property (nonatomic, copy) NSString *selectedMin;


/**
 初始化方法
 
 @param startHour 其实时间点 时
 @param endHour 结束时间点 时
 @param period 间隔多少分中
 @return QFTimePickerView实例
 */
- (instancetype)initDatePackerWithStartHour:(NSString *)startHour endHour:(NSString *)endHour period:(NSInteger)period selectedHour:(NSString *)selectedHour selectedMin:(NSString *)selectedMin tag:(NSString *)tag title:(NSString *)nameTitle;

- (void)show;

@end

NS_ASSUME_NONNULL_END
