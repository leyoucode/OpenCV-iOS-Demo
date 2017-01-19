//
//  EdgeDetectingViewController.h
//  OpenCVCameraSample
//
//  Created by Dan Bucholtz on 9/7/14.
//  Copyright (c) 2014 NXSW. All rights reserved.
//

#import "VideoCaptureViewController.h"

@interface EdgeDetectingViewController : VideoCaptureViewController<CALayerDelegate>

- (void)captureImageWithCompletionHander:(void(^)(NSString *imageFilePath))completionHandler;

@end
