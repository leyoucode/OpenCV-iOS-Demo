//
//  CXRectangle.m
//  DocBox
//
//  Created by Dan Bucholtz on 4/19/14.
//  Copyright (c) 2014 Mod618. All rights reserved.
//

#import "CXRectangle.h"

@implementation CXRectangle

@synthesize topLeftX;
@synthesize topRightX;
@synthesize bottomLeftX;
@synthesize bottomRightX;

@synthesize topLeftY;
@synthesize topRightY;
@synthesize bottomLeftY;
@synthesize bottomRightY;

-(NSString *)description
{
    return [NSString stringWithFormat:@"(%d,%d),(%d,%d),(%d,%d),(%d,%d)",
            topLeftX, topLeftY,
            topRightX, topRightY,
            bottomLeftX, bottomLeftY,
            bottomRightX, bottomRightY];
}

@end
