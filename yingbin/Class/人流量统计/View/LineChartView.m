//
//  LineChartView.m
//  yingbin
//
//  Created by slxk on 2021/8/9.
//  Copyright © 2021 wq. All rights reserved.
//

#import "LineChartView.h"
#import "XAxisView.h"
#import "YAxisView.h"

#define leftMargin 45
//#define defaultSpace 10
#define lastSpace 50

@interface LineChartView ()

@property (strong, nonatomic) NSArray *xTitleArray;
@property (strong, nonatomic) NSArray *yValueArray;
@property (assign, nonatomic) CGFloat yMax;
@property (assign, nonatomic) CGFloat yMin;
@property (strong, nonatomic) YAxisView *yAxisView;
@property (strong, nonatomic) XAxisView *xAxisView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) CGFloat pointGap;
@property (assign, nonatomic) CGFloat defaultSpace;//间距

@property (assign, nonatomic) CGFloat moveDistance;

@end

@implementation LineChartView

- (id)initWithFrame:(CGRect)frame xTitleArray:(NSArray*)xTitleArray yValueArray:(NSArray*)yValueArray yMax:(CGFloat)yMax yMin:(CGFloat)yMin {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.xTitleArray = xTitleArray;
        self.yValueArray = yValueArray;
        self.yMax = yMax;
        self.yMin = yMin;
        
        self.pointGap = 40;
        
        [self creatYAxisView];
        
        [self creatXAxisView];
        
        
        //拖拽手势
        UIPanGestureRecognizer *longPress = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressAction:)];
        [self.xAxisView addGestureRecognizer:longPress];
        

        
        
    }
    return self;
}



- (void)creatYAxisView {
    
    self.yAxisView = [[YAxisView alloc]initWithFrame:CGRectMake(0, 0, leftMargin, self.frame.size.height) yMax:self.yMax yMin:self.yMin];
    [self addSubview:self.yAxisView];
    
}

- (void)creatXAxisView {
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(leftMargin, 0, self.frame.size.width-leftMargin, self.frame.size.height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = NO;
    [self addSubview:_scrollView];
    
    self.xAxisView = [[XAxisView alloc] initWithFrame:CGRectMake(0, 0, self.xTitleArray.count * self.pointGap + lastSpace, self.frame.size.height) xTitleArray:self.xTitleArray yValueArray:self.yValueArray yMax:self.yMax yMin:self.yMin];
    
    [_scrollView addSubview:self.xAxisView];
    
    _scrollView.contentSize = self.xAxisView.frame.size;
    
}


- (void)event_longPressAction:(UILongPressGestureRecognizer *)longPress {
    
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state) {
        
        CGPoint location = [longPress locationInView:self.xAxisView];
        
        //相对于屏幕的位置
        CGPoint screenLoc = CGPointMake(location.x - self.scrollView.contentOffset.x, location.y);
        [self.xAxisView setScreenLoc:screenLoc];
        
        if (ABS(location.x - _moveDistance) > self.pointGap) { //不能长按移动一点点就重新绘图  要让定位的点改变了再重新绘图
            
            [self.xAxisView setIsShowLabel:YES];
            [self.xAxisView setIsLongPress:YES];
            self.xAxisView.currentLoc = location;
            _moveDistance = location.x;
        }
    }
    
    if(longPress.state == UIGestureRecognizerStateEnded)
    {
        //恢复scrollView的滑动
        [self.xAxisView setIsLongPress:NO];
        [self.xAxisView setIsShowLabel:NO];
        
    }
}


@end
