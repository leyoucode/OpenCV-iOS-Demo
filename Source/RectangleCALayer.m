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
}

//@property (nonatomic, strong) Rectangle * rectangle;

@end

@implementation RectangleCALayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.borderWidth = 2;
        self.borderColor = [UIColor redColor].CGColor;
        self.delegate = self;
    }
    return self;
}

-(void)updateDetect:(Rectangle *)rectangle
{
    _newRectangle = rectangle;
    [self setNeedsDisplay];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    
    NSLog(@"aggregateRectangle => %@",_newRectangle);
    
    if ( _newRectangle ){
        
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
        CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:1 alpha:0.25] CGColor]);
        
        CGContextMoveToPoint(context, _newRectangle.topLeftX, _newRectangle.topLeftY);
        
        CGContextAddLineToPoint(context, _newRectangle.topRightX, _newRectangle.topRightY);
        
        CGContextAddLineToPoint(context, _newRectangle.bottomRightX, _newRectangle.bottomRightY);
        
        CGContextAddLineToPoint(context, _newRectangle.bottomLeftX, _newRectangle.bottomLeftY);
        
        CGContextAddLineToPoint(context, _newRectangle.topLeftX, _newRectangle.topLeftY);
        
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}



@end
