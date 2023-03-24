//
//  BaseButtonCell.m
//  yingbin
//
//  Created by slxk on 2021/4/21.
//  Copyright © 2021 wq. All rights reserved.
//

#import "BaseButtonCell.h"

@interface BaseButtonCell ()

KSTRONG UIButton *bottomButton;

@end

@implementation BaseButtonCell

+ (CGFloat)viewHeightByDataModel:(id)dataModel
{
    return 55;
}
- (void)setViewDataModel:(NSString *)dataModel{
    [self.bottomButton setTitle:dataModel forState:UIControlStateNormal];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        WEAK
        self.bottomButton = self.contentView
        .addButton(1)
        .cornerRadius(5)
        .titleFont(KPingFangFont(15))
        .titleColor(UIColor.whiteColor)
        .backgroundColor(KThemeColor)
        .backgroundColorDisabled([KThemeColor colorWithAlphaComponent:0.4])
        .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
            STRONG
            KBLOCK_EXEC(self.eventAction,0,x)
        })
        .masonry(^(MASConstraintMaker *make){
            make.edges.mas_equalTo(UIEdgeInsetsMake(5, 15, 5, 15));
        })
        .view;
    }
    return self;
}
@end


@interface ZBButtonCell ()

KSTRONG UIButton *bottomButton;

@end

@implementation ZBButtonCell

+ (CGFloat)viewHeightByDataModel:(id)dataModel
{
    return 50;
}
- (void)setViewDataModel:(NSString *)dataModel{
    [self.bottomButton setTitle:dataModel forState:UIControlStateNormal];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        WEAK
        self.bottomButton = self.contentView
        .addButton(1)
        .cornerRadius(20)
        .titleFont(KPingFangFont(15))
        .titleColor(UIColor.whiteColor)
        .backgroundColor(KThemeColor)
        .backgroundColorDisabled([KThemeColor colorWithAlphaComponent:0.4])
        .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
            STRONG
            KBLOCK_EXEC(self.eventAction,0,x)
        })
        .masonry(^(MASConstraintMaker *make){
            make.edges.mas_equalTo(UIEdgeInsetsMake(5, 15, 5, 15));
        })
        .view;
    }
    return self;
}
@end


@interface BaseTextFieldCell ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) BaseGeneralModel *editModel;

@end


@implementation BaseTextFieldCell

+ (CGFloat)viewHeightByDataModel:(id)dataModel
{
    return 55;
}
- (void)setViewDataModel:(BaseGeneralModel *)dataModel{
    self.textField.zz_make.text(dataModel.itemSubName).placeholder(dataModel.placeholderName);
    if (dataModel.tag < 5) {
        self.textField.keyboardType = UIKeyboardTypePhonePad;
    }else{
        self.textField.keyboardType = UIKeyboardTypeDefault;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        WEAK
        self.textField = self.contentView
        .addTextField(1)
        .font(KPingFangFont(15))
        .textColor(KColor666666)
        .textAlignment(NSTextAlignmentCenter)
        .backgroundColor(UIColor.groupTableViewBackgroundColor)
        .cornerRadius(2)
        .masonry(^ (MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(5, 15, 5, 15));
        })
        .eventBlock(UIControlEventEditingChanged, ^(UITextField *sender) {
            @strongify(self);
            [self.editModel setItemName:sender.text];
            KBLOCK_EXEC(self.eventAction,0,sender)
            
        })
        .view;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return self;
}

@end

