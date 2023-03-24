//
//  AddSceneViewCell.m
//  yingbin
//
//  Created by slxk on 2021/4/27.
//  Copyright © 2021 wq. All rights reserved.
//

#import "AddSceneViewCell.h"

@interface AddSceneViewCell ()

@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *titleContentLabel;
@property (nonatomic, strong)UIButton *cancelBtn;

@end

@implementation AddSceneViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UIColor.whiteColor;
        self.layer.cornerRadius = 3;
        [self setupUI];
    }
    return self;
}
-(void)setupUI{
    WEAK
    self.titleContentLabel = self.contentView
    .addLabel(0)
    .textColor(KColor333333)
    .font(KFont(14))
    .masonry(^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(-30);
    })
    .view;
    
    self.titleLabel = self.contentView
    .addLabel(0)
    .textColor(KColor333333)
    .font(KFont(14))
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.right.mas_equalTo(self.titleContentLabel.mas_left).mas_equalTo(-10);
    })
    .view;
    
    self.cancelBtn = self.contentView
    .addButton(1)
    .image(KImage(@"icon_cancel"))
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *x){
        STRONG
        if (self.cancelBlock) {
            self.cancelBlock(x);
        }
    })
    .masonry(^(MASConstraintMaker *make){
        make.right.mas_equalTo(-5);
        make.size.mas_equalTo(24);
        make.centerY.mas_equalTo(self.contentView);
    })
    .view;
    
    
    
}

-(void)setModel:(TIoTAutoIntelligentModel *)model{
    _model = model;
    
    if ([model.type isEqualToString:@"0"] || [model.type isEqualToString: @"1"]) {
        if (model.CondType == 0) {//设备
            self.titleContentLabel.text = LOCSTR(@"人体感应触发");
            self.titleLabel.text = [NSString stringWithFormat:@"%@：%@",LOCSTR(@"设备"),model.AliasName];//后期需要知道PropertyId = 这个”人体感应触发“传那个参数
        }else if(model.CondType == 1){//定时
            self.titleLabel.text = [NSString stringWithFormat:@"%@：%@  %@",LOCSTR(@"定时"),model.Timer.TimePoint,[self getShowResultForRepeat:model.Timer.Days]];
            self.titleContentLabel.text = @"";
        }
    }else if([model.type isEqualToString:@"2"]){
        if(model.ActionType == 0){
            NSData *jsonData = [model.Data dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            NSMutableDictionary *newDIC = [NSMutableDictionary dictionaryWithDictionary:dic];
//            self.titleContentLabel.text = [MethodTool getName:[newDIC[@"PlayTimer"] integerValue]];
            

            NSInteger integer = [newDIC[@"PlayTimer"] integerValue]-1;
            NSDictionary *psenseDic = model.deviceSetInfo[@"PSense"][@"Value"][integer];
            self.titleContentLabel.text = psenseDic[@"Name"];
            self.titleLabel.text = [NSString stringWithFormat:@"%@",model.AliasName];
        }
    }
   
    
    
}

- (NSString *)getShowResultForRepeat:(NSString *)days
{
    const char *repeats = [days UTF8String];
    
    NSString *con = @"";
    
    if ((BOOL)(repeats[1] - '0') == NO && (BOOL)(repeats[2] - '0') == NO && (BOOL)(repeats[3] - '0') == NO && (BOOL)(repeats[4] - '0') == NO && (BOOL)(repeats[5] - '0') == NO && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con = NSLocalizedString(@"周末", nil);
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') == NO && (BOOL)(repeats[0] - '0') == NO) {
        con = NSLocalizedString(@"工作日", nil);
    }
    else if ((BOOL)(repeats[1] - '0') && (BOOL)(repeats[2] - '0') && (BOOL)(repeats[3] - '0') && (BOOL)(repeats[4] - '0') && (BOOL)(repeats[5] - '0') && (BOOL)(repeats[6] - '0') && (BOOL)(repeats[0] - '0')) {
        con =NSLocalizedString(@"每天", nil);
    }
    else
    {
        
        for (unsigned int i = 0; i < 7; i ++) {
            if ((BOOL)(repeats[i] - '0')) {
                NSString *weakday = @"";
                switch (i) {
                    case 0:
                        weakday = NSLocalizedString(@"周日", nil);
                        break;
                    case 1:
                        weakday = NSLocalizedString(@"周一", nil) ;
                        break;
                    case 2:
                        weakday = NSLocalizedString(@"周二", nil);
                        break;
                    case 3:
                        weakday = NSLocalizedString(@"周三", nil);
                        break;
                    case 4:
                        weakday = NSLocalizedString(@"周四", nil);
                        break;
                    case 5:
                        weakday = NSLocalizedString(@"周五", nil);
                        break;
                    case 6:
                        weakday = NSLocalizedString(@"周六", nil);
                        break;

                    default:
                        break;
                }

                con = [NSString stringWithFormat:@"%@ %@",con,weakday];
            }
        }
    }
    
    return con;
}
@end
