//
//  XAxisView.m
//  yingbin
//
//  Created by slxk on 2021/8/9.
//  Copyright © 2021 wq. All rights reserved.
//

#import "XAxisView.h"

#define topMargin 50   // 为顶部留出的空白
#define kChartLineColor         [UIColor grayColor]
#define kChartTextColor         KColor8C8C8C
//#define defaultSpace 5
#define leftMargin 45
#define kScreenWidth [UIScreen mainScreen].bounds.size.width


@interface XAxisView ()

@property (strong, nonatomic) NSArray *xTitleArray;
@property (strong, nonatomic) NSArray *yValueArray;
@property (assign, nonatomic) CGFloat yMax;
@property (assign, nonatomic) CGFloat yMin;

@property (assign, nonatomic) CGFloat defaultSpace;

/**
 *  记录坐标轴的第一个frame
 */
@property (assign, nonatomic) CGRect firstFrame;
@property (assign, nonatomic) CGRect firstStrFrame;//第一个点的文字的frame

@property (strong, nonatomic) NSString *xTypeName;
@property (strong, nonatomic) NSString *yTypeName;
@end



@implementation XAxisView

- (id)initWithFrame:(CGRect)frame xTitleArray:(NSArray*)xTitleArray yValueArray:(NSArray*)yValueArray yMax:(CGFloat)yMax yMin:(CGFloat)yMin {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.xTitleArray = xTitleArray;
        self.yValueArray = yValueArray;
        self.yMax = yMax;
        self.yMin = yMin;
        self.xTypeName = @"";
        self.yTypeName = LOCSTR(@"人流量");

        
        if (xTitleArray.count > 600) {
            _defaultSpace = 5;
        }
        else if (xTitleArray.count > 400 && xTitleArray.count <= 600){
            _defaultSpace = 10;
        }
        else if (xTitleArray.count > 200 && xTitleArray.count <= 400){
            _defaultSpace = 20;
        }
        else if (xTitleArray.count > 100 && xTitleArray.count <= 200){
            _defaultSpace = 30;
        }
        else {
            _defaultSpace = 40;
        }

        self.pointGap = _defaultSpace;

        
    }
    
    return self;
}

- (void)setPointGap:(CGFloat)pointGap {
    _pointGap = pointGap;
    
    [self setNeedsDisplay];
}

