//
//  QuMuViewCell.m
//  yingbin
//
//  Created by slxk on 2021/6/9.
//  Copyright © 2021 wq. All rights reserved.
//

#import "QuMuViewCell.h"

@interface QuMuViewCell ()

@property (nonatomic, strong)UILabel *nameLable;
@property (nonatomic, strong)UIButton *btn;

@end

@implementation QuMuViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self setupUI];
    }
    return self;
}
-(void)setupUI{
    WEAK
    
    self.btn = self.contentView
    .addButton(0)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        btn.selected = !btn.selected;
        if (btn.selected) {
            [self.image setImage:KImage(@"icon_xz")];
        }else{
            [self.image setImage:KImage(@"icon_wxz")];
        }
        if (self.selectMusicSuccess) {
            self.selectMusicSuccess(btn);
        }
    })
    .masonry(^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(0);
        make.bottom.top.mas_equalTo(0);
    })
    .view;
    
    self.nameLable = self.contentView
    .addLabel(0)
    .textColor(KColor666666)
    .font(KPingFangFont(14))
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.right.mas_lessThanOrEqualTo(-30.0f);
    })
    .view;
    
    self.image = self.contentView
    .addImageView(1)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(15);
    })
    .view;
    [self.image setImage:KImage(@"icon_wxz")];
    
//    UIButton *btn = self.contentView
//    .addButton(1)
//    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
//        STRONG
//        self.btn.selected = !btn.selected;
//
//        if (self.selectMusicSuccess) {
//            self.selectMusicSuccess(btn);
//        }
//    })
//    .masonry(^(MASConstraintMaker *make) {
//        make.right.left.mas_equalTo(0);
//        make.bottom.top.mas_equalTo(0);
//    })
//    .view;
    
//    self.btn = self.contentView
//    .addButton(1)
//    .image(KImage(@"icon_wxz"))
//    .imageSelected(KImage(@"icon_xz"))
//    .selected(NO)
//    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
//        STRONG
//        btn.selected = !btn.selected;
//        if (self.selectMusicSuccess) {
//            self.selectMusicSuccess(btn);
//        }
//    })
//    .masonry(^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-15);
//        make.centerY.mas_equalTo(0);
//        make.size.mas_equalTo(15);
//    })
//    .view;
    
}
-(void)setQuMuDic:(NSMutableDictionary *)quMuDic{
    _quMuDic = quMuDic;
    self.btn.selected = [quMuDic boolForKey:@"selected"];
    if (self.btn.selected) {
        [self.image setImage:KImage(@"icon_xz")];
    }else{
        [self.image setImage:KImage(@"icon_wxz")];
    }
    self.nameLable.text = [NSString stringWithFormat:@"%ld、%@",self.integer,quMuDic[@"name"]];
}
@end
