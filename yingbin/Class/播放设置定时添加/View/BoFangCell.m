//
//  BoFangCell.m
//  yingbin
//
//  Created by slxk on 2021/6/9.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BoFangCell.h"

@interface BoFangCell ()

@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UIButton *upperBtn;
@property (nonatomic, strong)UIButton *lowerBtn;

@end

@implementation BoFangCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    WEAK
    
    UIView *bgView = self.contentView
    .addView(0)
    .backgroundColor(UIColor.whiteColor)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.height.mas_equalTo(50);
    })
    .view;
    
    self.nameLabel = bgView
    .addLabel(0)
    .textColor(KColor666666)
    .font(KPingFangFont(14))
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-90.0f);
    })
    .view;
    
    self.lowerBtn = bgView
    .addButton(0)
    .title(LOCSTR(@"下移"))
    .titleFont(KFont(14))
    .titleColor(UIColor.blackColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        if (self.btnSelected) {
            self.btnSelected(2);
        }

    })
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(30, 35));
    })
    .view;
    
    self.upperBtn = bgView
    .addButton(1)
    .title(LOCSTR(@"上移"))
    .titleFont(KFont(14))
    .titleColor(UIColor.blackColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        if (self.btnSelected) {
            self.btnSelected(1);
        }
    })
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.lowerBtn.mas_left).mas_offset(-5);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(30, 35));
    })
    .view;
}

-(void)setNameStr:(NSString *)nameStr{
    _nameStr = nameStr;
    self.nameLabel.text = [NSString stringWithFormat:@"%ld、%@",self.integer,nameStr];
}
@end