- (void)setIsLongPress:(BOOL)isLongPress {
    _isLongPress = isLongPress;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    ////////////////////// X轴文字 //////////////////////////
    // 添加坐标轴Label
    for (int i = 0; i < self.xTitleArray.count; i++) {
        NSArray *array = [self.xTitleArray[i] componentsSeparatedByString:@"-"];
        NSString *title = [NSString stringWithFormat:@"%@-%@",array[1],array.lastObject];
        
        
        [[UIColor blackColor] set];
        NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:10]};
        CGSize labelSize = [title sizeWithAttributes:attr];
        
        CGRect titleRect = CGRectMake((i + 1) * self.pointGap - labelSize.width / 2,self.frame.size.height - labelSize.height,labelSize.width,labelSize.height);
        
        if (i == 0) {
            self.firstFrame = titleRect;
            if (titleRect.origin.x < 0) {
                titleRect.origin.x = 0;
            }
            
            [title drawInRect:titleRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:kChartTextColor}];
            
            //画垂直X轴的竖线
            [self drawLine:context
                startPoint:CGPointMake(titleRect.origin.x+labelSize.width/2, self.frame.size.height - labelSize.height-5)
                  endPoint:CGPointMake(titleRect.origin.x+labelSize.width/2, self.frame.size.height - labelSize.height-10)
                 lineColor:kChartLineColor
                 lineWidth:1];
        }
        // 如果Label的文字有重叠，那么不绘制
        CGFloat maxX = CGRectGetMaxX(self.firstFrame);
        if (i != 0) {
            if ((maxX + 3) > titleRect.origin.x) {
                //不绘制
                
            }else{
                
                [title drawInRect:titleRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:kChartTextColor}];
                //画垂直X轴的竖线
                [self drawLine:context
                    startPoint:CGPointMake(titleRect.origin.x+labelSize.width/2, self.frame.size.height - labelSize.height-5)
                      endPoint:CGPointMake(titleRect.origin.x+labelSize.width/2, self.frame.size.height - labelSize.height-10)
                     lineColor:kChartLineColor
                     lineWidth:1];
                
                self.firstFrame = titleRect;
            }
        }else {
            if (self.firstFrame.origin.x < 0) {
                
                CGRect frame = self.firstFrame;
                frame.origin.x = 0;
                self.firstFrame = frame;
            }
        }
        
    }
    
    //////////////// 画原点上的x轴 ///////////////////////
    NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:10]};
    CGSize textSize = [@"x" sizeWithAttributes:attribute];
    
    [self drawLine:context
        startPoint:CGPointMake(0, self.frame.size.height - textSize.height - 5)
          endPoint:CGPointMake(self.frame.size.width, self.frame.size.height - textSize.height - 5)
         lineColor:KColorE5E5E5
         lineWidth:1];
    
    
    //////////////// 画横向分割线 ///////////////////////
    CGFloat separateMargin = (self.frame.size.height - topMargin - textSize.height - 5 - 5 * 1) / 10;
    for (int i = 0; i < 10; i++) {
        
        [self drawLine:context
            startPoint:CGPointMake(0, self.frame.size.height - textSize.height - 5  - (i + 1) *(separateMargin + 1))
              endPoint:CGPointMake(0+self.frame.size.width, self.frame.size.height - textSize.height - 5  - (i + 1) *(separateMargin + 1))
             lineColor:[UIColor lightGrayColor]
             lineWidth:.1];
    }
    
    
    /////////////////////// 根据数据源画折线 /////////////////////////
    if (self.yValueArray && self.yValueArray.count > 0) {
        
        //画折线
        for (NSInteger i = 0; i < self.yValueArray.count; i++) {
            
            //如果是最后一个点
            if (i == self.yValueArray.count-1) {
                
                NSNumber *endValue = self.yValueArray[i];
                CGFloat chartHeight = self.frame.size.height - textSize.height - 5 - topMargin;
                CGPoint endPoint = CGPointMake((i+1)*self.pointGap, chartHeight -  (endValue.floatValue-self.yMin)/(self.yMax-self.yMin) * chartHeight+topMargin);
                
                //画最后一个点
                UIColor*aColor = KThemeColor; //点的颜色
                CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
                CGContextAddArc(context, endPoint.x, endPoint.y, 1, 0, 2*M_PI, 0); //添加一个圆
                CGContextDrawPath(context, kCGPathFill);//绘制填充
                
                
                //画点上的文字
                NSString *str = [NSString stringWithFormat:@"%.2f", endValue.floatValue];
                // 判断是不是小数
                if ([self isPureFloat:endValue.floatValue]) {
                    str = [NSString stringWithFormat:@"%.2f", endValue.floatValue];
                }
                else {
                    str = [NSString stringWithFormat:@"%.0f", endValue.floatValue];
                }
                
                NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:10]};
                CGSize strSize = [str sizeWithAttributes:attr];
                
                CGRect strRect = CGRectMake(endPoint.x-strSize.width/2,endPoint.y-strSize.height,strSize.width,strSize.height);
                
                // 如果点的文字有重叠，那么不绘制
                CGFloat maxX = CGRectGetMaxX(self.firstStrFrame);
                if (i != 0) {
                    if ((maxX + 3) > strRect.origin.x) {
                        //不绘制
                        
                    }else{
                        
                        [str drawInRect:strRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:kChartTextColor}];
                        
                        self.firstStrFrame = strRect;
                    }
                }else {
                    if (self.firstStrFrame.origin.x < 0) {
                        
                        CGRect frame = self.firstStrFrame;
                        frame.origin.x = 0;
                        self.firstStrFrame = frame;
                    }
                }
                
            }else {
                
                NSNumber *startValue = self.yValueArray[i];
                NSNumber *endValue = self.yValueArray[i+1];
                CGFloat chartHeight = self.frame.size.height - textSize.height - 5 - topMargin;
                
                CGPoint startPoint = CGPointMake((i+1)*self.pointGap, chartHeight -  (startValue.floatValue-self.yMin)/(self.yMax-self.yMin) * chartHeight+topMargin);
                CGPoint endPoint = CGPointMake((i+2)*self.pointGap, chartHeight -  (endValue.floatValue-self.yMin)/(self.yMax-self.yMin) * chartHeight+topMargin);
                
                CGFloat normal[1]={1};
                CGContextSetLineDash(context,0,normal,0); //画实线
                
                //折线 两点连线
                [self drawLine:context startPoint:startPoint endPoint:endPoint lineColor:KThemeColor lineWidth:2];
                
                
                //画点
                UIColor*aColor = KThemeColor; //点的颜色
                CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
                CGContextAddArc(context, startPoint.x, startPoint.y, 1, 0, 2*M_PI, 0); //添加一个圆
                CGContextDrawPath(context, kCGPathFill);//绘制填充
                
                
                if (!_isShowLabel) {
                    
                    //画点上的文字
                    NSString *str = [NSString stringWithFormat:@"%.0f", endValue.floatValue];
                    // 判断是不是小数
                    if ([self isPureFloat:startValue.floatValue]) {
                        str = [NSString stringWithFormat:@"%.2f", startValue.floatValue];
                    }
                    else {
                        
                        str = [NSString stringWithFormat:@"%.0f", startValue.floatValue];
                    }
                    
                    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:10]};
                    CGSize strSize = [str sizeWithAttributes:attr];
                    
                    CGRect strRect = CGRectMake(startPoint.x-strSize.width/2,startPoint.y-strSize.height,strSize.width,strSize.height);
                    if (i == 0) {
                        self.firstStrFrame = strRect;
                        if (strRect.origin.x < 0) {
                            strRect.origin.x = 0;
                        }
                        
                        [str drawInRect:strRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:kChartTextColor}];
                    }
                    // 如果点的文字有重叠，那么不绘制
                    CGFloat maxX = CGRectGetMaxX(self.firstStrFrame);
                    //            NSLog(@"%f   %f",maxX,strRect.origin.x);
                    if (i != 0) {
                        if ((maxX + 3) > strRect.origin.x) {
                            //不绘制
                            
                        }else{
                            
                            [str drawInRect:strRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:kChartTextColor}];
                            
                            self.firstStrFrame = strRect;
                        }
                    }else {
                        if (self.firstStrFrame.origin.x < 0) {
                            
                            CGRect frame = self.firstStrFrame;
                            frame.origin.x = 0;
                            self.firstStrFrame = frame;
                        }
                    }
                }
            }
            
            
        }
    }
    
    
    //长按时进入
