//
//  ChangjingViewCell.m
//  yingbin
//
//  Created by slxk on 2021/4/23.
//  Copyright © 2021 wq. All rights reserved.
//

#import "ChangjingViewCell.h"

@interface ChangjingViewCell ()
@property (strong, nonatomic)  UILabel *nameLabel;
@property (strong, nonatomic)  UIButton *nameContentButton;
@property (strong, nonatomic)  UISwitch *kaiguanSwitch;

@end

@implementation ChangjingViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self setupUI];
    }
    return self;
}
-(void)setupUI{
    WEAK
    UIView *bgView = self.contentView
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(10);
    })
    .view;
    bgView.layer.cornerRadius = 10;
    
    self.nameLabel = bgView
    .addLabel(0)
    .font(KBFont(15))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(23);
        make.centerY.mas_equalTo(bgView.mas_centerY);
    })
    .view;
    
    self.nameContentButton = bgView
    .addButton(1)
    .titleFont(KFont(10))
    .hidden(YES)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
//        STRONG
        //手动执行
        
    })
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(5);
    })
    .view;
    [self.nameContentButton setTitle:LOCSTR(@"手动执行") forState:UIControlStateNormal];
    [self.nameContentButton setTitleColor:[UIColor colorWithRed:255/255.0 green:102/255.0 blue:48/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    self.kaiguanSwitch = bgView
    .addSwitch(0)
    .onTintColor(KThemeColor)
    .tintColor(UIColor.groupTableViewBackgroundColor)
    .eventBlock(UIControlEventValueChanged, ^(UISwitch *sender) {
        //开关
        STRONG
        if (self.isSwitchSuccess) {
            self.isSwitchSuccess(sender, self.dataDic);
        }

    })
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(bgView);
    })
    .view;
}
//{
//    AutomationId = "a_8df6d87902794523a28928a83b71fbc9";
//    Icon = "https://main.qcloudimg.com/raw/9c04afe82f2d18448efa45e239ee1244/scene6.jpg";
//    Name = hjj;
//    Status = 0;
//}
-(void)setDataDic:(NSDictionary *)dataDic{
    _dataDic = dataDic;
    self.nameLabel.text = dataDic[@"Name"];
    if (self.dataDic[@"Status"] != nil) {
        NSString *statusStr = [NSString stringWithFormat:@"%@",self.dataDic[@"Status"]];
        
        if (statusStr.intValue == 0) {
            [self.kaiguanSwitch setOn:NO];
        }else if (statusStr.intValue == 1) {
            [self.kaiguanSwitch setOn:YES];
        }
    }
}

@end
