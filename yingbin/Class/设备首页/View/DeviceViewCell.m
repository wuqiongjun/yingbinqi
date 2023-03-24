//
//  DeviceViewCell.m
//  yingbin
//
//  Created by slxk on 2021/4/22.
//  Copyright © 2021 wq. All rights reserved.
//

#import "DeviceViewCell.h"

@interface DeviceViewCell ()
@property (nonatomic, strong) UIImageView *iconUrl;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *flowImageView;
@property (nonatomic, strong) UILabel *flowLabel;
@property (strong, nonatomic) UIButton *ganyingButton;
@property (strong, nonatomic) UIButton *bofangButton;
@property (strong, nonatomic) UIButton *setButton;

@end

@implementation DeviceViewCell


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
    
    self.iconUrl = bgView
    .addImageView(0)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(23);
        make.size.mas_equalTo(CGSizeMake(25, 38));
    })
    .view;
    
    //人流量
    self.flowLabel = bgView
    .addLabel(0)
    .font(KFont(12))
    .textColor(KColor4F4F4)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconUrl.mas_centerY);
        make.right.mas_equalTo(-25);
    })
    .view;
    
    self.flowImageView = bgView
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconUrl.mas_centerY);
        make.right.mas_equalTo(self.flowLabel.mas_left).mas_offset(-5);
        make.size.mas_equalTo(12);
    })
    .view;
    
    self.nameLabel = bgView
    .addLabel(0)
    .font(KBFont(16))
    .textColor(KColor333333)
    .textAlignment(NSTextAlignmentLeft)
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconUrl.mas_centerY);
        make.left.mas_equalTo(self.iconUrl.mas_right).mas_offset(20);
        make.right.mas_lessThanOrEqualTo(self.flowImageView.mas_right).mas_offset(-10);
    })
    .view;
    
    
    UILabel *line = bgView
    .addLabel(2)
    .masonry(^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(bgView.mas_bottom).mas_offset(-40);
        make.right.left.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    })
    .view;
    line.backgroundColor = KColorE5E5E5;
    

    self.bofangButton = bgView
    .addButton(1)
    .titleFont(KFont(12))
    .title(LOCSTR(@"播放"))
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        //播放
        if (self.model.Online == 1) {
            btn.selected = !btn.selected;
            if (self.isButtonClick) {
                self.isButtonClick(btn, 0);
            }
        }else{
            self.isButtonClick(btn, 3);
        }
    })
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView.mas_centerX);
        make.bottom.mas_equalTo(bgView);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    })
    .view;
    [self.bofangButton layoutButtonWithImageStyle:ZJButtonImageStyleLeft imageTitleToSpace:10];
    
    self.ganyingButton = bgView
    .addButton(1)
    .titleFont(KFont(12))
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        //切换感应播放
        if (self.model.Online == 1) {
            if (self.isButtonClick) {
                self.isButtonClick(btn, 2);
            }
        }else{
            self.isButtonClick(btn, 3);
        }
    })
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(bgView);
        make.size.mas_equalTo(CGSizeMake(70, 40));
    })
    .view;
    [self.ganyingButton layoutButtonWithImageStyle:ZJButtonImageStyleLeft imageTitleToSpace:10];
    
    self.setButton = bgView
    .addButton(1)
    .titleFont(KFont(12))
    .title(LOCSTR(@"设置"))
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        //设置
        if (self.model.Online == 1) {
            if (self.isButtonClick) {
                self.isButtonClick(btn, 1);
            }
        }else{
            self.isButtonClick(btn, 3);
        }
    })
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-13);
        make.bottom.mas_equalTo(bgView);
        make.size.mas_equalTo(CGSizeMake(70, 40));
    })
    .view;
    [self.setButton layoutButtonWithImageStyle:ZJButtonImageStyleLeft imageTitleToSpace:10];
    
}
//   shareDataArr {
//                AliasName = light;
//                CreateTime = "2021-05-14T16:23:54+08:00";
//                DeviceId = "56UED5AJ29/dev0001";
//                DeviceName = dev0001;
//                DeviceType = 0;
//                FromUserID = 249555369632731136;
//                GatewayDeviceId = "";
//                IconUrl = "https://main.qcloudimg.com/raw/1c69eb04f93e925436a3ee9d4896068e.png";
//                IconUrlGrid = "https://main.qcloudimg.com/raw/1c69eb04f93e925436a3ee9d4896068e.png";
//                Online = 1;
//                ProductId = 56UED5AJ29;
//                UserID = 250921057949585408;
//            }
//self.deviceList[{
//    AliasName = light;
//    CreateTime = 1619594915;
//    DeviceId = "56UED5AJ29/dev0001";
//    DeviceName = dev0001;
//    FamilyId = "f_2e6bd3c9824c497588fdce1c5ce48d6f";
//    IconUrl = "https://main.qcloudimg.com/raw/1c69eb04f93e925436a3ee9d4896068e.png";
//    Online = 1;
//    ProductId = 56UED5AJ29;
//    RoomId = 0;
//    UpdateTime = 1619594915;
//    UserID = 249555369632731136;
//
//}]
-(void)setModel:(DeviceViewModel *)model{
    _model = model;
    NSString * alias = model.AliasName;
    if (![MethodTool isBlankString:alias]) {
        self.nameLabel.text = model.AliasName;
    }
    else
    {
        self.nameLabel.text = model.DeviceName;
    }
    
    if ([[model.deviceSetInfo allKeys] containsObject:@"PlayMode"]) {
        NSString *playMode = [MethodTool playModeName:[model.deviceSetInfo[@"PlayMode"][@"Value"] integerValue]];
        [self.ganyingButton setTitle:playMode forState:UIControlStateNormal];
    }
    
    



    self.iconUrl.image  = KImage(@"icon_devimage");
    
    if (model.Online == 1) {
        self.flowImageView.hidden = NO;
        self.flowImageView.image = KImage(@"icon_my_zaixian");
        [self.ganyingButton setImage:KImage(@"icon_bianji_zaixian") forState:UIControlStateNormal];
        [self.ganyingButton setTitleColor:KColor4F4F4 forState:UIControlStateNormal];
        [self.bofangButton setImage:KImage(@"icon_bofang_zaixian") forState:UIControlStateNormal];
        [self.bofangButton setTitleColor:KColor4F4F4 forState:UIControlStateNormal];
        [self.setButton setImage:KImage(@"icon_set_zaixian") forState:UIControlStateNormal];
        [self.setButton setTitleColor:KColor4F4F4 forState:UIControlStateNormal];
        
        if ([[model.deviceSetInfo allKeys] containsObject:@"Counter"]) {
            //前一天的结束时间（手机本地时间和更新时间对比。更新时间小于上一天的 23：59：59  统计清零）
            NSDate *par = [NSDate backward:-1 date:[NSDate dateWithString:[MethodTool getCurrentTimes] format:@"yyyy-MM-dd HH:mm:ss"] unitType:NSCalendarUnitDay];
            NSString *yesterday = [NSString stringWithFormat:@"%@ 23:59:59",[NSDate stringWithDate:par format:@"yyyy-MM-dd"]];
            NSString *counter =  [NSDate timeStringFromTimestamp:[model.deviceSetInfo[@"Counter"][@"LastUpdate"] doubleValue] formatter:@"yyyy-MM-dd HH:mm:ss"];
        //    NSOrderedAscending     => (dateString1 < dateString2)
        //    NSOrderedDescending    => (dateString1 > dateString2)
        //    NSOrderedSame          => (dateString1 = dateString2)
            NSComparisonResult type = [NSDate compareDateString1:yesterday dateString2:counter formatter:@"yyyy-MM-dd HH:mm:ss"];
            if (type == NSOrderedDescending) {
                self.flowLabel.text = @"0";
            }else{
                self.flowLabel.text = [NSString stringWithFormat:@"%ld",(long)[model.deviceSetInfo[@"Counter"][@"Value"] integerValue]];
            }
        }
        
    }else{
        self.flowLabel.textColor = KColor939393;
        self.flowLabel.text = LOCSTR(@"离线");
        self.flowImageView.hidden = YES;
        [self.ganyingButton setImage:KImage(@"icon_bianji") forState:UIControlStateNormal];
        [self.ganyingButton setTitleColor:KColor939393 forState:UIControlStateNormal];
        [self.bofangButton setImage:KImage(@"icon_bofang") forState:UIControlStateNormal];
        [self.bofangButton setTitleColor:KColor939393 forState:UIControlStateNormal];
        [self.setButton setImage:KImage(@"icon_set") forState:UIControlStateNormal];
        [self.setButton setTitleColor:KColor939393 forState:UIControlStateNormal];

    }
}


@end
