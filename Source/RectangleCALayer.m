//
//  RectangleCALayer.m
//  DocBox
//
//  Created by Dan Bucholtz on 8/26/14.
//  Copyright (c) 2014 Mod618. All rights reserved.
//

#import "RectangleCALayer.h"
#import "UIKit/UIKit.h"
#import "Rectangle.h"

@interface RectangleCALayer() <CALayerDelegate>
{
    // 当前找到的矩形区域
    Rectangle * _rectangle;
    
    // 是否在执行动画中
    BOOL _isAnimating;
}

@end

@implementation RectangleCALayer

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.borderWidth = 2;
//        self.borderColor = [UIColor redColor].CGColor;
        self.delegate = self;
        _isAnimating = NO;
    }
    return self;
}

-(Rectangle *)getCurrentRectangle
{
    return _rectangle;
}

-(void)updateDetect:(Rectangle *)rectangle
{
    if (_isAnimating)
    {
        NSLog(@"执行动画中 放弃当前找到的矩形区域...");
        return;
    }
    
    NSLog(@"开始绘制...%@",rectangle);
    _rectangle = rectangle;
    [self setNeedsDisplay];
    
    if (rectangle)
    {
        NSLog(@"执行动画...");
        _isAnimating = YES;
        [CATransaction begin];
        // 创建Animation
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @(0.0);
        animation.toValue = @(1.0);
        animation.duration = 0.4;
        animation.repeatCount = 1;
        animation.removedOnCompletion = YES;
        
        [CATransaction setCompletionBlock:^{
            _isAnimating = NO;
            NSLog(@"动画执行完毕");
        }];
        // 设置layer的animation
        [self addAnimation:animation forKey:nil];
        //animation.delegate = self;
        [CATransaction commit];
    }
    
    
    
    /*
     int w1 = abs(rectangle.topRightX - rectangle.topLeftX);
     int w2 = abs(rectangle.topRightX - rectangle.bottomLeftX);
     int w3 = abs(rectangle.bottomRightX - rectangle.bottomLeftX);
     int w4 = abs(rectangle.bottomRightX - rectangle.topLeftX);
     
     
     int h1 = abs(rectangle.bottomLeftY - rectangle.topLeftY);
     int h2 = abs(rectangle.bottomLeftY - rectangle.topRightY);
     int h3 = abs(rectangle.bottomRightY - rectangle.topRightY);
     int h4 = abs(rectangle.bottomRightY - rectangle.topLeftY);
     
     int maxWidth = MAX(MAX(w1,w2),MAX(w3,w4));
     int maxHeight = MAX(MAX(h1,h2),MAX(h3,h4));
     
     self.frame = CGRectMake(MIN(rectangle.topLeftX, rectangle.bottomLeftX),
     MIN(rectangle.topLeftY, rectangle.bottomLeftY),
     maxWidth,
     maxHeight);
     */
    
    
    
    
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    
    if ( _rectangle ){
        
        /*
        UIGraphicsPushContext(context);
        
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineWidth = 2.0;
        
        bezierPath.lineCapStyle = kCGLineCapRound;
        bezierPath.lineJoinStyle = kCGLineCapRound;
        
        // 定义左上角，右上角，左下角，右下角
        CGPoint tlp, trp, blp, brp;
        
        if (_rectangle.topLeftY - _rectangle.topRightY > 0)
        {
            //(36,61),(245,56),(27,350),(330,317)
            if (_rectangle.topLeftX - _rectangle.bottomLeftX > 0)
            {
                tlp = CGPointMake(_rectangle.topLeftX - _rectangle.bottomLeftX, _rectangle.topLeftY - _rectangle.topRightY);
                trp = CGPointMake(_rectangle.topRightX - _rectangle.bottomLeftX, 0);
                blp = CGPointMake(0, _rectangle.bottomLeftY - _rectangle.topRightY);
                brp = CGPointMake(_rectangle.bottomRightX - _rectangle.bottomLeftX, _rectangle.bottomRightY - _rectangle.topRightY);
            }
            else{
                tlp = CGPointMake(0, _rectangle.topLeftY - _rectangle.topRightY);
                trp = CGPointMake(_rectangle.topRightX - _rectangle.topLeftX, 0);
                blp = CGPointMake(_rectangle.bottomLeftX - _rectangle.topLeftX, _rectangle.bottomLeftY - _rectangle.topRightY);
                brp = CGPointMake(_rectangle.bottomRightX - _rectangle.topLeftX, _rectangle.bottomLeftY - _rectangle.topRightY);
            }
        }
        else {
            if (_rectangle.topLeftX - _rectangle.bottomLeftX > 0)
            {
                tlp = CGPointMake(_rectangle.topLeftX - _rectangle.bottomLeftX, 0);
                trp = CGPointMake(_rectangle.topRightX - _rectangle.bottomLeftX, _rectangle.topRightY - _rectangle.topLeftY);
                blp = CGPointMake(0, _rectangle.bottomRightY - _rectangle.topLeftY);
                brp = CGPointMake(_rectangle.bottomRightX - _rectangle.bottomLeftX, _rectangle.bottomRightY - _rectangle.topLeftY);
            }else{
                tlp = CGPointMake(0, 0);
                trp = CGPointMake(_rectangle.topRightX - _rectangle.topLeftX, _rectangle.topRightY - _rectangle.topLeftY);
                blp = CGPointMake(_rectangle.bottomLeftX - _rectangle.topLeftX, _rectangle.bottomLeftY - _rectangle.topLeftY);
                brp = CGPointMake(_rectangle.bottomRightX - _rectangle.topLeftX, _rectangle.bottomRightY - _rectangle.topLeftY);
            }
        }
        
        NSLog(@"LT:%@ RT:%@ LB:%@ RB:%@", NSStringFromCGPoint(tlp),NSStringFromCGPoint(trp),NSStringFromCGPoint(blp),NSStringFromCGPoint(brp));
        
        // 起点
        [bezierPath moveToPoint:tlp];
        
        // 绘制线条
        [bezierPath addLineToPoint:trp];
        [bezierPath addLineToPoint:brp];
        [bezierPath addLineToPoint:blp];
        [bezierPath closePath];//第五条线通过调用closePath方法得到的
        
        // 设置颜色
        [[UIColor greenColor] setStroke];
        [[UIColor colorWithWhite:1 alpha:0.25] setFill];
        
        //根据坐标点连线
        [bezierPath stroke];
        [bezierPath fill];
        
        */
        
//        CGContextSetRGBFillColor(context, 1.0,1.0,1.0,0.65);
//        CGContextFillRect(context,self.bounds);
        
        CGContextSetLineWidth(context, 2.0);
        
        CGContextMoveToPoint(context, _rectangle.topLeftX, _rectangle.topLeftY);
        CGContextAddLineToPoint(context, _rectangle.topRightX, _rectangle.topRightY);
        CGContextAddLineToPoint(context, _rectangle.bottomRightX, _rectangle.bottomRightY);
        CGContextAddLineToPoint(context, _rectangle.bottomLeftX, _rectangle.bottomLeftY);
        CGContextClosePath(context);
        
        CGContextSetRGBFillColor(context, 1.0,1.1,1.0,0.1);
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
}


//#pragma mark - CAAnimationDelegate
//- (void)animationDidStart:(CAAnimation *)anim
//{
//    
//}
//
//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
//{
//    isDetecting = NO;
//    NSLog(@"动画执行完毕");
//}



@end
