//
//  TimingViewController.m
//  yingbin
//
//  Created by slxk on 2021/4/24.
//  Copyright © 2021 wq. All rights reserved.
//

#import "TimingViewController.h"
#import "ChongfuViewController.h"
#import "AddSceneViewController.h"
@interface TimingViewController ()<TimePickerViewDelegate>

@property (nonatomic, strong)UILabel *CFLabel;

@property (nonatomic, strong) NSString *hour;
@property (nonatomic, strong) NSString *min;

@property (nonatomic, strong)UILabel *timeLabel;
@property (nonatomic,strong) NSString *repeatData;//重复数据

@end

@implementation TimingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"定时");

    self.navigationItem.rightBarButtonItem = self.saveButtonItem;

    [self createSubviews];
    if (self.isEdit == YES) {
        [self setCellSupView];
    }else{
        self.timeLabel.text = [MethodTool getCurrentTimesHHSS];
        NSArray *timeArray = [self.timeLabel.text componentsSeparatedByString:@":"];
        self.hour = timeArray[0];
        self.min = timeArray[1];
    }
}

//保存
- (void)saveItemClick:(UIBarButtonItem *)btn{
    
    NSString *timeTamp = [NSString getNowTimeString];
    
    if (self.isEdit) {//编辑
        self.model.Timer.Days = [MethodTool isBlankString:self.repeatData]?self.model.Timer.Days:self.repeatData;
        self.model.Timer.TimePoint = self.timeLabel.text;
        [self.navigationController popViewControllerAnimated:YES];
        if (self.updateTimerBlock) {
            self.updateTimerBlock(self.model);
        }
    }else{//创建
        if ([MethodTool isBlankString:self.timeLabel.text]) {
            [MBProgressHUD showError:LOCSTR(@"请选择执行时间")];
            return;
        }
        NSString *days = [MethodTool isBlankString:self.repeatData]?@"0000000":self.repeatData;

        NSDictionary *timerSelectDic = @{@"Days":days,@"TimePoint":self.timeLabel.text};
        NSDictionary *timerDic = @{@"CondId":timeTamp,@"CondType":@(1),@"Timer":timerSelectDic,@"type":@"1"};
        TIoTAutoIntelligentModel *timerModel = [TIoTAutoIntelligentModel yy_modelWithJSON:timerDic];

        AddSceneViewController *VC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-3];
        VC.addConditionModel = timerModel;
        [[NSNotificationCenter defaultCenter] postNotificationName:CHANGJING_TIAOJIAN object:nil];
        [self.navigationController popToViewController:VC animated:true];

    }
}
-(void)createSubviews{
    WEAK
    UIButton *bgCFView = self.view
    .addButton(0)
    .backgroundColor(UIColor.whiteColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        //星期几勾选返回
        ChongfuViewController *vc = [[ChongfuViewController alloc]init];
        vc.days = self.model.Timer.Days;
        if (self.repeatData) {
            vc.days = self.repeatData;
        }
        vc.repeatResult = ^(NSArray *repeats) {
            STRONG
            self.repeatData = [repeats componentsJoinedByString:@""];
            self.CFLabel.text = [MethodTool isBlankString:[self getShowResultForRepeat:self.repeatData]]?LOCSTR(@"仅限一次"):[self getShowResultForRepeat:self.repeatData];
        };
        PushVC(vc);
    })
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12.0);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(5);
        make.height.mas_equalTo(54);
    })
    .view;
    bgCFView.layer.cornerRadius = 9;
    
    UILabel *titleCF = bgCFView
    .addLabel(0)
    .font(KFont(14))
    .text(LOCSTR(@"重复"))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.0);
        make.centerY.mas_equalTo(bgCFView);
    })
    .view;
    
    UIImageView *jiantouImage = bgCFView
    .addImageView(0)
    .image(KImage(@"icon_jiantou"))
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.centerY.mas_equalTo(bgCFView);
        make.size.mas_equalTo(13);
    })
    .view;
    
    self.CFLabel = bgCFView
    .addLabel(1)
    .font(KFont(12))
    .textColor(KColor999999)
    .text(LOCSTR(@"仅限一次"))
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(jiantouImage.mas_left).mas_offset(-10);
        make.centerY.mas_equalTo(bgCFView);
    })
    .view;
    
    UIButton *bgTimeVIew = self.view
    .addButton(1)
    .backgroundColor(UIColor.whiteColor)
    .eventBlock(UIControlEventTouchUpInside,^(UIButton *btn){
        STRONG
        WQTimePickerView *picker = [[WQTimePickerView alloc]initDatePackerWithStartHour:@"00" endHour:@"24" period:1 selectedHour:self.hour selectedMin:self.min tag:@"1" title:LOCSTR(@"执行时间")];
        picker.delegate = self;
        [picker show];
    })
    .masonry(^(MASConstraintMaker *make) {
        make.left.right.height.mas_equalTo(bgCFView);
        make.top.mas_equalTo(bgCFView.mas_bottom).mas_offset(15);
    })
    .view;
    bgTimeVIew.layer.cornerRadius = 9;

    
    UILabel *titleTime = bgTimeVIew
    .addLabel(0)
    .font(KFont(14))
    .text(LOCSTR(@"设置开始执行时间"))
    .textColor(KColor333333)
    .masonry(^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleCF);
        make.centerY.mas_equalTo(bgTimeVIew);
    })
    .view;
    
    UIImageView *jiantou = bgTimeVIew
    .addImageView(0)
    .image(KImage(@"icon_jiantou"))
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-12);
        make.centerY.mas_equalTo(titleTime);
        make.size.mas_equalTo(13);
    })
    .view;
    
    self.timeLabel = bgTimeVIew
    .addLabel(1)
    .font(KFont(12))
    .textColor(KColor999999)
    .masonry(^(MASConstraintMaker *make) {
        make.right.mas_equalTo(jiantou.mas_left).mas_offset(-10);
        make.centerY.mas_equalTo(bgTimeVIew);
    })
    .view;
    
    
}

-(void)timePickerViewDidSelectRow:(NSString *)Hour MIN:(NSString *)min tag:(NSString *)tag{
    self.hour = Hour;
    self.min = min;
    self.timeLabel.text = [NSString stringWithFormat:@"%@:%@",Hour,min];
}

//赋值
-(void)setCellSupView{
    NSString *days = [self getShowResultForRepeat:self.model.Timer.Days];
    if ([MethodTool isBlankString:days]) {
        self.CFLabel.text = LOCSTR(@"仅限一次");
    }else{
        self.CFLabel.text = days;
    }
    self.timeLabel.text = self.model.Timer.TimePoint;
    NSArray *timeArray = [self.model.Timer.TimePoint componentsSeparatedByString:@":"];
    self.hour = timeArray[0];
    self.min = timeArray[1];
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
