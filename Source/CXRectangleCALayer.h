//
//  CXRectangleCALayer.h
//  DocBox
//
//  Created by Dan Bucholtz on 8/26/14.
//  Copyright (c) 2014 Mod618. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class CXRectangle;

@interface CXRectangleCALayer : CALayer

-(void)updateDetect:(CXRectangle *)rectangle;

-(CXRectangle *)getCurrentRectangle;

@end
