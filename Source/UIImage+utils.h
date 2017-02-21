//
//  UIImage+OpenCV.h
//  OpenCVClient
//
//  Created by Robin Summerhill on 02/09/2011.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

@interface UIImage (utils)

@property(nonatomic, readonly) cv::Mat CVMat;

#pragma mark - OpenCV

-(id)initWithCVMat:(const cv::Mat&)cvMat;

+(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;



/*
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;
*/

#pragma mark - Extension

- (UIImage *)fixOrientation:(UIImage *)aImage;

+(UIImage*) createImageWithColor: (UIColor*) color;

@end
