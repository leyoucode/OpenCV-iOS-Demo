//
//  RectangleCALayer.m
//  DocBox
//
//  Created by Dan Bucholtz on 8/26/14.
//  Copyright (c) 2014 Mod618. All rights reserved.
//

#import "RectangleCALayer.h"
#import "UIKit/UIKit.h"

@implementation RectangleCALayer

@synthesize rectangle;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.borderWidth = 2;
        self.borderColor = [UIColor greenColor].CGColor;
        
    }
    return self;
}
@end
