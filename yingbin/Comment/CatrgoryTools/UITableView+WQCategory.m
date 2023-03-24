//
//  UITableView+WQCategory.m
//  yingbin
//
//  Created by slxk on 2021/6/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "UITableView+WQCategory.h"

@implementation UITableView (WQCategory)

- (void)showDataCount:(NSInteger)count Title:(NSString *)title image:(UIImage *)image{
    if (count > 0) {
        self.backgroundView = nil;
        return;
    }
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    
    UIImageView *showImageView = [[UIImageView alloc]init];
    showImageView.contentMode = UIViewContentModeScaleAspectFill;
    [backgroundView addSubview:showImageView];
    
    UILabel *tipLabel = [[UILabel alloc]init];
    tipLabel.font = [UIFont boldSystemFontOfSize:15];
    tipLabel.textColor = KColor999999;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [backgroundView addSubview:tipLabel];
    
    showImageView.image = image;
    tipLabel.text = title;
    ///tipLabel.text = @"网络不可用";
 
    [showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(backgroundView.mas_centerX);
        make.centerY.mas_equalTo(backgroundView.mas_centerY).mas_offset(-20);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(backgroundView.mas_centerX);
        make.top.mas_equalTo(showImageView.mas_bottom).mas_offset(0);
    }];
    
    self.backgroundView = backgroundView;
    

}

@end
