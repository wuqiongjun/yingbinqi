//
//  MessagesShareCell.m
//  yingbin
//
//  Created by slxk on 2021/5/14.
//  Copyright © 2021 wq. All rights reserved.
//

#import "MessagesShareCell.h"

@interface MessagesShareCell ()

@property (nonatomic, strong) UIImageView *iconUrl;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *nameConLabel;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UIButton *Tbutton;

@end

@implementation MessagesShareCell

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
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(10);
    })
    .view;
    bgView.layer.cornerRadius = 10;
    
    self.iconUrl = bgView
    .addImageView(0)
    .hidden(YES)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(bgView);
        make.size.mas_equalTo(CGSizeMake(0.5, 43));
    })
    .view;
    
    self.nameLabel = bgView
    .addLabel(0)
    .font(KBFont(15))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconUrl.mas_right).mas_offset(10);
        make.bottom.mas_equalTo(self.iconUrl.mas_centerY).mas_offset(-8);
    })
    .view;
    
    self.nameConLabel = bgView
    .addLabel(1)
    .font(KFont(12))
    .textColor(KColor999999)
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.right.mas_equalTo(-80);
        make.bottom.mas_equalTo(bgView).mas_offset(-3);
        make.top.mas_equalTo(self.iconUrl.mas_centerY).mas_offset(-8);
    })
    .view;
    
    self.time = bgView
    .addLabel(1)
    .font(KFont(12))
    .textColor(KColor999999)
    .numberOfLines(0)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
    })
    .view;
    
    self.Tbutton = bgView
    .addButton(2)
    .title(LOCSTR(@"同意"))
    .titleColor(UIColor.whiteColor)
    .backgroundColor(KThemeColor)
    .titleFont(KFont(14))
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
   STRONG
        [self AppBindUserShareDevice];
        
    })
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.nameConLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    })
    .view;
    self.Tbutton.layer.cornerRadius = 5;
}
-(void)setDataDic:(NSMutableDictionary *)dataDic{
    _dataDic = dataDic;
    self.nameLabel.text = dataDic[@"MsgTitle"];
    self.nameConLabel.text = dataDic[@"MsgContent"];
    self.time.text = [NSString convertTimestampToTime:dataDic[@"MsgTimestamp"] byDateFormat:@"yyyy-MM-dd HH:mm"];
    NSInteger msgType = [dataDic[@"MsgType"] integerValue];
//    if (msgType >= 300) {
        [self.iconUrl setImage:[UIImage imageNamed:@"icon_morentouxiang"]];
//    }
    if (msgType != 301) {
        self.Tbutton.hidden = YES;
    }

}
//点击同意
-(void)AppBindUserShareDevice{
//    WEAK
    NSDictionary *param = @{@"ShareDeviceToken":self.dataDic[@"Attachments"][@"ShareToken"],@"ProductId":self.dataDic[@"ProductId"],@"DeviceName":self.dataDic[@"DeviceName"]};
    [[TIoTCoreRequestObject shared] post:AppBindUserShareDevice Param:param success:^(id responseObject) {
//        STRONG
        [MBProgressHUD showMessage:LOCSTR(@"绑定成功") icon:@""];
        /*
       NSArray *ARRAY = [[NSUserDefaults standardUserDefaults] objectForKey:ShareTokenDeviceArr];
        //判断是否是第一次存
        if (ARRAY.count >=1 ) {
            NSArray *arrayNSU = [[NSUserDefaults standardUserDefaults] objectForKey:ShareTokenDeviceArr];
            NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:arrayNSU];
            [mutableArray addObject:self.dataDic];
            NSArray * array = [NSArray arrayWithArray:mutableArray];

            [[NSUserDefaults standardUserDefaults]setValue:array forKey:ShareTokenDeviceArr];
        }else{
            NSMutableArray *mutableArray = [NSMutableArray new];
            [mutableArray addObject:self.dataDic];
            NSArray * array = [NSArray arrayWithArray:mutableArray];
            [[NSUserDefaults standardUserDefaults]setValue:array forKey:ShareTokenDeviceArr];
        }
*/
//        NSLog(@"------绑定设备------%@=",responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:DeviceInformation object:nil];
    } failure:^(NSString *reason, NSError *error,NSDictionary *dic) {
        [MBProgressHUD showError:reason];
        [MethodTool judgeUserSignoutWithReturnToken:dic];

    }];
}
@end
