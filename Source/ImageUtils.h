//
//  ImageUtils.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/highgui/highgui.hpp>

@interface ImageUtils : NSObject

+(cv::Mat)getCVMatFrom:(UIImage*)image;

#pragma mark - OpenCV

+(UIImage*)getImageWithCVMat:(const cv::Mat&)cvMat;

/*
 @property(nonatomic, readonly) cv::Mat CVGrayscaleMat;
 */

#pragma mark - Extension

+(UIImage *)fixOrientation:(UIImage *)aImage;

+(UIImage*) createImageWithColor: (UIColor*) color;


@end
