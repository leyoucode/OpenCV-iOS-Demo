//
//  UIImage+UIImage_Rotate.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 20/01/2017.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_Rotate)

- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

/*水平翻转*/
- (UIImage *)flipHorizontal;

@end
