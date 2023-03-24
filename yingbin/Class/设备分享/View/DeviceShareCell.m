//
//  DeviceShareCell.m
//  yingbin
//
//  Created by slxk on 2021/5/15.
//  Copyright © 2021 wq. All rights reserved.
//

#import "DeviceShareCell.h"
#import <UIImageView+WebCache.h>

@interface DeviceShareCell ()

@property (nonatomic, strong) UIImageView *avatarImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *cancelShareBtn;

@end

@implementation DeviceShareCell

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
    
    self.avatarImage = bgView
    .addImageView(0)
    .userInteractionEnabled(YES)
    .cornerRadius(5)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(bgView);
        make.size.mas_equalTo(40);
    })
    .view;
    
    self.nameLabel = bgView
    .addLabel(0)
    .font(KBFont(15))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatarImage.mas_right).mas_offset(10);
//        make.bottom.mas_equalTo(self.avatarImage.mas_centerY).mas_offset(-5);
        make.centerY.mas_equalTo(bgView.mas_centerY);
        make.right.mas_equalTo(-15);
    })
    .view;
    
//    self.phoneLabel = bgView
//    .addLabel(1)
//    .font(KFont(15))
//    .textColor(UIColor.blackColor)
//    .masonry(^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.avatarImage.mas_right).mas_offset(10);
//        make.top.mas_equalTo(self.avatarImage.mas_top);
//    })
//    .view;
    
//    self.timeLabel = bgView
//    .addLabel(1)
//    .font(KFont(12))
//    .textColor(KColor999999)
//    .numberOfLines(0)
//    .masonry(^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-15);
//        make.top.mas_equalTo(self.phoneLabel.mas_bottom).mas_offset(5);
//    })
//    .view;
    
    self.cancelShareBtn = bgView
    .addButton(1)
    .title(LOCSTR(@"取消分享"))
    .titleColor(KThemeColor)
    .titleFont(KFont(14))
//    .hidden(YES)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
    STRONG
        if (self.CancelShareBtnBlock) {
            self.CancelShareBtnBlock(x);
        }
        
    })
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(90, 30));
    })
    .view;
    

}
//{
//  "UserId": "1",
//  "CountryCode": "86",
//  "PhoneNumber": "139****5678",
//  "NickName": "tests",
//  "Avatar": "",
//  "BindTime": 1574153536
//}
-(void)setDataDic:(NSMutableDictionary *)dataDic{
    _dataDic = dataDic;
    [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:dataDic[@"Avatar"]] placeholderImage:[UIImage imageNamed:@"icon_morentouxiang"]];
//    self.phoneLabel.text = [NSString stringWithFormat:@"%@",[dataDic[@"NickName"] substringFromIndex:9]?:@""];

    self.nameLabel.text = dataDic[@"NickName"]?:@"";
//    self.timeLabel.text = [NSString convertTimestampToTime:dataDic[@"BindTime"]?:@"" byDateFormat:@"yyyy-MM-dd HH:mm"];
}
-(void)setModel:(DeviceViewModel *)model{
    _model = model;
    if ([MethodTool isBlankString:_model.FamilyId]) {
        self.cancelShareBtn.hidden = YES;
    }
}

@end
