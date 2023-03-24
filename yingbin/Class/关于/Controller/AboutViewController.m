//
//  AboutViewController.m
//  yingbin
//
//  Created by slxk on 2021/6/26.
//  Copyright © 2021 wq. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"关于");
    [self createSubviews];
}

-(void)createSubviews{
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
    [self.view sendSubviewToBack:bgView];

    UIImageView *ImagView = bgView
    .addImageView(5)
    .masonry(^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView);
        make.top.mas_offset(70);
        make.size.mas_equalTo(80);
    })
    .view;
    ImagView.image  = KImage(@"icon_login");
    
    UILabel *line_top = bgView
    .addLabel(3)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(225);
        make.right.mas_equalTo(-15);
        make.left.mas_equalTo(30);
        make.height.mas_equalTo(0.5);
    })
    .view;
    line_top.backgroundColor = KColorE5E5E5;
    
    UILabel *line_botton = bgView
    .addLabel(3)
    .masonry(^(MASConstraintMaker *make) {
        make.top.mas_equalTo(225+60);
        make.right.mas_equalTo(-15);
        make.left.mas_equalTo(30);
        make.height.mas_equalTo(0.5);
    })
    .view;
    line_botton.backgroundColor = KColorE5E5E5;
    
    
    NSMutableArray *dateArray = [NSMutableArray array];
    [dateArray addObject:@{titleKey   : LOCSTR(@"隐私政策"),
                           selectType  : @(500)
                           }];
    WEAK
    NSMutableArray *array = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateArray] mutableCopy];
    self.collectionView.scrollEnabled = NO;
    self.addSection(0).sectionInsets(UIEdgeInsetsMake(250, 0, 0, 0));
    self.addCells(@"SetUpViewCell")
    .toSection(0).withDataModelArray(array)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
            case 500:
            {
                NSURL*firstUrl = [NSURL URLWithString:@"http://ys.cciot.cc/ybin/privacyPolicy_yingbin.html"];
                if (![Lauguage isEqualToString:@"zh"]) {
                    firstUrl = [NSURL URLWithString:@"http://ys.cciot.cc/ybin/privacyPolicy_yingbin_en.html"];
                }
                [MethodTool pushWebVcFrom:self URL:firstUrl.absoluteString title:LOCSTR(@"隐私政策")];

            }
                break;

            default:
                break;
        }
    });
}


@end
