//
//  WQTimePickerView.m
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "WQTimePickerView.h"

@interface WQTimePickerView () <UIPickerViewDataSource,UIPickerViewDelegate>{
    UIView *contentView;
    
    NSMutableArray *hourArray;
    NSMutableArray *minArray;
    NSInteger currentHour;
    NSInteger currentMin;
    NSString *restr;
    
    //NSString *selectedHour;
    //NSString *selectedMin;
}

@property (nonatomic, assign) NSString *startTime;
@property (nonatomic, assign) NSString *endTime;
@property (nonatomic, assign) NSInteger period;

@property (nonatomic, assign) NSString *tagStr;
@property (nonatomic, assign) NSString *titleStr;


@end

@implementation WQTimePickerView

/**
 初始化方法
 
 @param startHour 其实时间点 时
 @param endHour 结束时间点 时
 @param period 间隔多少分中
 @return QFTimePickerView实例
 */
- (instancetype)initDatePackerWithStartHour:(NSString *)startHour endHour:(NSString *)endHour period:(NSInteger)period selectedHour:(NSString *)selectedHour selectedMin:(NSString *)selectedMin tag:(NSString *)tag title:(NSString *)nameTitle{
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
    }
    _startTime = startHour;
    _endTime = endHour;
    _period = period;
    _selectedHour = selectedHour;
    _selectedMin = selectedMin;
    _tagStr = tag;
    _titleStr = nameTitle;
    
    [self initDataSource];
    [self initAppreaence];
    
    return self;
}

#pragma mark - initDataSource
- (void)initDataSource {
    
    [self configHourArray];
    [self configMinArray];
    
    _selectedHour = _selectedHour ? _selectedHour : hourArray[0];
    _selectedMin = _selectedMin ? _selectedMin : minArray[0];
}

- (void)configHourArray {//配置小时数据源数组
    //初始化小时数据源数组
    hourArray = [[NSMutableArray alloc]init];
    
    NSString *startHour = [_startTime substringWithRange:NSMakeRange(0, 2)];
    NSString *endHour = [_endTime substringWithRange:NSMakeRange(0, 2)];
    
    if ([startHour integerValue] > [endHour integerValue]) {//跨天
        NSString *minStr = @"";
        for (NSInteger i = [startHour integerValue]; i < 24; i++) {//加当天的小时数
            if (i < 10) {
                minStr = [NSString stringWithFormat:@"0%ld",i];
            } else {
                minStr = [NSString stringWithFormat:@"%ld",i];
            }
            [hourArray addObject:minStr];
        }
        for (NSInteger i = 0; i <= [endHour integerValue]; i++) {//加次天的小时数
            if (i < 10) {
                minStr = [NSString stringWithFormat:@"0%ld",i];
            } else {
                minStr = [NSString stringWithFormat:@"%ld",i];
            }
            [hourArray addObject:minStr];
        }
    } else {
        for (NSInteger i = [startHour integerValue]; i < [endHour integerValue]; i++) {//加小时数
            NSString *minStr = @"";
            if (i < 10) {
                minStr = [NSString stringWithFormat:@"0%ld",i];
            } else {
                minStr = [NSString stringWithFormat:@"%ld",i];
            }
            [hourArray addObject:minStr];
        }
    }
}

- (void)configMinArray {//配置分钟数据源数组
    minArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 1 ; i <= 60; i++) {
        NSString *minStr = @"";
        if (i % _period == 0) {
            if (i < 10) {
                minStr = [NSString stringWithFormat:@"0%ld",(long)i];
            } else {
                minStr = [NSString stringWithFormat:@"%ld",(long)i];
            }
            [minArray addObject:minStr];
        }
    }
    [minArray insertObject:@"00" atIndex:0];
    [minArray removeLastObject];
}

#pragma mark - initAppreaence
- (void)initAppreaence {
    
    self->contentView = [[UIView alloc] initWithFrame:CGRectMake(12, self.frame.size.height, self.frame.size.width-24, 300)];
    contentView.layer.cornerRadius = 9;
    contentView.backgroundColor = UIColor.whiteColor;
    [self addSubview:contentView];
    //设置背景颜色为黑色，并有0.4的透明度
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    //添加白色view
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 250, contentView.frame.size.width, 50)];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.layer.cornerRadius = 9;
    [contentView addSubview:whiteView];


    //添加确定和取消按钮
    for (int i = 0; i < 2; i ++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((contentView.frame.size.width/2) * i, 0, contentView.frame.size.width/2, 50)];
        [button setTitle:i == 0 ? @"取消" : @"保存" forState:UIControlStateNormal];
        if (i == 0) {
            [button setTitleColor:[UIColor colorWithRed:102.0 / 255.0 green:102.0 / 255.0 blue:102.0 / 255.0 alpha:1] forState:UIControlStateNormal];
        } else {
            [button setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
        [whiteView addSubview:button];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 10 + i;
    }
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 25, contentView.frame.size.width, 240)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = UIColor.whiteColor;
    pickerView.layer.cornerRadius = 9;

    
    /*
     设置pickerView默认第一行 这里也可默认选中其他行 修改selectRow即可
     如果后台传过来的不是整点需要特殊处理
     */
    
    NSString *hour = [NSString stringWithFormat:@"%@",_selectedHour];
    NSString *minute = [NSString stringWithFormat:@"%@",_selectedMin];
    
    [pickerView selectRow:[self minuteIndex:hour minute:minute] inComponent:1 animated:YES];
    [pickerView selectRow:[self hourIndex:hour minute:minute] inComponent:0 animated:YES];
    
    
    [contentView addSubview:pickerView];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 250, contentView.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
    [contentView addSubview:lineView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(contentView.frame.size.width/2, 250, 0.5, 50)];
    line.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
    [contentView addSubview:line];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 12, contentView.frame.size.width, 20)];
    title.text = _titleStr;
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = KColor666666;
    title.font = KFont(14);
    [contentView addSubview:title];
    
    //在时间选择器上 - 时分
