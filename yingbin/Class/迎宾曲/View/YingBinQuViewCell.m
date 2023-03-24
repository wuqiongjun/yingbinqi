//
//  YingBinQuViewCell.m
//  yingbin
//
//  Created by slxk on 2021/4/26.
//  Copyright © 2021 wq. All rights reserved.
//

#import "YingBinQuViewCell.h"

@interface YingBinQuViewCell()

/// 左侧标题
KSTRONG UILabel *titleLabel;

/// 右箭头
KSTRONG UIImageView *arrowView;

@end
@implementation YingBinQuViewCell
+ (CGSize)viewSizeByDataModel:(id)dataModel
{
    return CGSizeMake(SCREEN_WIDTH-24, 54);
}
#pragma mark - # Public Methods
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
//        [self setSelectedBackgrounColor:[UIColor lightGrayColor]];
        self.layer.cornerRadius = 9;
        [self loadSubViews];
    }
    return self;
}
- (void)setViewDataModel:(BaseGeneralModel *)dataModel
{
    [self.titleLabel setText:LOCSTR(dataModel.itemName)];
//    if (dataModel.type.integerValue == 2) {
//        [self.detailLabel setText:[NSString stringWithFormat:@"V%@",kAppVersion]];
//    }
    
    
}
- (void)viewIndexPath:(NSIndexPath *)indexPath sectionItemCount:(NSInteger)count
{
    if (indexPath.row == 0) {
//        self.addSeparator(ZZSeparatorPositionTop);

    }
    else {
//        self.removeSeparator(ZZSeparatorPositionTop);
    }
    if (indexPath.row == count - 1) {
//        self.addSeparator(ZZSeparatorPositionBottom);

    }
    else {
        self.addSeparator(ZZSeparatorPositionBottom).beginAt(15);
    }
    

}

#pragma mark - # Private Methods
- (void)loadSubViews
{

    
    self.titleLabel = self.contentView.addLabel(1)
    .font(KPingFangFont(15))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.centerY.mas_equalTo(0);
        make.right.mas_lessThanOrEqualTo(-15.0f);
    })
    .view;
    
    self.arrowView = self.contentView.addImageView(2)
    .image([UIImage imageNamed:@"icon_jiantou"])
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(13, 13));
        make.right.mas_equalTo(-15);
    })
    .view;
    
}

@end
