//
//  DeviceInitCell.m
//  yingbin
//
//  Created by slxk on 2021/6/11.
//  Copyright © 2021 wq. All rights reserved.
//

#import "DeviceInitCell.h"

@interface DeviceInitCell ()
@property (nonatomic, strong)UILabel *nameCLable;

@property (nonatomic, strong)UILabel *nameLable;
@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation DeviceInitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self setupUI];
    }
    return self;
}
-(void)setupUI{
    
    self.nameLable = self.contentView
    .addLabel(0)
    .textColor(UIColor.blackColor)
    .font(KPingFangFont(15))
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_lessThanOrEqualTo(-30.0f);
    })
    .view;
    
    self.nameCLable = self.contentView
    .addLabel(0)
    .textColor(UIColor.blackColor)
    .font(KPingFangFont(15))
    .numberOfLines(0)
    .hidden(YES)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.right.mas_lessThanOrEqualTo(-30.0f);
    })
    .view;
    
    self.titleLabel = self.contentView
    .addLabel(0)
    .textColor(UIColor.redColor)
    .font(KPingFangFont(12))
    .adjustsFontSizeToFitWidth(YES)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(10);
        make.right.mas_lessThanOrEqualTo(-40.0f);
    })
    .view;
    
    self.btn = self.contentView
    .addButton(0)
    .image(KImage(@"icon_wxz"))
    .imageSelected(KImage(@"icon_xz"))
    .selected(NO)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(30);
    })
    .view;
}

-(void)setDic:(NSMutableDictionary *)dic{
    _dic = dic;
    self.nameLable.text = dic[@"title"];
    self.titleLabel.text = dic[@"name"];
    if ([MethodTool isBlankString:self.titleLabel.text]) {
        self.nameCLable.text = dic[@"title"];
        self.nameLable.hidden = YES;
        self.nameCLable.hidden = NO;
    }
    if ([dic[@"isSelected"] isEqualToString:@"1"]) {
        self.btn.selected = YES;
    } else {
        self.btn.selected = NO;
    }
}
@end
