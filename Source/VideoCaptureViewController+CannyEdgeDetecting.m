////
////  VideoCaptureViewController+CannyEdgeDetecting.m
////  OpenCV-iOS-demo
////
////  Created by 刘伟 on 2/16/17.
////  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
////
//
//#import "VideoCaptureViewController+CannyEdgeDetecting.h"
//
//@implementation VideoCaptureViewController (CannyEdgeDetecting)
//
//- (void)captureImageWithCompletionHander:(void(^)(NSString *imageFilePath))completionHandler
//{
//    
//    //dispatch_suspend(_captureQueue);
//    
//    AVCaptureConnection *videoConnection = nil;
//    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
//    {
//        for (AVCaptureInputPort *port in [connection inputPorts])
//        {
//            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
//            {
//                videoConnection = connection;
//                break;
//            }
//        }
//        if (videoConnection) break;
//    }
//    
//    __weak typeof(self) weakSelf = self;
//    
//    Rectangle* rectangle = [rectangleCALayer getCurrentRectangle];
//    
//    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
//     {
//         
//         if (error)
//         {
//             //dispatch_resume(_captureQueue);
//             return;
//         }
//         
//         __block NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"ipdf_img_%i.jpeg",(int)[NSDate date].timeIntervalSince1970]];
//         
//         @autoreleasepool
//         {
//             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
//             UIImage* image = [[UIImage alloc] initWithData:imageData];
//             
//             image = [image fixOrientation:image];
//             
//             Rectangle *newRectangle = [self rotationRectangle:rectangle];
//             
//             image = [weakSelf correctPerspectiveForImage:image withFeatures:newRectangle];
//             
//             //image = [weakSelf confirmedImage:image withFeatures:rectangle];
//             
//             NSData *jpgData = UIImageJPEGRepresentation(image, 1.0f);
//             [jpgData writeToFile:filePath atomically:NO];
//             
//             NSLog(@"=== OK");
//             
//             dispatch_async(dispatch_get_main_queue(), ^
//                            {
//                                completionHandler(filePath);
//                            });
//         }
//     }];
//}
//
//- (UIImage *)confirmedImage:(UIImage*)sourceImage withFeatures:(Rectangle *)rectangle
//{
//    
//    CGSize imageSize = sourceImage.size;
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    
//    float a = imageSize.width / screenSize.width;
//    float b = imageSize.height / screenSize.height;
//    //float c = MAX(a, b);
//    
//    cv::Mat img = [sourceImage CVMat];
//    
//    std::vector<cv::Point2f> corners(4);
//    corners[0] = cv::Point2f(rectangle.topLeftX * a, rectangle.topLeftY * b );
//    corners[1] = cv::Point2f(rectangle.topRightX * a, rectangle.topRightY * b );
//    corners[2] = cv::Point2f(rectangle.bottomLeftX * a, rectangle.bottomLeftY * b );
//    corners[3] = cv::Point2f(rectangle.bottomRightX * a, rectangle.bottomRightY * b );
//    
//    float leftX = MIN(rectangle.topLeftX, rectangle.bottomLeftX);
//    float topY = MIN(rectangle.topLeftY, rectangle.topRightY);
//    float rightX = MAX(rectangle.topRightX, rectangle.bottomRightX);
//    float bottomY = MAX(rectangle.bottomLeftY, rectangle.bottomRightY);
//    
//    std::vector<cv::Point2f> corners_trans(4);
//    corners_trans[0] = cv::Point2f(leftX,topY);
//    corners_trans[1] = cv::Point2f(rightX,topY);
//    corners_trans[2] = cv::Point2f(leftX,bottomY);
//    corners_trans[3] = cv::Point2f(rightX,bottomY);
//    
//    //    // Assemble a rotated rectangle out of that info
//    //    cv::RotatedRect box = minAreaRect(cv::Mat(corners));
//    //    std::cout << "Rotated box set to (" << box.boundingRect().x << "," << box.boundingRect().y << ") " << box.size.width << "x" << box.size.height << std::endl;
//    //
//    ////    cv::Point2f pts[4];
//    ////    box.points(pts);
//    //
//    //    corners_trans[0] = cv::Point(0, 0);
//    //    corners_trans[1] = cv::Point(box.boundingRect().width - 1, 0);
//    //    corners_trans[2] = cv::Point(0, box.boundingRect().height - 1);
//    //    corners_trans[3] = cv::Point(box.boundingRect().width - 1, box.boundingRect().height - 1);
//    
//    //自由变换 透视变换矩阵3*3
//    cv::Mat warp_matrix( 3, 3, CV_32FC1 );
//    // 求解变换公式的函数
//    cv::Mat warpMatrix = getPerspectiveTransform(corners, corners_trans);
//    //cv::Mat rotated;
//    
//    //cv::RotatedRect box = minAreaRect(cv::Mat(corners_trans));
//    cv::Mat outt;
//    cv::Size size(std::abs(rightX - leftX), std::abs(bottomY - topY));
//    warpPerspective(img, outt, warpMatrix,size, 1, 0, 0);
//    
//    //cv::warpPerspective(img, quad, warpMatrix, quad.size());
//    //warpPerspective(img, rotated, warpMatrix, rotated.size(), cv::INTER_LINEAR, cv::BORDER_CONSTANT);
//    
//    return [UIImage imageWithCVMat:outt];
//    
//    /*
//     
//     // 这里顺利打印出了四个点
//     cv::Mat draw = img.clone();
//     
//     // draw the polygon
//     cv::circle(draw,corners[0],5,cv::Scalar(0,0,255),2.5);
//     cv::circle(draw,corners[1],5,cv::Scalar(0,0,255),2.5);
//     cv::circle(draw,corners[2],5,cv::Scalar(0,0,255),2.5);
//     cv::circle(draw,corners[3],5,cv::Scalar(0,0,255),2.5);
//     
//     return [UIImage imageWithCVMat:draw];
//     */
//    
//}
//
//cv::Point2f RotatePoint(const cv::Point2f& p, float rad)
//{
//    const float x = std::cos(rad) * p.x - std::sin(rad) * p.y;
//    const float y = std::sin(rad) * p.x + std::cos(rad) * p.y;
//    
//    const cv::Point2f rot_p(x, y);
//    return rot_p;
//}
//
//cv::Point2f RotatePoint(const cv::Point2f& cen_pt, const cv::Point2f& p, float rad)
//{
//    const cv::Point2f trans_pt = p - cen_pt;
//    const cv::Point2f rot_pt   = RotatePoint(trans_pt, rad);
//    const cv::Point2f fin_pt   = rot_pt + cen_pt;
//    
//    return fin_pt;
//}
//
//CGFloat flipHorizontalPointX(float pointX, CGFloat screenWidth) {
//    return screenWidth - pointX;
//}
//
//-(Rectangle *)rotationRectangle:(Rectangle *)rectangle
//{
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    CGFloat screenWidth = screenSize.width;
//    CGFloat screenHeight = screenSize.height;
//    
//    cv::Point2f center = cv::Point2f((screenWidth / 2), (screenHeight / 2));
//    
//    cv::Point2f topLeft = RotatePoint(center, cv::Point2f(rectangle.topLeftX, rectangle.topLeftY), M_PI);
//    cv::Point2f topRight = RotatePoint(center, cv::Point2f(rectangle.topRightX, rectangle.topRightY), M_PI);
//    cv::Point2f bottomLeft = RotatePoint(center, cv::Point2f(rectangle.bottomLeftX, rectangle.bottomLeftY), M_PI);
//    cv::Point2f bottomRight = RotatePoint(center, cv::Point2f(rectangle.bottomRightX, rectangle.bottomRightY), M_PI);
//    
//    Rectangle *newRectangle = [[Rectangle alloc] init];
//    newRectangle.topLeftX = flipHorizontalPointX(topLeft.x, screenWidth);
//    newRectangle.topLeftY = topLeft.y;
//    newRectangle.topRightX = flipHorizontalPointX(topRight.x, screenWidth);
//    newRectangle.topRightY = topRight.y;
//    newRectangle.bottomLeftX = flipHorizontalPointX(bottomLeft.x, screenWidth);
//    newRectangle.bottomLeftY = bottomLeft.y;
//    newRectangle.bottomRightX = flipHorizontalPointX(bottomRight.x, screenWidth);
//    newRectangle.bottomRightY = bottomRight.y;
//    return newRectangle;
//}
//
//- (UIImage *)correctPerspectiveForImage:(UIImage *)image withFeatures:(Rectangle *)rectangle
//{
//    // 定义左上角，右上角，左下角，右下角
//    CGPoint tlp, trp, blp, brp;
//    
//    CGSize imageSize = image.size;
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    float screenRatio = screenSize.width / screenSize.height;
//    imageSize.height = imageSize.width / screenRatio;
//    
//    float a = imageSize.width / screenSize.width;
//    float b = imageSize.height / screenSize.height;
//    //float c = MAX(a, b);
//    
//    tlp = CGPointMake(rectangle.topLeftX * a, rectangle.topLeftY * b);
//    trp = CGPointMake(rectangle.topRightX * a, rectangle.topRightY * b);
//    blp = CGPointMake(rectangle.bottomLeftX * a, rectangle.bottomLeftY * b);
//    brp = CGPointMake(rectangle.bottomRightX * a, rectangle.bottomRightY * b);
//    
//    NSLog(@"LT:%@ RT:%@ LB:%@ RB:%@", NSStringFromCGPoint(tlp),NSStringFromCGPoint(trp),NSStringFromCGPoint(blp),NSStringFromCGPoint(brp));
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(NULL, image.size.width, image.size.height, 8, 4 * image.size.width, colorSpace, kCGImageAlphaPremultipliedLast);
//    
//    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
//    
//    [[UIColor blackColor] setFill];
//    CGContextFillRect(context, rect);
//    
//    CGColorRef fillColor = [[UIColor whiteColor] CGColor];
//    CGContextSetFillColor(context, CGColorGetComponents(fillColor));
//    
//    CGContextMoveToPoint(context, tlp.x, tlp.y);
//    CGContextAddLineToPoint(context, trp.x, trp.y);
//    CGContextAddLineToPoint(context, brp.x, brp.y);
//    CGContextAddLineToPoint(context, blp.x, blp.y);
//    
//    CGContextClosePath(context);
//    CGContextClip(context);
//    
//    CGContextDrawImage(context, rect, image.CGImage);
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    UIImage *newImage = [UIImage imageWithCGImage:imageMasked];
//    CGImageRelease(imageMasked);
//    
//    /* TODO 这里需要优化 需要抠出需要的图片
//     调研一下 OpenCV提取轮廓
//     float leftX = MIN(rectangle.topLeftX * a, rectangle.bottomLeftX * b);
//     float topY = MIN(rectangle.topLeftY * a, rectangle.topRightY * b);
//     float rightX = MAX(rectangle.topRightX * a, rectangle.bottomRightX * b);
//     float bottomY = MAX(rectangle.bottomLeftY * a, rectangle.bottomRightY * b);
//     
//     CGImageRef imagRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(leftX, topY, (rightX - leftX), (bottomY - topY)));
//     UIImage* finalImage = [UIImage imageWithCGImage: imagRef];
//     CGImageRelease(imagRef);
//     */
//    
//    return newImage;
//}
//
//@end
