//
//  UIExPickerView.m
//  yingbin
//
//  Created by slxk on 2021/5/17.
//  Copyright © 2021 wq. All rights reserved.
//

#import "UIExPickerView.h"

@implementation UIExPickerView

- (instancetype)initWithFrame:(CGRect)frame titleStr:(NSString *)titleStr indexSelect:(NSInteger)getIndexSelect arr:(NSArray *)arrData devModel:(DeviceViewModel *)model
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        self.arr = [[NSMutableArray alloc ] initWithArray:arrData];
        self.titleStr = titleStr;
        self.getIndexSelect = getIndexSelect;
        self.indexSelect = getIndexSelect;
        self.model = model;
        [self initCtrl:frame];
    }
    return self;
}
-(void)initCtrl:(CGRect)frame
{
    UIView *BGView = [[UIView alloc]init];
    if ([self.titleStr containsString:LOCSTR(@"播放模式设置")]) {
        BGView.frame = CGRectMake(0, KScreenH-k_Height_TabBar-270, KScreenW, 270);
        
    }else{
        BGView.frame = CGRectMake(0, KScreenH-k_Height_NavBar-270, KScreenW, 270);
        
    }
    BGView.backgroundColor = UIColor.whiteColor;
    [self addSubview:BGView];
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
    bgView.backgroundColor = KThemeColor;
    [BGView addSubview:bgView];
    
    
    UIButton *btnCancel = [[UIButton alloc ] initWithFrame:CGRectMake(15, 5, 50, 30)];
    [btnCancel setTitle:LOCSTR(@"取消") forState:UIControlStateNormal];
    [btnCancel setTitleColor:KThemeColor forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:(15)];
    [btnCancel setBackgroundColor:[UIColor whiteColor]];
    btnCancel.layer.cornerRadius = 13;
    [btnCancel addTarget:self action:@selector(onButtonCancel) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btnCancel];
    
    UIButton *btnFinish = [[UIButton alloc ] initWithFrame:CGRectMake(frame.size.width-50-15, 5, 50, 30)];
    [btnFinish setTitle:LOCSTR(@"确定") forState:UIControlStateNormal];
    [btnFinish setTitleColor:KThemeColor forState:UIControlStateNormal];
    btnFinish.titleLabel.font = [UIFont systemFontOfSize:(15)];
    [btnFinish setBackgroundColor:[UIColor whiteColor]];
    btnFinish.layer.cornerRadius = 13;
    [btnFinish addTarget:self action:@selector(onButtonFinish) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btnFinish];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15+50, 0, frame.size.width-2*50-2*15, 40)];
    titleLabel.text = self.titleStr;
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:(16)];
    [bgView addSubview:titleLabel];
    
    UIPickerView *pickerView = [[UIPickerView alloc ] initWithFrame:CGRectMake(5, 40, KScreenW-10, 270-40)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    [pickerView selectRow:self.getIndexSelect inComponent:0 animated:YES];
    [BGView addSubview:pickerView];
    
}

-(void)onButtonCancel
{
    if (self)
    {
        [self removeFromSuperview];
    }
}

-(void)onButtonFinish
{
    if ([self.delegate respondsToSelector:@selector(selectIndex:title:devModel:)]) {
        [self.delegate selectIndex:_indexSelect title:self.titleStr devModel:self.model];
    }
    //点击完成后，关闭当前view
    [self onButtonCancel];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.arr objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    _indexSelect = row;

}

@end
