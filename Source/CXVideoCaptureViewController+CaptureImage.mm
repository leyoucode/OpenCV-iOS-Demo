//
//  CXVideoCaptureViewController+CaptureImage.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXVideoCaptureViewController+CaptureImage.h"
#import "ImageUtils.h"
#import "CXMarcos.h"

@implementation CXVideoCaptureViewController (CaptureImage)

- (void)captureImageWithCompletionHander:(void(^)(NSString *imageFilePath))completionHandler
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) break;
    }
    
    //__weak typeof(self) weakSelf = self;
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         if (error)
         {
             //dispatch_resume(_captureQueue);
             return;
         }
         
         __block NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"CX_IMAGE_%i.jpeg",(int)[NSDate date].timeIntervalSince1970]];
         
         @autoreleasepool
         {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             
             UIImage * image = [UIImage imageWithData:imageData];
             
             image = [ImageUtils fixOrientation:image];
             
             image = [self cropImage:image];
             
             imageData = UIImageJPEGRepresentation(image, 1.0);
             
             [imageData writeToFile:filePath atomically:NO];
             
             NSLog(@"=== OK");
             
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                completionHandler(filePath);
                            });
         }
     }];
}

#pragma mark - Private
- (UIImage *)cropImage:(UIImage*)originImage
{
    float topRate = (50.0 / SCREEN_HEIGHT);
    float heightRate = (SCREEN_HEIGHT - 50.0 - 120.0) / SCREEN_HEIGHT;
    
    CGRect rect = CGRectMake(0, originImage.size.height * topRate, originImage.size.width, originImage.size.height * heightRate);
    
    if (originImage.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * originImage.scale,
                          rect.origin.y * originImage.scale,
                          rect.size.width * originImage.scale,
                          rect.size.height * originImage.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(originImage.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:originImage.scale orientation:originImage.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

@end
