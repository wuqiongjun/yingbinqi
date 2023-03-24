//
//  BoFangDingShiCell.m
//  yingbin
//
//  Created by slxk on 2021/5/17.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BoFangDingShiCell.h"

@interface BoFangDingShiCell ()

@property (strong, nonatomic)  UILabel *nameLabel;
@property (strong, nonatomic)  UILabel *timeLabel;
@property (strong, nonatomic)  UILabel *dateLabel;
@property (strong, nonatomic)  UISwitch *kaiguanSwitch;
@property (strong, nonatomic)  UILabel *integerLabel;
@property (strong, nonatomic)  UIButton *selectBtn;

@end

@implementation BoFangDingShiCell

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
    
    /*
    self.integerLabel = bgView
    .addLabel(0)
    .font(KFont(11))
    .textColor(KColor999999)
    .textAlignment(NSTextAlignmentCenter)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_offset(5);
        make.top.mas_equalTo(5);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    })
    .view;
    self.integerLabel.layer.cornerRadius = 7.5;
    self.integerLabel.layer.borderWidth = 0.5;
    self.integerLabel.layer.borderColor = KColor999999.CGColor;
*/
    
    
    self.timeLabel = bgView
    .addLabel(0)
    .font(KFont(13))
    .textColor(KColor999999)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_offset(46);
        make.centerY.mas_equalTo(bgView);
    })
    .view;
    
    self.nameLabel = bgView
    .addLabel(0)
    .font(KFont(16))
    .textColor(KColor333333)
    .adjustsFontSizeToFitWidth(YES)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_left);
        make.bottom.mas_equalTo(self.timeLabel.mas_top).offset(-10);
        make.right.mas_offset(-2);
    })
    .view;
    
    UIImageView *image = bgView
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.nameLabel.mas_left).offset(-15);
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
    })
    .view;
    image.image = KImage(@"icon_timing");
        
    self.dateLabel = bgView
    .addLabel(1)
    .font(KFont(13))
    .textColor(KColor999999)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(10);
    })
    .view;
    
    self.kaiguanSwitch = bgView
    .addSwitch(0)
    .onTintColor(KThemeColor)
    .tintColor(UIColor.groupTableViewBackgroundColor)
    .eventBlock(UIControlEventValueChanged, ^(UISwitch *sender) {
        //开关
        STRONG
        if (self.isSwitchClick) {
            self.isSwitchClick(sender, self.model);
        }
        
    })
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(bgView);
    })
    .view;
    
    self.selectBtn = bgView
    .addButton(1)
    .imageSelected(KImage(@"icon_gouxuan"))
    .contentHorizontalAlignment(UIControlContentHorizontalAlignmentLeft)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        //场景勾选
        if (self.isBtnClick) {
            self.isBtnClick(x);
        }
    })
    .masonry(^(MASConstraintMaker *make){
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(bgView);
    })
    .view;
    
}
-(void)setModel:(NSMutableDictionary *)model{
    _model = model;
    _integer = self.integer;
    self.nameLabel.text = model[@"Name"]?:@"";
    self.timeLabel.text = [NSString stringWithFormat:@"%@：%@%@ - %@%@",LOCSTR(@"时间"),_model[@"StartTime"],LOCSTR(@"开启"),_model[@"EndTime"],LOCSTR(@"结束")];
    self.dateLabel.text = [NSString stringWithFormat:@"%@：%@",LOCSTR(@"重复"),[self getShowResultForRepeat:_model[@"Days"]]];
    if (self.fromTimeVCBool) {
        self.kaiguanSwitch.on = [_model[@"Status"] integerValue]==1?YES:NO;
        self.kaiguanSwitch.hidden = NO;
        self.selectBtn.hidden = YES;
    }else{
        self.selectBtn.selected = [_model[@"Status"] integerValue]==1?YES:NO;
        self.kaiguanSwitch.hidden = YES;
        self.selectBtn.hidden = NO;
    }
}
/*
-(void)setInteger:(NSInteger)integer{
    _integer = integer;
    self.integerLabel.text = [NSString stringWithFormat:@"%ld",integer];
}
*/
- (NSString *)getShowResultForRepeat:(NSString *)days
{
    const char *repeats = [days UTF8String];
    
    NSString *con = @"";
    
    if ((BOOL)(repeats[1] - '0') == NO && (BOOL)(repeats[2] - '0') == NO && (BOOL)(repeats[3] - '0') == NO && (BOOL)(repeats[4] - '0') == NO && (BOOL)(repeats[5] - '0') == NO && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con = NSLocalizedString(@"周末", nil);
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') == NO && (BOOL)(repeats[0] - '0') == NO) {
        con = NSLocalizedString(@"工作日", nil);
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con =NSLocalizedString(@"每天", nil);
    }
    else
    {
        
        for (unsigned int i = 0; i < 7; i ++) {
            if ((BOOL)(repeats[i] - '0')) {
                NSString *weakday = @"";
                switch (i) {
                    case 0:
                        weakday = NSLocalizedString(@"周日", nil);
                        break;
                    case 1:
                        weakday = NSLocalizedString(@"周一", nil) ;
                        break;
                    case 2:
                        weakday = NSLocalizedString(@"周二", nil);
                        break;
                    case 3:
                        weakday = NSLocalizedString(@"周三", nil);
                        break;
                    case 4:
                        weakday = NSLocalizedString(@"周四", nil);
                        break;
                    case 5:
                        weakday = NSLocalizedString(@"周五", nil);
                        break;
                    case 6:
                        weakday = NSLocalizedString(@"周六", nil);
                        break;

                    default:
                        break;
                }

                con = [NSString stringWithFormat:@"%@ %@",con,weakday];
            }
        }
    }
    
    return con;
}
@end
