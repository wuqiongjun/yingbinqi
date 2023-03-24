//
//  ForgotPwdCell.m
//  yingbin
//
//  Created by slxk on 2021/4/21.
//  Copyright © 2021 wq. All rights reserved.
//

#import "ForgotPwdCell.h"

@interface ForgotPwdCell ()

KSTRONG UITextField *textField;
KSTRONG BaseGeneralModel *editModel;
KSTRONG UIButton *codeButton;
KASSIGN NSInteger startCheckTimer;
KASSIGN NSInteger remainSeconds;
KSTRONG RACDisposable *disposable;
@end

@implementation ForgotPwdCell

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
    [self.textField setPlaceholder:dataModel.placeholderName];
    [self.textField setText:dataModel.itemName];
    if (dataModel.tag > 1000) {
        self.textField.keyboardType = UIKeyboardTypePhonePad;
    }
    else{
        self.textField.keyboardType = UIKeyboardTypeDefault;
    }
    if ([dataModel.placeholderName containsString:LOCSTR(@"验证码")]) {
        self.codeButton.hidden = NO;
        [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-130);
        }];
    }
    else{
        self.codeButton.hidden = YES;
        [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
        }];
    }
    if ([dataModel.placeholderName containsString:LOCSTR(@"密码")]) {
        self.textField.secureTextEntry = YES;
    }
    else{
        self.textField.secureTextEntry = NO;
    }
 
}

#pragma mark - # Cell
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        WEAK
        [[TLNotificationCenter rac_addObserverForName:@"CountdownBegin" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
            STRONG
            [self setTime];
        }];
        [self ui_initSubViewsToView:self.contentView];
    }
    return self;
}
#pragma mark - # UI
- (void)ui_initSubViewsToView:(UIView *)contentView
{
    WEAK
    self.textField = self.contentView.addTextField(0)
    .font(KFont(13))
    .masonry(^ (MASConstraintMaker *make) {
        make.right.mas_equalTo(-110);
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(15);
    })
    .eventBlock(UIControlEventEditingChanged, ^(UITextField *sender) {
        STRONG
        [self.editModel setItemName:sender.text];
        KBLOCK_EXEC(self.eventAction,self.editModel.tag,self.editModel)
    })
    .view;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.codeButton = self.contentView.addButton(1)
    .title(LOCSTR(@"获取验证码"))
    .titleColor(KThemeColor)
    .titleFont(KPingFangFont(12))
    .border(1,KThemeColor)
    .titleColorDisabled([KThemeColor colorWithAlphaComponent:0.5])
    .cornerRadius(15)
    .hidden(YES)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
        KBLOCK_EXEC(self.eventAction,100,self.editModel);

    })
    .masonry(^ (MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(0);
    })
    .view;
    
}

- (void)setTime{
    @weakify(self);
    self.remainSeconds = 60;
    self.startCheckTimer = 0;
    if (self.disposable) {
        return;
    }
    self.codeButton.enabled = NO;
    self.disposable = [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self)
        
        if (!self) {
            return;
        }
        self.startCheckTimer++;
        if (self.startCheckTimer < self.remainSeconds) {
            [self.codeButton setTitle:[NSString stringWithFormat:@"%ld秒",self.remainSeconds-self.startCheckTimer] forState:UIControlStateNormal];
        } else {
            [self.codeButton setTitle:LOCSTR(@"获取验证码") forState:UIControlStateNormal];
            self.codeButton.enabled = YES;
            [self.disposable dispose];
            self.disposable = nil;
        }
    }];

}

@end
