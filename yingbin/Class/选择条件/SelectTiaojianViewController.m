//
//  SelectTiaojianViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "SelectTiaojianViewController.h"
#import "TimingViewController.h"
#import "SelectDeviceViewController.h"
@interface SelectTiaojianViewController ()

@property (nonatomic, strong)UIImageView *jiantou;
@end

@implementation SelectTiaojianViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"选择条件");
    [self createSubviews];
}

-(void)createSubviews{
    WEAK
    UIButton *bgTimeView = self.view
    .addButton(0)
    .backgroundColor(UIColor.whiteColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        //时间
        TimingViewController *vc = [[TimingViewController alloc]init];
        vc.isEdit = NO;
        PushVC(vc);
    })
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(5);
        make.height.mas_equalTo(54);
    })
    .view;
    bgTimeView.layer.cornerRadius = 9;
    
    UIImageView *timeImage = bgTimeView
    .addImageView(0)
    .image(KImage(@"icon_Time"))
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(bgTimeView);
        make.size.mas_equalTo(18);
    })
    .view;
    
    UILabel *time_l = bgTimeView
    .addLabel(0)
    .font(KFont(14))
    .text(LOCSTR(@"时间"))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(timeImage.mas_right).mas_offset(10);
        make.centerY.mas_equalTo(bgTimeView);
    })
    .view;
    
    UIImageView *jiantouImage = bgTimeView
    .addImageView(0)
    .image(KImage(@"icon_jiantou"))
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.centerY.mas_equalTo(time_l);
        make.size.mas_equalTo(13);
    })
    .view;
    
    UIButton *bgDevVIew = self.view
    .addButton(1)
    .backgroundColor(UIColor.whiteColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        //设备
        SelectDeviceViewController *vc = [[SelectDeviceViewController alloc] init];
        vc.titleStr = LOCSTR(@"选择触发设备");
        vc.isEdit = NO;
        PushVC(vc);
    })
    .masonry(^(MASConstraintMaker *make) {
        make.left.right.height.mas_equalTo(bgTimeView);
        make.top.mas_equalTo(bgTimeView.mas_bottom).mas_offset(15);
    })
    .view;
    bgDevVIew.layer.cornerRadius = 9;

    UIImageView *devImage = bgDevVIew
    .addImageView(0)
    .image(KImage(@"icon_changjing_dev"))
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(bgDevVIew);
        make.size.mas_equalTo(16);
    })
    .view;
    
    UILabel *dev_l = bgDevVIew
    .addLabel(1)
    .font(KFont(14))
    .text(LOCSTR(@"设备"))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(devImage.mas_right).offset(10);
        make.centerY.mas_equalTo(bgDevVIew);
    })
    .view;
    
    self.jiantou = bgDevVIew
    .addImageView(0)
    .image(KImage(@"icon_jiantou"))
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.centerY.mas_equalTo(dev_l);
        make.size.mas_equalTo(jiantouImage);
    })
    .view;
    
    
    
}



@end
