//
//  SetUpViewCell.m
//  yingbin
//
//  Created by slxk on 2021/4/26.
//  Copyright © 2021 wq. All rights reserved.
//

#import "SetUpViewCell.h"

@interface SetUpViewCell ()

/// 左侧icon
KSTRONG UIImageView *iconView;
/// 左侧标题
KSTRONG UILabel *titleLabel;

/// 右侧副标题
KSTRONG UILabel *detailLabel;
/// 右箭头
KSTRONG UIImageView *arrowView;

@end

@implementation SetUpViewCell

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
        self.layer.cornerRadius = 3;
        [self loadSubViews];
    }
    return self;
}
- (void)setViewDataModel:(BaseGeneralModel *)dataModel
{
    [self.iconView setImage:[UIImage imageNamed:dataModel.itemImageName]];
    [self.titleLabel setText:LOCSTR(dataModel.itemName)];
//    if ([MethodTool isPureInt:dataModel.itemSubName]) {
//        [self.detailLabel setText:dataModel.itemSubName];
//    }else{
        [self.detailLabel setText:LOCSTR(dataModel.itemSubName)];
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
        self.addSeparator(ZZSeparatorPositionBottom).beginAt(50);
    }
}

#pragma mark - # Private Methods
- (void)loadSubViews
{
    self.iconView = self.contentView.addImageView(0)
    .contentMode(UIViewContentModeScaleAspectFit)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.0f);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(20.0f);
    })
    .view;
    
    self.titleLabel = self.contentView.addLabel(1)
    .font(KPingFangFont(15))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).mas_offset(10);
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
    
    self.detailLabel = self.addLabel(3)
    .numberOfLines(2)
    .font([UIFont systemFontOfSize:14.0f]).textColor([UIColor grayColor])
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(self.titleLabel.mas_right).mas_offset(15);
        make.right.mas_equalTo(self.arrowView.mas_left).mas_offset(-13);
        make.centerY.mas_equalTo(self.titleLabel);
    })
    .view;
}


@end
