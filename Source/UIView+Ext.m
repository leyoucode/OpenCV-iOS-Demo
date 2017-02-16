//
//  UIView+Ext.h
//  HFHFinance
//
//  Created by 刘伟 on 15/11/9.
//  Copyright © 2015年 慧富汇. All rights reserved.
//

#import "UIView+Ext.h"

@implementation UIView(Ext)


+(void)modifyViewWidth:(CGFloat)width view:(UIView*)view
{
    if (view == nil) {
        return;
    }
    
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        if (label.textAlignment == NSTextAlignmentRight) {
            view.frame = CGRectMake(CGRectGetMaxX(view.frame)-width, view.frame.origin.y, width, view.frame.size.height);
            return;
        } else if (label.textAlignment == NSTextAlignmentCenter) {
            CGFloat oriWidth = view.frame.size.width;
            CGPoint oriCenter = view.center;
            view.frame = CGRectMake(CGRectGetMidX(view.frame)-((width - oriWidth)/2.0f), view.frame.origin.y, width, view.frame.size.height);
            view.center = oriCenter;
            return;
        }
    }
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, view.frame.size.height);
}


+(void)modifyViewHeigth:(CGFloat)height view:(UIView*)view
{
    if (view == nil) {
        return;
    }
    
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height);
}

+(void)modifyViewOrigin:(CGPoint)point view:(UIView*)view
{
    if (view == nil) {
        return;
    }
    
    view.frame = CGRectMake(point.x, point.y, view.frame.size.width, view.frame.size.height);
}

-(CGFloat)getViewLeft
{
    return self.frame.origin.x;
}

-(CGFloat)getViewTop
{
    return self.frame.origin.y;
}

-(CGFloat)getViewRight
{
    return (self.frame.origin.x + self.frame.size.width);
}

-(CGFloat)getViewBottem
{
    return (self.frame.origin.y + self.frame.size.height);
}


-(void)setTheSameBottemWithView:(UIView*)view
{
    self.frame = CGRectMake(self.frame.origin.x, VIEW_BOTTEM(view) - VIEW_HEIGHT(self), VIEW_WIDTH(self), VIEW_HEIGHT(self));
}

-(void)fitToVerticalCenterWithView:(UIView*)view
{
    self.frame = CGRectMake(self.frame.origin.x, (view.frame.size.height - self.frame.size.height)/2, self.frame.size.width, self.frame.size.height);
}

