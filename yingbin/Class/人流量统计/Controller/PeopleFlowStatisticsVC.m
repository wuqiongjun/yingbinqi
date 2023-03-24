//
//  PeopleFlowStatisticsVC.m
//  yingbin
//
//  Created by slxk on 2021/8/9.
//  Copyright © 2021 wq. All rights reserved.
//

#import "PeopleFlowStatisticsVC.h"
#import "LineChartView.h"

@interface PeopleFlowStatisticsVC ()

@end

@implementation PeopleFlowStatisticsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LOCSTR(@"人流量统计");
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *dateArr = [[[self getCurrentDayToLastServeDay] reverseObjectEnumerator] allObjects];
    NSMutableArray *xArray = [NSMutableArray array];
    NSMutableArray *yArray = [NSMutableArray array];
    NSMutableArray *resultArr = [UserManageCenter sharedUserManageCenter].CountHistoryList;
    NSInteger max = 0;
    
    for (int i = 0 ; i < dateArr.count; i++) {
        BOOL isCount = NO;
        [xArray addObject:[NSString stringWithFormat:@"%@",dateArr[i]]];
        
        for (NSMutableDictionary *dic in resultArr) {
            NSComparisonResult type = [NSDate compareDateString1:dateArr[i] dateString2:[MethodTool timestampTime:[dic[@"timestamp"] integerValue] andFormatter:@""] formatter:@"YYYY-MM-dd"];
            if (type == NSOrderedSame) {
                isCount = YES;
                [yArray addObject:dic[@"count"]];
            }
            
            if (i == 0) {
                max = [dic[@"count"] integerValue];
            }else{
                if (max < [dic[@"count"] integerValue]) {
                    max = [dic[@"count"] integerValue];
                }
            }
        }
        if (!isCount) {
            [yArray addObject:@"0"];
        }
        
    }
    
    

    if (max <= 100) {
        max = 100;
    }else if (max <= 200) {
        max = 200;
    }else if (max <= 300) {
        max = 300;
    }else if (max <= 400) {
        max = 400;
    }else if (max <= 500) {
        max = 500;
    }else if (max <= 600) {
        max = 600;
    }else if (max <= 700) {
        max = 700;
    }else if (max <= 800) {
        max = 800;
    }else if (max <= 900) {
        max = 900;
    }else if (max <= 1000) {
        max = 1000;
    }else if (max <= 2000) {
        max = 2000;
    }else if(max <= 3000){
        max = 3000;
    }else if(max <= 4000){
        max = 4000;
    }else if(max <= 5000){
        max = 5000;
    }else if(max <= 10000){
        max = 10000;
    }

    
    //这里你可以计算出yArray的最大最小值。设置为曲线的最大最小值，这样画出来的线占据整个y轴高度。
    //..........
    
    
    LineChartView *wsLine = [[LineChartView alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 500) xTitleArray:xArray yValueArray:yArray yMax:max yMin:0];
    [self.view addSubview:wsLine];
}

//获取当前日期开始的前七天日期
-(NSMutableArray *)getCurrentDayToLastServeDay{
    NSMutableArray *weekArr = [[NSMutableArray alloc] init];
    NSDate *nowDate = [NSDate date];
    for (int i = 1; i < 8; i ++) {
           //从现在开始的24小时
           NSTimeInterval secondsPerDay = -i * 24*60*60;
           NSDate *curDate = [NSDate dateWithTimeInterval:secondsPerDay sinceDate:nowDate];
           NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
           [dateFormatter setDateFormat:@"YYYY-MM-dd"];
           NSString *dateStr = [dateFormatter stringFromDate:curDate];
           [weekArr addObject:dateStr];
       }
    return weekArr;
}


@end
