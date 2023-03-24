//
//  SelectDeviceViewCell.m
//  yingbin
//
//  Created by slxk on 2021/4/26.
//  Copyright © 2021 wq. All rights reserved.
//

#import "SelectDeviceViewCell.h"

@interface SelectDeviceViewCell ()

@property (strong, nonatomic) UIImageView *topImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *jiantouImageView;
@end

@implementation SelectDeviceViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self setupUI];
    }
    return self;
}
-(void)setupUI{
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
    bgView.layer.cornerRadius = 10.5;
    
    self.topImageView = bgView
    .addImageView(0)
    .image(KImage(@"icon_head"))
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25);
        make.centerY.mas_equalTo(bgView);
        make.size.mas_equalTo(CGSizeMake(25, 38));
    })
    .view;
    
    self.nameLabel = bgView
    .addLabel(0)
    .font(KBFont(15))
    .textColor(KColor333333)
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.topImageView.mas_right).mas_offset(20);
        make.right.mas_equalTo(-40);
        make.centerY.mas_equalTo(self.topImageView);
    })
    .view;
    
    self.jiantouImageView = bgView
    .addImageView(1)
    .image(KImage(@"icon_jiantou"))
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-25);
        make.centerY.mas_equalTo(bgView);
        make.size.mas_equalTo(CGSizeMake(13, 13));
    })
    .view;
    
}
- (void)setModel:(DeviceViewModel *)model{
    _model = model;
    if (![MethodTool isBlankString:model.AliasName]) {
        self.nameLabel.text = model.AliasName;
    }
    else
    {
        self.nameLabel.text = model.DeviceName;
    }
    self.topImageView.image = KImage(@"icon_devimage");

}
@end
