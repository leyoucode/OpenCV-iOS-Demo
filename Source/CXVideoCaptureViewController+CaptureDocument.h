//
//  CXVideoCaptureViewController+CaptureDocument.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXVideoCaptureViewController.h"

@interface CXVideoCaptureViewController (CaptureDocument)

- (void)captureDocumentWithCompletionHander:(void(^)(NSString *imageFilePath))completionHandler;

- (void) processDocumentBuffer:(CMSampleBufferRef)sampleBuffer;

@end
