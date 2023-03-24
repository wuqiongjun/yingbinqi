//
//  YingBinQuViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "YingBinQuViewController.h"
#import "DeviceBringMusicVC.h"
#import "locallyUploadMusicVC.h"
#import "TextToSpeechVC.h"

@interface YingBinQuViewController ()

@end

@implementation YingBinQuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"迎宾曲");
    [self createSubviews];
    
}
-(void)createSubviews{
    
    UIView *bgView = self.view
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0f);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-24, 108));
    })
    .view;
    bgView.layer.cornerRadius = 9;
    [self.view sendSubviewToBack:bgView];
    
    NSMutableArray *dateArray = [NSMutableArray array];
    [dateArray addObject:@{titleKey   : LOCSTR(@"设备自带音乐"),
                           selectType  : @(0)
                           }];
    [dateArray addObject:@{titleKey   : LOCSTR(@"自定义曲目"),
                          selectType  : @(1)
    }];

    WEAK
    NSMutableArray *array = [[NSArray yy_modelArrayWithClass:[BaseGeneralModel class] json:dateArray] mutableCopy];
    self.collectionView.scrollEnabled = NO;
    self.addSection(0).sectionInsets(UIEdgeInsetsMake(10, 0, 0, 0));
    self.addCells(@"YingBinQuViewCell")
    .toSection(0).withDataModelArray(array)
    .selectedAction(^(BaseGeneralModel *model){
        STRONG
        NSUInteger typeUI = [model.type unsignedIntegerValue];
        switch (typeUI) {
            case 0:
            {
                DeviceBringMusicVC *vc = [DeviceBringMusicVC new];
//                vc.songDic = self.songDic;
                PushVC(vc);
            }
                break;
            case 1:
            {
                locallyUploadMusicVC *vc = [locallyUploadMusicVC new];
                PushVC(vc);
            }
                break;

            default:
                break;
        }
    });
}



@end
