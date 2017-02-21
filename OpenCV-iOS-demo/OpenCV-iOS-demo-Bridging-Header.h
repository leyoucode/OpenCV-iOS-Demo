//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

// reference to: http://docs.opencv.org/2.4/doc/tutorials/ios/video_processing/video_processing.html#opencviosvideoprocessing

#import <Availability.h>

#ifndef __IPHONE_4_0
#warning "This project uses features only available in iOS SDK 4.0 and later."
#endif

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif

#import "OpenCVWrapper.h"
//#import "CannyEdgeDetectingViewController.h"

