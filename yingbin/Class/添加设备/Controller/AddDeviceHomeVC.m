//
//  AddDeviceHomeVC.m
//  yingbin
//
//  Created by slxk on 2021/7/9.
//  Copyright © 2021 wq. All rights reserved.
//

#import "AddDeviceHomeVC.h"
#import "AddDeviceViewController.h"
#import "AddDeviceWiFiVC.h"

@interface AddDeviceHomeVC ()

@property (nonatomic, strong)UILabel *networkLabel;
@property (nonatomic, strong)UIButton *onekeybtn;
@property (nonatomic, strong)UIButton *hotspotBtn;

@end

@implementation AddDeviceHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"添加设备");
    
    [self createSubviews];

}

-(void)createSubviews{
    WEAK
    UIView *bgView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(-(k_Height_SafetyArea+20));
    })
    .view;
    bgView.layer.cornerRadius = 9;
    
    self.networkLabel = bgView
    .addLabel(0)
    .text(LOCSTR(@"请选择配网方式"))
    .font(KFont(15))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView.mas_centerX);
        make.top.mas_equalTo(134);
    })
    .view;
    
    
    
    self.onekeybtn = bgView
    .addButton(0)
    .title(LOCSTR(@"一键配网"))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        AddDeviceViewController *vc = [AddDeviceViewController new];
        PushVC(vc);

    })
    .masonry(^(MASConstraintMaker *make){
        make.centerX.mas_equalTo(bgView.mas_centerX);
        make.top.mas_equalTo(self.networkLabel.mas_bottom).mas_offset(63);
        make.size.mas_equalTo(CGSizeMake(200, 48));
    })
    .view;
    self.onekeybtn.layer.cornerRadius = 24;
    
    
    self.hotspotBtn = bgView
    .addButton(0)
    .title(LOCSTR(@"热点配网"))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        AddDeviceWiFiVC *vc = [AddDeviceWiFiVC new];
        PushVC(vc);

    })
    .masonry(^(MASConstraintMaker *make){
        make.centerX.mas_equalTo(bgView.mas_centerX);
        make.top.mas_equalTo(self.onekeybtn.mas_bottom).mas_offset(63);
        make.size.mas_equalTo(CGSizeMake(200, 48));
        
    })
    .view;
    self.hotspotBtn.layer.cornerRadius = 24;

}


@end
