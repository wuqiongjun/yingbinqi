//
//  BofangSetVC.m
//  yingbin
//
//  Created by slxk on 2021/5/17.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BofangSetVC.h"
#import "BoFangDingShiViewController.h"
@interface BofangSetVC ()


@end

@implementation BofangSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"播放设置");
    
    [self createSubviews];

}

-(void)createSubviews{
    
    UIView *bgoneView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 162+54));
    })
    .view;
    bgoneView.layer.cornerRadius = 9;
    [self.view sendSubviewToBack:bgoneView];
    
    NSMutableArray *dateOneArray = [NSMutableArray array];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"感应播放"),
                           selectType  : @(0)
                           }];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"仅感应"),
                          selectType  : @(1)
    }];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"仅播放"),
                           selectType  : @(2)
                           }];
    [dateOneArray addObject:@{titleKey   : LOCSTR(@"广告播放"),
                           selectType  : @(3)
                           }];
    WEAK
    NSMutableArray *array = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateOneArray] mutableCopy];
    self.collectionView.scrollEnabled = NO;
    self.addSection(0).sectionInsets(UIEdgeInsetsMake(10, 0, 0, 0));
    self.addCells(@"YingBinQuViewCell")
    .toSection(0).withDataModelArray(array)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
            case 0:
            {//感应播放
                BoFangDingShiViewController *vc = [[BoFangDingShiViewController alloc]init];
                vc.titleStr = LOCSTR(@"感应播放设置");
                PushVC(vc);
            }
                break;
            case 1:
            {//仅感应
                [MethodTool presentVc:self Title:LOCSTR(@"提示") message:LOCSTR(@"设备感应到人体后，闪灯提示，不播放声音。可用于只统计流量，也可通过设置场景联动，楼下感应，楼上播放。") cancelButtonTitle:LOCSTR(@"确定") defineButtonTitle:@"" otherButtonTitles:@[] actionHandler:^(NSInteger buttonIndex) {
                    
                }];

            }
                break;
            case 2:
            {//仅播放
                BoFangDingShiViewController *vc = [[BoFangDingShiViewController alloc]init];
                vc.titleStr = LOCSTR(@"仅播放设置");
                PushVC(vc);
                
            }
                break;
            case 3:
            {//广告播放
                BoFangDingShiViewController *vc = [[BoFangDingShiViewController alloc]init];
                vc.titleStr = LOCSTR(@"广告播放设置");
                PushVC(vc);
                
            }
                break;
            default:
                break;
        }
    });
}

@end
