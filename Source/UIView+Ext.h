//
//  UIView+Ext.h
//  HFHFinance
//
//  Created by 刘伟 on 15/11/9.
//  Copyright © 2015年 慧富汇. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define VIEW_BOTTEM(V)     V.getViewBottem
#define VIEW_LEFT(V)     V.getViewLeft
#define VIEW_RIGHT(V)    V.getViewRight
#define VIEW_TOP(V)     V.getViewTop

#define VIEW_WIDTH(V)  V.frame.size.width
#define VIEW_HEIGHT(V) V.frame.size.height

@interface UIView(Ext)

-(CGFloat)getViewLeft;

-(CGFloat)getViewTop;

-(CGFloat)getViewRight;

-(CGFloat)getViewBottem;


-(void)fitToHorizontalCenterWithView:(UIView*)view;
-(void)fitToVerticalCenterWithView:(UIView*)view;
-(void)makeTopRightFrameWithPoint:(CGPoint)point width:(CGFloat)width height:(CGFloat)height;
-(void)modifyWidthToLeft:(CGFloat)width;
-(void)modifyWidthToRight:(CGFloat)width;
-(void)modifyWidth:(CGFloat)width;
-(void)modifyHeight:(CGFloat)height;
-(void)modifySize:(CGSize)size;
-(void)modifyOrigi:(CGPoint)point;
-(void)modifyX:(CGFloat)x;
-(void)modifyY:(CGFloat)y;
-(void)modifyRight:(CGFloat)right;
-(void)modifyBottem:(CGFloat)bottem;
-(void)modifyCenterX:(CGFloat)x;
-(void)modifyCenterY:(CGFloat)y;
-(void)setTheSameBottemWithView:(UIView*)view;

-(void)removeAllSubviews;

//矩形
-(void)drawRectangle:(CGRect)rect;
//圆角矩形
-(void)drawRectangle:(CGRect)rect withRadius:(float)radius;
//画多边形
//pointArray = @[[NSValue valueWithCGPoint:CGPointMake(200, 400)]];
-(void)drawPolygon:(NSArray *)pointArray;
//圆形
-(void)drawCircleWithCenter:(CGPoint)center
                     radius:(float)radius;
//曲线
-(void)drawCurveFrom:(CGPoint)startPoint
                  to:(CGPoint)endPoint
       controlPoint1:(CGPoint)controlPoint1
       controlPoint2:(CGPoint)controlPoint2;

//弧线
-(void)drawArcFromCenter:(CGPoint)center
                  radius:(float)radius
              startAngle:(float)startAngle
                endAngle:(float)endAngle
               clockwise:(BOOL)clockwise;
//扇形
-(void)drawSectorFromCenter:(CGPoint)center
                     radius:(float)radius
                 startAngle:(float)startAngle
                   endAngle:(float)endAngle
                  clockwise:(BOOL)clockwise;

//直线
-(void)drawLineFrom:(CGPoint)startPoint
                 to:(CGPoint)endPoint;

/*
 折线，连续直线
 pointArray = @[[NSValue valueWithCGPoint:CGPointMake(200, 400)]];
 */
-(void)drawLines:(NSArray *)pointArray;



-(CGMutablePathRef)pathwithFrame:(CGRect)frame withRadius:(float)radius;
@end
