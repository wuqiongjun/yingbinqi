//
//  TJRenWuViewCell.m
//  yingbin
//
//  Created by slxk on 2021/4/26.
//  Copyright © 2021 wq. All rights reserved.
//

#import "TJRenWuViewCell.h"

@interface TJRenWuViewCell ()
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *selectedView;
@end

@implementation TJRenWuViewCell
+ (CGFloat)viewHeightByDataModel:(id)dataModel
{
    return 50.0f;
}

- (void)setViewDataModel:(BaseGeneralModel *)dataModel
{
    [self.titleLabel setText:LOCSTR(dataModel.itemName)];
//    [self.selectedView setHidden:!dataModel.selected];
    if (!dataModel.selected) {
        self.selectedView.image = KImage(@"icon_wxz");
    }else{
        self.selectedView.image = KImage(@"icon_gouxuan");
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        
        self.titleLabel = self.addLabel(1)
        .font(KFont(14))
        .textColor(KColor333333)
        .masonry(^ (MASConstraintMaker *make) {
            make.left.mas_equalTo(18);
            make.centerY.mas_equalTo(0);
            make.right.mas_lessThanOrEqualTo(-15.0f);
        })
        .view;
        
        self.selectedView = self.addImageView(2)
        .image([UIImage imageNamed:@"icon_gouxuan"])
//        .hidden(YES)
        .masonry(^ (MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.centerY.mas_equalTo(0);
            make.size.mas_equalTo(20);
        })
        .view;
    }
    return self;
}

@end
