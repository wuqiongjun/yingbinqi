//
//  EditPhoneCell.m
//  yingbin
//
//  Created by slxk on 2021/4/21.
//  Copyright © 2021 wq. All rights reserved.
//

#import "EditPhoneCell.h"
@interface EditPhoneCell ()

KSTRONG UITextField *textField;
KSTRONG BaseGeneralModel *editModel;
KSTRONG UIButton *areaCodeButton;
KSTRONG UIView *line;

@end
@implementation EditPhoneCell

+ (CGFloat)viewHeightByDataModel:(id)dataModel
{
    return 45;
}
- (void)viewIndexPath:(NSIndexPath *)indexPath sectionItemCount:(NSInteger)count
{
    if (indexPath.row == 0) {
        self.addSeparator(ZZSeparatorPositionTop);
    }
    else {
        self.removeSeparator(ZZSeparatorPositionTop);
    }
    if (indexPath.row == count - 1) {
        self.addSeparator(ZZSeparatorPositionBottom);
    }
    else {
        self.addSeparator(ZZSeparatorPositionBottom).beginAt(15);
    }
}

- (void)setViewDataModel:(BaseGeneralModel *)dataModel
{
    _editModel = dataModel;
    [self.areaCodeButton setTitle:[NSString stringWithFormat:@"%@",dataModel.itemSubName] forState:UIControlStateNormal];
    if (dataModel.itemSubName.length == 3) {
        [self.areaCodeButton setImageEdgeInsets:(UIEdgeInsetsMake(0, 35, -5, 0))];
    }else if(dataModel.itemSubName.length == 4){
        [self.areaCodeButton setImageEdgeInsets:(UIEdgeInsetsMake(0, 40, -5, 0))];
    }else{
        [self.areaCodeButton setImageEdgeInsets:(UIEdgeInsetsMake(0, 30, -5, 0))];
    }
    
    [self.textField setPlaceholder:dataModel.placeholderName];
    [self.textField setText:dataModel.itemName];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        WEAK
        self.areaCodeButton = self.contentView
        .addButton(0)
        .image(KImage(@"icon_jia"))
        .titleColor(KColor333333)
        .titleFont(KFont(13))
        .titleEdgeInsets(UIEdgeInsetsMake(0, -5, 0, 0))
        .imageEdgeInsets(UIEdgeInsetsMake(0, 30, -5, 0))
        .contentHorizontalAlignment(UIControlContentHorizontalAlignmentLeft)
        .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
//            STRONG
//            KBLOCK_EXEC(self.eventAction,0,self.editModel)
        })
        .masonry(^(MASConstraintMaker *make){
            make.centerY.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(50, 30));
            make.left.mas_equalTo(15);
        })
        .view;
        
        self.line = self.contentView.addView(1)
        .backgroundColor(KColor(220, 220, 220, 1))
        .masonry(^(MASConstraintMaker *make){
            make.left.mas_equalTo(self.areaCodeButton.mas_right);
            make.size.mas_equalTo(CGSizeMake(0.75, 14));
            make.top.mas_equalTo(15);
        })
        .view;
        
        self.textField = self.contentView.addTextField(2)
        .font(KFont(13))
        .keyboardType(UIKeyboardTypePhonePad)
        .masonry(^ (MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(self.areaCodeButton.mas_right).mas_offset(10);
        })
        .eventBlock(UIControlEventEditingChanged, ^(UITextField *sender) {
            STRONG
            [self.editModel setItemName:sender.text];
            KBLOCK_EXEC(self.eventAction,self.editModel.tag,self.editModel)
        })
        .view;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return self;
}

@end
