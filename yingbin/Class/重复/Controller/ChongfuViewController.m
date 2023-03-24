//
//  ChongfuViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "ChongfuViewController.h"
#import "TimingViewController.h"
@interface ChongfuViewController ()

@property (nonatomic, strong)UILabel *topTitle;
@property (nonatomic, strong)NSMutableArray *itemsArray;
@property (nonatomic, strong)NSMutableArray *repeatsArray;

@property (nonatomic,strong) NSMutableArray *weekSelect;


KASSIGN NSInteger tag;

@end

@implementation ChongfuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"重复");
    [self configData];
    self.navigationItem.rightBarButtonItem = self.saveButtonItem;

    [self createSubviews];

}
//赋值
-(void)configData{
    if (self.days) {
        const char *repeats = [self.days UTF8String];
        
        for (int i = 0; i < 7; i ++) {
            int a = repeats[i] - '0';
            self.weekSelect[i] = [NSString stringWithFormat:@"%i",a];
        }
    }
}


//保存
- (void)saveItemClick:(UIBarButtonItem *)btn{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.repeatResult) {
        self.repeatResult([self.weekSelect copy]);
    }
}
-(void)createSubviews{
    
    UIView *bgView = self.view
    .addView(0)
    .backgroundColor(UIColor.groupTableViewBackgroundColor)
    .masonry(^(MASConstraintMaker *make){
        make.top.mas_equalTo(self.view).mas_offset(0);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 60));
    })
    .view;
    
    self.topTitle = bgView
    .addLabel(0)
    .text(LOCSTR(@"不勾选将默认只执行一次"))
    .textColor(KColor666666)
    .font(KFont(13))
    .masonry(^(MASConstraintMaker *make){
        make.left.mas_equalTo(18);
        make.centerY.mas_equalTo(bgView);
    })
    .view;
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 7; i++) {
        BaseGeneralModel *model = [[BaseGeneralModel alloc] init];
        [model setTag:i];
        [model setItemName:[self getName:i]];
        if ([self.weekSelect[i] integerValue] == 1) {
            [model setSelected:YES];
        }else{
            [model setSelected:NO];
        }
        [data addObject:model];
    }
    self.itemsArray = data;
    
    
    [self reloadUIWithModelArray:self.itemsArray];
}
- (void)reloadUIWithModelArray:(NSArray *)modelArray
{
    WEAK
    self.clear();
    
    self.addSection(0).sectionInsets(UIEdgeInsetsMake(60, 0, 0, 0));
    self.addCells(@"ChongfuViewCell")
    .withDataModelArray(modelArray)
    .toSection(0)
    .selectedAction(^ (BaseGeneralModel *model) {
        STRONG
        for (int i = 0; i < 7; i++) {
            BaseGeneralModel *item = self.itemsArray[i];
            if (item == model) {
                if (model.selected) {
                    item.selected = NO;
                    [self.weekSelect replaceObjectAtIndex:i withObject:@"0"];
                }else{
                    item.selected = YES;
                    [self.weekSelect replaceObjectAtIndex:i withObject:@"1"];
                }
                [self.itemsArray replaceObjectAtIndex:model.tag withObject:item];
            }
        }

        [self reloadView];
    });
    [self reloadView];
}
- (NSString *)getName:(NSInteger )index{
    switch (index) {
        case 0:
            return @"周日";
            break;
        case 1:
            return @"周一";
            break;
        case 2:
            return @"周二";
            break;
        case 3:
            return @"周三";
            break;
        case 4:
            return @"周四";
            break;
        case 5:
            return @"周五";
            break;
        case 6:
            return @"周六";
            break;
        default:
            break;
    }
    return @"";
}
- (NSMutableArray *)weekSelect
{
    if (!_weekSelect) {
        _weekSelect = [NSMutableArray arrayWithArray:@[@"0",@"0",@"0",@"0",@"0",@"0",@"0"]];
    }
    return _weekSelect;
}
@end