//    NSArray * labelArr = @[@"时",@"分"];
//    for (int i = 0; i < 2; i++) {
//        UILabel * label = [[UILabel alloc] init];
//        if (i==0) {
//            label.frame = CGRectMake(KScreenW/4+30, 240/2-15, 30, 30);
//        }else{
//            label.frame = CGRectMake(KScreenW/4*2+70, 240/2-15, 30, 30);
//        }
//        label.text = labelArr[i];
//        label.font = [UIFont systemFontOfSize:20];
//        label.textColor = [UIColor blackColor];
//        [pickerView addSubview:label];
//        label.textAlignment = NSTextAlignmentCenter;
//        //label.backgroundColor = [UIColor orangeColor];
//    }
}

//获取小时的下标
-(NSInteger)hourIndex:(NSString *)hour minute:(NSString *)minute{
    
    //判断分钟是否大于分钟数组的最后一个元素值，如果大则小时+1分钟归0
    NSInteger hourAdd = [minute integerValue] > [minArray[minArray.count-1] integerValue] ? 1 : 0;
    
    NSInteger index = [hourArray indexOfObject:hour] + hourAdd;
    index = index > hourArray.count-1 ? 0 : index;
    _selectedHour = hourArray[index];
//    NSLog(@"hourIndex - %ld",(long)index);
    return index;
}

//获取分钟的下标
-(NSInteger)minuteIndex:(NSString *)hour minute:(NSString *)minute{
    
    NSInteger index = 0;
    if ([minArray containsObject:minute]) {
        index = [minArray indexOfObject:minute];
    }else{
        
        if ([minute integerValue] > [minArray[minArray.count-1] integerValue]) {
            index = 0;
        }else{
            for (NSInteger i=(minArray.count-2); i<minArray.count-1; i--) {
                
                if ([minute integerValue] > [minArray[i] integerValue]) {
                    index = i + 1;
                    _selectedMin = minArray[index];
//                    NSLog(@"minIndex - %ld",(long)index);
                    return index;
                }
            }
        }
    }
    _selectedMin = minArray[index];
//    NSLog(@"minIndex - %ld",(long)index);
    return index;
}

#pragma mark - Actions
- (void)buttonTapped:(UIButton *)sender {
    if (sender.tag == 10) {
        [self dismiss];
    } else {
        
        restr = [NSString stringWithFormat:@"%@:%@",_selectedHour,_selectedMin];
        
        if ([self.delegate respondsToSelector:@selector(timePickerViewDidSelectRow:MIN:tag:)]) {
            [self.delegate timePickerViewDidSelectRow:_selectedHour MIN:_selectedMin tag:_tagStr];
        }
        [self dismiss];
    }
}

#pragma mark - pickerView出现
- (void)show {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.4 animations:^{
        self->contentView.center = CGPointMake(self.frame.size.width/2, self->contentView.center.y - self->contentView.frame.size.height-k_Height_SafetyArea-15);
    }];
}

#pragma mark - pickerView消失
- (void)dismiss{
    
    [UIView animateWithDuration:0.4 animations:^{
        self->contentView.center = CGPointMake(self.frame.size.width/2, self->contentView.center.y + self->contentView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return hourArray.count;
    }
    else {
        return minArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return hourArray[row];
    } else {
        return minArray[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        _selectedHour = hourArray[row];

        [pickerView reloadComponent:1];
        
    } else {

        _selectedMin = minArray[row];
    }
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 30;
}

-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenW/2, 30)];
    //添加一个label
    UILabel * label = [[UILabel alloc] init];
    
    if (component == 0) {
        label.frame = CGRectMake(KScreenW/4, 0, 50, 30);
    }else{
        label.frame = CGRectMake(40, 0, 50, 30);
    }
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:20];
    label.textAlignment = NSTextAlignmentCenter;
//    bg.backgroundColor = [UIColor redColor];
    if (component == 0){
        label.text = [NSString stringWithFormat:@"%@%@",hourArray[row],LOCSTR(@"时")];
    }else{
        label.text = [NSString stringWithFormat:@"%@%@",minArray[row],LOCSTR(@"分")];
    }
    
    [bg addSubview:label];
    
    return bg;
}

@end
