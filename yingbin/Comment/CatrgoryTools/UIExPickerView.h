//
//  UIExPickerView.h
//  yingbin
//
//  Created by slxk on 2021/5/17.
//  Copyright © 2021 wq. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol pickerDelegate <NSObject>
- (void)selectIndex:(NSInteger)index title:(NSString *)title devModel:(DeviceViewModel *)model;
@end

@interface UIExPickerView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) NSMutableArray       *arr;
@property (nonatomic, strong) NSString             *titleStr;
@property (nonatomic, assign) NSInteger            indexSelect;
@property (nonatomic, weak) id <pickerDelegate>     delegate;

@property (nonatomic, assign) NSInteger            getIndexSelect;

@property (nonatomic, strong) DeviceViewModel *model;

/*  初始化方法
    frame ：选择框的frame
    arrData ： 要展示的数据
*/
- (instancetype)initWithFrame:(CGRect)frame titleStr:(NSString *)titleStr indexSelect:(NSInteger)getIndexSelect arr:(NSArray *)arrData devModel:(DeviceViewModel *)model;

@end

NS_ASSUME_NONNULL_END