//    if(self.isLongPress)
//    {
        NSLog(@"%f",_currentLoc.x/self.pointGap);
        int nowPoint = _currentLoc.x/self.pointGap;
        if(nowPoint >= 0 && nowPoint < [self.yValueArray count]) {
            
            NSNumber *num = [self.yValueArray objectAtIndex:nowPoint];
            CGFloat chartHeight = self.frame.size.height - textSize.height - 5 - topMargin;

            CGPoint selectPoint = CGPointMake((nowPoint+1)*self.pointGap, chartHeight -  (num.floatValue-self.yMin)/(self.yMax-self.yMin) * chartHeight+topMargin);


            CGContextSaveGState(context);

            
            //计算文字最大长度，以便于设置背景宽度
            CGFloat timeWidth = [[NSString stringWithFormat:@"%@",self.xTitleArray[nowPoint]] sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSForegroundColorAttributeName:UIColor.whiteColor}].width;
//            CGFloat dataWidth = [[NSString stringWithFormat:@"%@:%@%@", self.yTypeName,[NSString stringWithFormat:@"%@",num],self.unit] sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSForegroundColorAttributeName:[UIColor whiteColor]}].width;
            CGFloat dataWidth = [[NSString stringWithFormat:@"%@:%@", self.yTypeName,[NSString stringWithFormat:@"%@",num]] sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSForegroundColorAttributeName:UIColor.whiteColor}].width;

            CGFloat with = timeWidth > dataWidth ? timeWidth : dataWidth;
            CGFloat shadowWith = with+20;
            
            //画文字所在的位置  动态变化
            CGPoint drawPoint = CGPointZero;
            if(_screenLoc.x-shadowWith/2 > 0 && _screenLoc.x
               +shadowWith/2 < kScreenWidth-leftMargin) {
                //如果按住的位置在屏幕靠右边边并且在屏幕靠上面的地方   那么字就显示在按住位置的左上角40 60位置
                drawPoint = CGPointMake(selectPoint.x-shadowWith/2, selectPoint.y-45);
            }
            else if(_screenLoc.x >((kScreenWidth-leftMargin)/2)) {
                //如果按住的位置在屏幕靠右边边并且在屏幕靠上面的地方   那么字就显示在按住位置的左上角40 60位置
                drawPoint = CGPointMake(selectPoint.x-shadowWith-5, selectPoint.y-20);
            }
            else if (_screenLoc.x <= ((kScreenWidth-leftMargin)/2)) {
                //如果按住的位置在屏幕靠左边边并且在屏幕靠上面的地方   那么字就显示在按住位置的右上角上角40 40位置
                drawPoint = CGPointMake(selectPoint.x+5, selectPoint.y-20);

            }
            CGFloat normal[]={2,2};
            CGContextSetLineDash(context, 0, normal,2);
            //画竖线虚线
            [self drawLine:context startPoint:CGPointMake(selectPoint.x, 0) endPoint:CGPointMake(selectPoint.x, self.frame.size.height- textSize.height - 5) lineColor:[UIColor lightGrayColor] lineWidth:1];
            
            // 交界点
            CGRect myOval = {selectPoint.x-2, selectPoint.y-2, 4, 4};
            CGContextSetFillColorWithColor(context, KThemeColor.CGColor);
            CGContextAddEllipseInRect(context, myOval);
            CGContextFillPath(context);
            
            
            //设置数据背景，放在竖线之后加载，不会被竖线遮住
            CGContextSetFillColorWithColor(context, RGBAColor(1, 0, 0, 0.5).CGColor);
            CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(drawPoint.x, drawPoint.y, with+20, 40) cornerRadius:10].CGPath;
            CGContextAddPath(context, clippath);
            CGContextClosePath(context);
            CGContextDrawPath(context, kCGPathFill);

            [[NSString stringWithFormat:@"%@",self.xTitleArray[nowPoint]] drawInRect:CGRectMake(drawPoint.x+10, drawPoint.y+5, with, 15) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSForegroundColorAttributeName:UIColor.whiteColor}];
            [[NSString stringWithFormat:@"%@:%@", self.yTypeName,[NSString stringWithFormat:@"%@",num]] drawInRect:CGRectMake(drawPoint.x+10, drawPoint.y+20, with, 15) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13],NSForegroundColorAttributeName:UIColor.whiteColor}];

            

        }
//    }
    
    
    NSDictionary *waterAttr = @{NSFontAttributeName : [UIFont systemFontOfSize:10]};
    CGSize waterLabelSize = [LOCSTR(@"日期") sizeWithAttributes:waterAttr];
    CGRect waterRect = CGRectMake(self.frame.size.width - 1-5 - waterLabelSize.width, self.frame.size.height-waterLabelSize.height,waterLabelSize.width,waterLabelSize.height);
    [LOCSTR(@"日期") drawInRect:waterRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:kChartTextColor}];
    
}

- (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width {
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Linecolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Linecolorspace1);
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    CGColorSpaceRelease(Linecolorspace1);
}


// 判断是小数还是整数
- (BOOL)isPureFloat:(CGFloat)num {
    int i = num;
    
    CGFloat result = num - i;
    
    // 当不等于0时，是小数
    return result != 0;
}
@end
