//
//  CXVideoCaptureViewController+CaptureImage.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXVideoCaptureViewController.h"

@interface CXVideoCaptureViewController (CaptureImage)

- (void)captureImageWithCompletionHander:(void(^)(NSString *imageFilePath))completionHandler;

@end