-(void)fitToHorizontalCenterWithView:(UIView*)view
{
    self.frame = CGRectMake((view.frame.size.width - self.frame.size.width)/2, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

-(void)makeTopRightFrameWithPoint:(CGPoint)point width:(CGFloat)width height:(CGFloat)height
{
    self.frame = CGRectMake(point.x - width, point.y, width, height);
}

-(void)modifyWidthToLeft:(CGFloat)width
{
    if (width <= 0) {
        width = 0;
    }
    
    CGFloat gap = self.frame.size.width - width;
    [self modifyWidth:width];
    [self modifyOrigi:CGPointMake(self.frame.origin.x - gap, self.frame.origin.y)];
}
-(void)modifyBottem:(CGFloat)bottem
{
    [self modifyY:bottem - self.frame.size.height];
}

-(void)modifyRight:(CGFloat)right
{
    [self modifyX:right - self.frame.size.width];
}

-(void)modifyWidth:(CGFloat)width
{
    if (width <= 0) {
        width = 0;
    }
    [UIView modifyViewWidth:width view:self];
}

-(void)modifySize:(CGSize)size
{
    [self modifyWidth:size.width];
    [self modifyHeight:size.height];
}

-(void)modifyWidthToRight:(CGFloat)width
{
    if (width <= 0) {
        width = 0;
    }
    [self modifyWidth:width];
}

-(void)modifyHeight:(CGFloat)height
{
    if (height <= 0) {
        height = 0;
    }
    [UIView modifyViewHeigth:height view:self];
}

-(void)modifyOrigi:(CGPoint)point
{
    [UIView modifyViewOrigin:point view:self];
}

-(void)modifyX:(CGFloat)x
{
    CGPoint point = self.frame.origin;
    point.x = x;
    [UIView modifyViewOrigin:point view:self];
}

-(void)modifyY:(CGFloat)y
{
    CGPoint point = self.frame.origin;
    point.y = y;
    [UIView modifyViewOrigin:point view:self];
}

-(void)modifyCenterX:(CGFloat)x
{
    self.frame = CGRectMake(x - (self.frame.size.width/2.0f), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    
}

-(void)modifyCenterY:(CGFloat)y
{
    self.frame = CGRectMake(self.frame.origin.x, y - (self.frame.size.height/2.0f), self.frame.size.width, self.frame.size.height);
}

-(void)removeAllSubviews
{
    
//    for (UIView* view in [self subviews]) {
//        [view removeFromSuperview];
//    }
    [[self subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
}


//矩形
-(void)drawRectangle:(CGRect)rect
{
    CGContextRef     context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef pathRef = [self pathwithFrame:rect withRadius:0];
    
    CGContextAddPath(context, pathRef);
    CGContextDrawPath(context,kCGPathFillStroke);
    
    CGPathRelease(pathRef);
}
//圆角矩形
-(void)drawRectangle:(CGRect)rect withRadius:(float)radius
{
    CGContextRef     context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef pathRef = [self pathwithFrame:rect withRadius:radius];
    
    CGContextAddPath(context, pathRef);
    CGContextDrawPath(context,kCGPathFillStroke);
    
    CGPathRelease(pathRef);
}
//多边形
-(void)drawPolygon:(NSArray *)pointArray
{
    NSAssert(pointArray.count>=2,@"数组长度必须大于等于2");
    NSAssert([[pointArray[0] class] isSubclassOfClass:[NSValue class]], @"数组成员必须是CGPoint组成的NSValue");
    
    CGContextRef     context = UIGraphicsGetCurrentContext();
    
    NSValue *startPointValue = pointArray[0];
    CGPoint  startPoint      = [startPointValue CGPointValue];
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    
    for(int i = 1;i<pointArray.count;i++)
    {
        NSAssert([[pointArray[i] class] isSubclassOfClass:[NSValue class]], @"数组成员必须是CGPoint组成的NSValue");
        NSValue *pointValue = pointArray[i];
        CGPoint  point      = [pointValue CGPointValue];
        CGContextAddLineToPoint(context, point.x,point.y);
    }
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

#define HFH_PI  3.1415926

//圆形
-(void)drawCircleWithCenter:(CGPoint)center
                     radius:(float)radius
{
    CGContextRef     context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGPathAddArc(pathRef,
                 &CGAffineTransformIdentity,
                 center.x,
                 center.y,
                 radius,
                 -HFH_PI/2,
                 radius*2*HFH_PI-HFH_PI/2,
                 NO);
    CGPathCloseSubpath(pathRef);
    
    CGContextAddPath(context, pathRef);
    CGContextDrawPath(context,kCGPathFillStroke);
    
    CGPathRelease(pathRef);
    
}
//曲线
-(void)drawCurveFrom:(CGPoint)startPoint
                  to:(CGPoint)endPoint
       controlPoint1:(CGPoint)controlPoint1
       controlPoint2:(CGPoint)controlPoint2
{
    CGContextRef     context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddCurveToPoint(context,
                             controlPoint1.x,
                             controlPoint1.y,
                             controlPoint2.x,
                             controlPoint2.y,
                             endPoint.x,
                             endPoint.y);
    
    CGContextDrawPath(context,kCGPathStroke);
}
//弧线
-(void)drawArcFromCenter:(CGPoint)center
                  radius:(float)radius
              startAngle:(float)startAngle
                endAngle:(float)endAngle
               clockwise:(BOOL)clockwise
{
    CGContextRef     context = UIGraphicsGetCurrentContext();
    
    CGContextAddArc(context,
                    center.x,
                    center.y,
                    radius,
                    startAngle,
                    endAngle,
                    clockwise?0:1);
    
    CGContextStrokePath(context);
}

//扇形
-(void)drawSectorFromCenter:(CGPoint)center
                     radius:(float)radius
                 startAngle:(float)startAngle
                   endAngle:(float)endAngle
                  clockwise:(BOOL)clockwise
{
    CGContextRef     context = UIGraphicsGetCurrentContext();
    
    
    CGContextMoveToPoint(context, center.x, center.y);
    
    CGContextAddArc(context,
                    center.x,
                    center.y,
                    radius,
                    startAngle,
                    endAngle,
                    clockwise?0:1);
    CGContextClosePath(context);
    CGContextDrawPath(context,kCGPathFillStroke);
}


//直线
-(void)drawLineFrom:(CGPoint)startPoint
                 to:(CGPoint)endPoint
{
    CGContextRef     context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x,endPoint.y);
    
    CGContextStrokePath(context);
}
-(void)drawLines:(NSArray *)pointArray
{
    NSAssert(pointArray.count>=2,@"数组长度必须大于等于2");
    NSAssert([[pointArray[0] class] isSubclassOfClass:[NSValue class]], @"数组成员必须是CGPoint组成的NSValue");
    
    CGContextRef     context = UIGraphicsGetCurrentContext();
    
    NSValue *startPointValue = pointArray[0];
    CGPoint  startPoint      = [startPointValue CGPointValue];
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    
    for(int i = 1;i<pointArray.count;i++)
    {
        NSAssert([[pointArray[i] class] isSubclassOfClass:[NSValue class]], @"数组成员必须是CGPoint组成的NSValue");
        NSValue *pointValue = pointArray[i];
        CGPoint  point      = [pointValue CGPointValue];
        CGContextAddLineToPoint(context, point.x,point.y);
    }
    
    CGContextStrokePath(context);
}

-(CGMutablePathRef)pathwithFrame:(CGRect)frame withRadius:(float)radius
{
    CGPoint x1,x2,x3,x4; //x为4个顶点
    CGPoint y1,y2,y3,y4,y5,y6,y7,y8; //y为4个控制点
    //从左上角顶点开始，顺时针旋转,x1->y1->y2->x2
    
    x1 = frame.origin;
    x2 = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y);
    x3 = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height);
    x4 = CGPointMake(frame.origin.x                 , frame.origin.y+frame.size.height);
    
    
    y1 = CGPointMake(frame.origin.x+radius, frame.origin.y);
    y2 = CGPointMake(frame.origin.x+frame.size.width-radius, frame.origin.y);
    y3 = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+radius);
    y4 = CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height-radius);
    
    y5 = CGPointMake(frame.origin.x+frame.size.width-radius, frame.origin.y+frame.size.height);
    y6 = CGPointMake(frame.origin.x+radius, frame.origin.y+frame.size.height);
    y7 = CGPointMake(frame.origin.x, frame.origin.y+frame.size.height-radius);
    y8 = CGPointMake(frame.origin.x, frame.origin.y+radius);
    
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    if (radius<=0) {
        CGPathMoveToPoint(pathRef,    &CGAffineTransformIdentity, x1.x,x1.y);
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, x2.x,x2.y);
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, x3.x,x3.y);
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, x4.x,x4.y);
    }else
    {
        CGPathMoveToPoint(pathRef,    &CGAffineTransformIdentity, y1.x,y1.y);
        
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, y2.x,y2.y);
        CGPathAddArcToPoint(pathRef, &CGAffineTransformIdentity,  x2.x,x2.y,y3.x,y3.y,radius);
        
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, y4.x,y4.y);
        CGPathAddArcToPoint(pathRef, &CGAffineTransformIdentity,  x3.x,x3.y,y5.x,y5.y,radius);
        
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, y6.x,y6.y);
        CGPathAddArcToPoint(pathRef, &CGAffineTransformIdentity,  x4.x,x4.y,y7.x,y7.y,radius);
        
        CGPathAddLineToPoint(pathRef, &CGAffineTransformIdentity, y8.x,y8.y);
        CGPathAddArcToPoint(pathRef, &CGAffineTransformIdentity,  x1.x,x1.y,y1.x,y1.y,radius);
        
    }
    
    
    CGPathCloseSubpath(pathRef);
    
    //[[UIColor whiteColor] setFill];
    //[[UIColor blackColor] setStroke];
    
    return pathRef;
}

@end
