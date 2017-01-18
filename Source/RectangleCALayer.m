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
    Rectangle * _oldRectangle;
    Rectangle * _newRectangle;
    BOOL isDetecting;
}

//@property (nonatomic, strong) Rectangle * rectangle;

@end

@implementation RectangleCALayer

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.borderWidth = 2;
//        self.borderColor = [UIColor redColor].CGColor;
        self.delegate = self;
        isDetecting = NO;
    }
    return self;
}

-(void)updateDetect:(Rectangle *)rectangle
{
    
    
    if (rectangle)
    {
        if (isDetecting)
        {
            NSLog(@"执行动画中 放弃...");
            return;
        }
        
        isDetecting = YES;
        _newRectangle = rectangle;
        
     
        NSLog(@"开始 Detecting...");
        
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
        [self setNeedsDisplay];
        
        [CATransaction begin];
        // 创建Animation
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = @(0.0);
        animation.toValue = @(1.0);
        animation.duration = 0.4;
        animation.repeatCount = 1;
        animation.removedOnCompletion = YES;
        
        [CATransaction setCompletionBlock:^{
            isDetecting = NO;
            NSLog(@"动画执行完毕");
        }];
        // 设置layer的animation
        [self addAnimation:animation forKey:nil];
        //animation.delegate = self;
        [CATransaction commit];
    }
    
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    
    if ( _newRectangle ){
        
        /*
        UIGraphicsPushContext(context);
        
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        bezierPath.lineWidth = 2.0;
        
        bezierPath.lineCapStyle = kCGLineCapRound;
        bezierPath.lineJoinStyle = kCGLineCapRound;
        
        // 定义左上角，右上角，左下角，右下角
        CGPoint tlp, trp, blp, brp;
        
        if (_newRectangle.topLeftY - _newRectangle.topRightY > 0)
        {
            //(36,61),(245,56),(27,350),(330,317)
            if (_newRectangle.topLeftX - _newRectangle.bottomLeftX > 0)
            {
                tlp = CGPointMake(_newRectangle.topLeftX - _newRectangle.bottomLeftX, _newRectangle.topLeftY - _newRectangle.topRightY);
                trp = CGPointMake(_newRectangle.topRightX - _newRectangle.bottomLeftX, 0);
                blp = CGPointMake(0, _newRectangle.bottomLeftY - _newRectangle.topRightY);
                brp = CGPointMake(_newRectangle.bottomRightX - _newRectangle.bottomLeftX, _newRectangle.bottomRightY - _newRectangle.topRightY);
            }
            else{
                tlp = CGPointMake(0, _newRectangle.topLeftY - _newRectangle.topRightY);
                trp = CGPointMake(_newRectangle.topRightX - _newRectangle.topLeftX, 0);
                blp = CGPointMake(_newRectangle.bottomLeftX - _newRectangle.topLeftX, _newRectangle.bottomLeftY - _newRectangle.topRightY);
                brp = CGPointMake(_newRectangle.bottomRightX - _newRectangle.topLeftX, _newRectangle.bottomLeftY - _newRectangle.topRightY);
            }
        }
        else {
            if (_newRectangle.topLeftX - _newRectangle.bottomLeftX > 0)
            {
                tlp = CGPointMake(_newRectangle.topLeftX - _newRectangle.bottomLeftX, 0);
                trp = CGPointMake(_newRectangle.topRightX - _newRectangle.bottomLeftX, _newRectangle.topRightY - _newRectangle.topLeftY);
                blp = CGPointMake(0, _newRectangle.bottomRightY - _newRectangle.topLeftY);
                brp = CGPointMake(_newRectangle.bottomRightX - _newRectangle.bottomLeftX, _newRectangle.bottomRightY - _newRectangle.topLeftY);
            }else{
                tlp = CGPointMake(0, 0);
                trp = CGPointMake(_newRectangle.topRightX - _newRectangle.topLeftX, _newRectangle.topRightY - _newRectangle.topLeftY);
                blp = CGPointMake(_newRectangle.bottomLeftX - _newRectangle.topLeftX, _newRectangle.bottomLeftY - _newRectangle.topLeftY);
                brp = CGPointMake(_newRectangle.bottomRightX - _newRectangle.topLeftX, _newRectangle.bottomRightY - _newRectangle.topLeftY);
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
        
        
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
        CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:1 alpha:0.05] CGColor]);
        
        CGContextMoveToPoint(context, _newRectangle.topLeftX, _newRectangle.topLeftY);
        
        CGContextAddLineToPoint(context, _newRectangle.topRightX, _newRectangle.topRightY);
        
        CGContextAddLineToPoint(context, _newRectangle.bottomRightX, _newRectangle.bottomRightY);
        
        CGContextAddLineToPoint(context, _newRectangle.bottomLeftX, _newRectangle.bottomLeftY);
        
        CGContextAddLineToPoint(context, _newRectangle.topLeftX, _newRectangle.topLeftY);
        
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
