//
//  EdgeDetectingViewController.m
//  OpenCVCameraSample
//
//  Created by Dan Bucholtz on 9/7/14.
//  Copyright (c) 2014 NXSW. All rights reserved.
//

#import "EdgeDetectingViewController.h"

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>


#import "Rectangle.h"
#import "RectangleCALayer.h"
#import "UIImage+OpenCV.h"
#import <opencv2/imgcodecs/ios.h>
#import "UIImage+UIImage_Rotate.h"


@implementation EdgeDetectingViewController

long frameNumber = 0;
NSMutableArray * queue;

NSObject * frameNumberLockObject = [[NSObject alloc] init];
NSObject * queueLockObject = [[NSObject alloc] init];
NSObject * aggregateRectangleLockObject = [[NSObject alloc] init];

Rectangle * aggregateRectangle;
cv::Mat currentMat;

RectangleCALayer *rectangleCALayer = [[RectangleCALayer alloc] init];

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_videoPreviewLayer addSublayer:rectangleCALayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    frameNumber = 0;
    aggregateRectangle = nil;
    queue = [[NSMutableArray alloc] initWithCapacity:5];
}

- (void)processFrame:(cv::Mat&)mat videoRect:(CGRect)rect videoOrientation:(AVCaptureVideoOrientation)orientation{
    
    currentMat = mat;
    
    @synchronized(frameNumberLockObject){
        frameNumber++;
    }
    
    
    // Shrink video frame to 320X240
    cv::resize(mat, mat, cv::Size(), 0.25f, 0.25f, CV_INTER_LINEAR);
    rect.size.width /= 4.0f;
    rect.size.height /= 4.0f;

//    float ratioW = 240.0 / rect.size.width;
//    //float ratioH= 320.0 / rect.size.height;
//    cv::resize(mat, mat, cv::Size(), ratioW, ratioW, CV_INTER_LINEAR);
//    rect.size.width *= ratioW;
//    rect.size.height *= ratioW;
    
    // Rotate video frame by 90deg to portrait by combining a transpose and a flip
    // Note that AVCaptureVideoDataOutput connection does NOT support hardware-accelerated
    // rotation and mirroring via videoOrientation and setVideoMirrored properties so we
    // need to do the rotation in software here.
    cv::transpose(mat, mat);
    CGFloat temp = rect.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = temp;
    
    if (orientation == AVCaptureVideoOrientationLandscapeRight)
    {
        // flip around y axis for back camera
        cv::flip(mat, mat, 1);
    }
    else {
        // Front camera output needs to be mirrored to match preview layer so no flip is required here
    }
    
    orientation = AVCaptureVideoOrientationPortrait;
    
    long start = [[NSDate date] timeIntervalSince1970 ] * 1000;
    
    Rectangle * rectangle = [self getLargestRectangleInFrame:mat];
    
    [self processRectangleFromFrame:rectangle inFrame:frameNumber];
    
    long end = [[NSDate date] timeIntervalSince1970 ] * 1000;
    
    long difference = end - start;
    
    //NSLog(@"%@", [NSString stringWithFormat:@"Millis to calculate: %ld", difference]);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self displayDataForVideoRect:rect videoOrientation:orientation];
    });
}

- (void) displayDataForVideoRect:(CGRect)rect videoOrientation:(AVCaptureVideoOrientation)videoOrientation
{
    
    @synchronized (self) {
        
//        NSArray *sublayers = [NSArray arrayWithArray:[_videoPreviewLayer sublayers]];
//        int sublayersCount = (int) [sublayers count];
//        int currentSublayer = 0;
//        
//        [CATransaction begin];
//        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//        [CATransaction setAnimationDuration:0.4];
////        // hide all the drawing layers
//        for (CALayer *layer in sublayers) {
//            NSString *layerName = [layer name];
//            if ([layerName isEqualToString:@"DrawingLayer"])
//                [layer setHidden:YES];
//        }
        
        CGAffineTransform t = [self affineTransformForVideoFrame:rect orientation:videoOrientation];
        
        if ( aggregateRectangle ){
            
            CGPoint transformedTopLeft = CGPointApplyAffineTransform(CGPointMake(aggregateRectangle.topLeftX, aggregateRectangle.topLeftY), t);
            CGPoint transformedTopRight = CGPointApplyAffineTransform(CGPointMake(aggregateRectangle.topRightX, aggregateRectangle.topRightY), t);
            CGPoint transformedBottomLeft = CGPointApplyAffineTransform(CGPointMake(aggregateRectangle.bottomLeftX, aggregateRectangle.bottomLeftY), t);
            CGPoint transformedBottomRight = CGPointApplyAffineTransform(CGPointMake(aggregateRectangle.bottomRightX, aggregateRectangle.bottomRightY), t);
            
            aggregateRectangle.topLeftX = transformedTopLeft.x;
            aggregateRectangle.topRightX = transformedTopRight.x;
            aggregateRectangle.bottomLeftX = transformedBottomLeft.x;
            aggregateRectangle.bottomRightX = transformedBottomRight.x;
            
            aggregateRectangle.topLeftY = transformedTopLeft.y;
            aggregateRectangle.topRightY = transformedTopRight.y;
            aggregateRectangle.bottomLeftY = transformedBottomLeft.y;
            aggregateRectangle.bottomRightY = transformedBottomRight.y;
        }
        
        
//        CALayer *featureLayer = nil;
//        
//        // re-use an existing layer if possible
//        while ( !featureLayer && (currentSublayer < sublayersCount) ) {
//            CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
//            if ( [[currentLayer name] isEqualToString:@"DrawingLayer"] ) {
//                featureLayer = currentLayer;
//                [currentLayer setHidden:NO];
//            }
//        }
//        
//        // create a new one if necessary
//        if ( !featureLayer ) {
//            featureLayer = [CALayer new];
//            featureLayer.delegate = self;
//            [featureLayer setName:@"DrawingLayer"];
//            [_videoPreviewLayer addSublayer:featureLayer];
//        }
//        
//        [featureLayer setFrame:_videoPreviewLayer.frame];
//        [featureLayer setNeedsDisplay];
        
//
        //NSLog(@"aggregateRectangle => %@",aggregateRectangle);
        
//        if (aggregateRectangle)
//        {
            [rectangleCALayer setFrame:_videoPreviewLayer.frame];
            [rectangleCALayer updateDetect:aggregateRectangle];
//        }
        
        
//        [CATransaction commit];
    }
}

- (void) processRectangleFromFrame:(Rectangle *)rectangle inFrame:(long)frame{
    if ( !rectangle ){
        // the rectangle is null, so remove the oldest frame from the queue
        [self removeOldestFrameFromRectangleQueue];
        [self updateAggregateRectangle:rectangle];
    }
    else{
        BOOL significantChange = [self checkForSignificantChange:rectangle withAggregate:aggregateRectangle];
        if ( significantChange ){
            // empty the queue, and make the new rectangle the aggregated rectangle for now
            [self emptyQueue];
            [self updateAggregateRectangle:rectangle];
        }
        else{
            // remove the oldest frame
            [self removeOldestFrameFromRectangleQueue];
            // then add the new frame, and average the 5 to build an aggregate rectangle
            [self addRectangleToQueue:rectangle];
            Rectangle * aggregate = [self buildAggregateRectangleFromQueue];
            [self updateAggregateRectangle:aggregate];
        }
    }
}

- (Rectangle *) buildAggregateRectangleFromQueue{
    @synchronized(queueLockObject){
        double topLeftX = 0;
        double topLeftY = 0;
        double topRightX = 0;
        double topRightY = 0;
        double bottomLeftX = 0;
        double bottomLeftY = 0;
        double bottomRightX = 0;
        double bottomRightY = 0;
        
        if ( !queue ){
            return nil;
        }
        
        for ( int i = 0; i < [queue count]; i++ ){
            Rectangle * temp = [queue objectAtIndex:i];
            topLeftX = topLeftX + temp.topLeftX;
            topLeftY = topLeftY + temp.topLeftY;
            topRightX = topRightX + temp.topRightX;
            topRightY = topRightY + temp.topRightY;
            bottomLeftX = bottomLeftX + temp.bottomLeftX;
            bottomLeftY = bottomLeftY + temp.bottomLeftY;
            bottomRightX = bottomRightX + temp.bottomRightX;
            bottomRightY = bottomRightY + temp.bottomRightY;
        }
        
        Rectangle * aggregate = [[Rectangle alloc] init];
        aggregate.topLeftX = round(topLeftX/[queue count]);
        aggregate.topLeftY = round(topLeftY/[queue count]);
        aggregate.topRightX = round(topRightX/[queue count]);
        aggregate.topRightY = round(topRightY/[queue count]);
        aggregate.bottomLeftX = round(bottomLeftX/[queue count]);
        aggregate.bottomLeftY = round(bottomLeftY/[queue count]);
        aggregate.bottomRightX = round(bottomRightX/[queue count]);
        aggregate.bottomRightY = round(bottomRightY/[queue count]);
        
        return aggregate;
    }
}

- (void) updateAggregateRectangle:(Rectangle *)rectangle{
    @synchronized(aggregateRectangleLockObject){
        aggregateRectangle = rectangle;
    }
}

- (void) emptyQueue{
    @synchronized(queueLockObject){
        if ( queue ){
            [queue removeAllObjects];
        }
    }
}

- (BOOL) checkForSignificantChange:(Rectangle *)rectangle withAggregate:(Rectangle *)aggregate {
    @synchronized(aggregateRectangleLockObject){
        if ( !aggregate ){
            return YES;
        }
        else{
            // compare each point
            int maxDiff = 12;
            
            int topLeftXDiff = abs(rectangle.topLeftX - aggregate.topLeftX);
            int topLeftYDiff = abs(rectangle.topLeftY - aggregate.topLeftY);
            int topRightXDiff = abs(rectangle.topRightX - aggregate.topRightX);
            int topRightYDiff = abs(rectangle.topRightY - aggregate.topRightY);
            
            int bottomLeftXDiff = abs(rectangle.bottomLeftX - aggregate.bottomLeftX);
            int bottomLeftYDiff = abs(rectangle.bottomLeftY - aggregate.bottomLeftY);
            int bottomRightXDiff = abs(rectangle.bottomRightX - aggregate.bottomRightX);
            int bottomRightYDiff = abs(rectangle.bottomRightY - aggregate.bottomRightY);
            
            if ( topLeftXDiff > maxDiff || topLeftYDiff > maxDiff || topRightXDiff > maxDiff || topRightYDiff > maxDiff || bottomLeftXDiff > maxDiff || bottomLeftYDiff > maxDiff || bottomRightXDiff > maxDiff || bottomRightYDiff > maxDiff ){
                
                return YES;
            }
            
            return NO;
        }
    }
}

- (void) removeOldestFrameFromRectangleQueue{
    @synchronized(queueLockObject){
        if ( queue ){
            int index = (int)[queue count] - 1;
            if ( index >= 0 ){
                [queue removeObjectAtIndex:index];
            }
        }
    }
}

- (void) addRectangleToQueue:(Rectangle *)rectangle{
    @synchronized(queueLockObject){
        if ( queue ){
            // per apple docs, If index is already occupied, the objects at index and beyond are shifted by adding 1 to their indices to make room.
            // put the rectangle at index 0 and let the NSArray scoot everything back one position
            [queue insertObject:rectangle atIndex:0];
        }
    }
}

- (Rectangle *) getLargestRectangleInFrame:(cv::Mat)mat{
    return nil;
}

- (void)captureImageWithCompletionHander:(void(^)(NSString *imageFilePath))completionHandler
{
    
    dispatch_suspend(_captureQueue);
    
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
    
    __weak typeof(self) weakSelf = self;
    
    Rectangle* rectangle = [rectangleCALayer getCurrentRectangle];
    
    /*
    if ([self.captureDevice lockForConfiguration:nil])
    {
        //captureDevice.activeFormat = format
        [self.captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
        //[self.captureSession startRunning];
        [self.captureDevice unlockForConfiguration];
    }
     */
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         if (error)
         {
             dispatch_resume(_captureQueue);
             return;
         }
         
         __block NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"ipdf_img_%i.jpeg",(int)[NSDate date].timeIntervalSince1970]];
         
         @autoreleasepool
         {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage* image = [[UIImage alloc] initWithData:imageData];
             
             image = [image fixOrientation:image];
             
             Rectangle *newRectangle = [self rotationRectangle:rectangle];
             
             image = [weakSelf correctPerspectiveForImage:image withFeatures:newRectangle];
             
             image = [weakSelf confirmedImage:image withFeatures:rectangle];
             
             NSData *jpgData = UIImageJPEGRepresentation(image, 1.0f);
             [jpgData writeToFile:filePath atomically:NO];
             
             NSLog(@"=== OK");
             
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                completionHandler(filePath);
                                dispatch_resume(_captureQueue);
                            });
         }
     }];
}

- (UIImage *)confirmedImage:(UIImage*)sourceImage withFeatures:(Rectangle *)rectangle
{
    
    CGSize imageSize = sourceImage.size;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    float a = imageSize.width / screenSize.width;
    float b = imageSize.height / screenSize.height;
    //float c = MAX(a, b);
    
    cv::Mat img = [sourceImage CVMat];
    
    std::vector<cv::Point2f> corners(4);
    corners[0] = cv::Point2f(rectangle.topLeftX * a, rectangle.topLeftY * b );
    corners[1] = cv::Point2f(rectangle.topRightX * a, rectangle.topRightY * b );
    corners[2] = cv::Point2f(rectangle.bottomLeftX * a, rectangle.bottomLeftY * b );
    corners[3] = cv::Point2f(rectangle.bottomRightX * a, rectangle.bottomRightY * b );
    
    std::vector<cv::Point2f> corners_trans(4);
//    corners_trans[0] = cv::Point2f(0,0);
//    corners_trans[1] = cv::Point2f(img.cols,0);
//    corners_trans[2] = cv::Point2f(img.cols,img.rows);
//    corners_trans[3] = cv::Point2f(0,img.rows);
    
    // Assemble a rotated rectangle out of that info
    cv::RotatedRect box = minAreaRect(cv::Mat(corners));
    std::cout << "Rotated box set to (" << box.boundingRect().x << "," << box.boundingRect().y << ") " << box.size.width << "x" << box.size.height << std::endl;
    
//    cv::Point2f pts[4];
//    box.points(pts);

    corners_trans[0] = cv::Point(0, 0);
    corners_trans[1] = cv::Point(box.boundingRect().width - 1, 0);
    corners_trans[2] = cv::Point(0, box.boundingRect().height - 1);
    corners_trans[3] = cv::Point(box.boundingRect().width - 1, box.boundingRect().height - 1);
    
    cv::Mat warpMatrix = getPerspectiveTransform(corners, corners_trans);
    //cv::Mat rotated;
    
    cv::Mat outt;
    cv::Size size(box.boundingRect().width, box.boundingRect().height);
    warpPerspective(img, outt, warpMatrix,size, 1, 0, 0);
    
    //cv::warpPerspective(img, quad, warpMatrix, quad.size());
    //warpPerspective(img, rotated, warpMatrix, rotated.size(), cv::INTER_LINEAR, cv::BORDER_CONSTANT);

    return [UIImage imageWithCVMat:outt];
    
    /*
     
    // 这里顺利打印出了四个点
    cv::Mat draw = img.clone();
    
    // draw the polygon
    cv::circle(draw,corners[0],5,cv::Scalar(0,0,255),2.5);
    cv::circle(draw,corners[1],5,cv::Scalar(0,0,255),2.5);
    cv::circle(draw,corners[2],5,cv::Scalar(0,0,255),2.5);
    cv::circle(draw,corners[3],5,cv::Scalar(0,0,255),2.5);
    
    return [UIImage imageWithCVMat:draw];
    */
    
}

cv::Point2f RotatePoint(const cv::Point2f& p, float rad)
{
    const float x = std::cos(rad) * p.x - std::sin(rad) * p.y;
    const float y = std::sin(rad) * p.x + std::cos(rad) * p.y;
    
    const cv::Point2f rot_p(x, y);
    return rot_p;
}

cv::Point2f RotatePoint(const cv::Point2f& cen_pt, const cv::Point2f& p, float rad)
{
    const cv::Point2f trans_pt = p - cen_pt;
    const cv::Point2f rot_pt   = RotatePoint(trans_pt, rad);
    const cv::Point2f fin_pt   = rot_pt + cen_pt;
    
    return fin_pt;
}

CGFloat flipHorizontalPointX(float pointX, CGFloat screenWidth) {
    return screenWidth - pointX;
}

-(Rectangle *)rotationRectangle:(Rectangle *)rectangle
{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    
    cv::Point2f center = cv::Point2f((screenWidth / 2), (screenHeight / 2));
    
    cv::Point2f topLeft = RotatePoint(center, cv::Point2f(rectangle.topLeftX, rectangle.topLeftY), M_PI);
    cv::Point2f topRight = RotatePoint(center, cv::Point2f(rectangle.topRightX, rectangle.topRightY), M_PI);
    cv::Point2f bottomLeft = RotatePoint(center, cv::Point2f(rectangle.bottomLeftX, rectangle.bottomLeftY), M_PI);
    cv::Point2f bottomRight = RotatePoint(center, cv::Point2f(rectangle.bottomRightX, rectangle.bottomRightY), M_PI);
    
    Rectangle *newRectangle = [[Rectangle alloc] init];
    newRectangle.topLeftX = flipHorizontalPointX(topLeft.x, screenWidth);
    newRectangle.topLeftY = topLeft.y;
    newRectangle.topRightX = flipHorizontalPointX(topRight.x, screenWidth);
    newRectangle.topRightY = topRight.y;
    newRectangle.bottomLeftX = flipHorizontalPointX(bottomLeft.x, screenWidth);
    newRectangle.bottomLeftY = bottomLeft.y;
    newRectangle.bottomRightX = flipHorizontalPointX(bottomRight.x, screenWidth);
    newRectangle.bottomRightY = bottomRight.y;
    return newRectangle;
}

- (UIImage *)correctPerspectiveForImage:(UIImage *)image withFeatures:(Rectangle *)rectangle
{
    // 定义左上角，右上角，左下角，右下角
    CGPoint tlp, trp, blp, brp;
    
    tlp = CGPointMake(rectangle.topLeftX, rectangle.topLeftY);
    trp = CGPointMake(rectangle.topRightX, rectangle.topRightY);
    blp = CGPointMake(rectangle.bottomLeftX, rectangle.bottomLeftY);
    brp = CGPointMake(rectangle.bottomRightX, rectangle.bottomRightY);
    
    NSLog(@"LT:%@ RT:%@ LB:%@ RB:%@", NSStringFromCGPoint(tlp),NSStringFromCGPoint(trp),NSStringFromCGPoint(blp),NSStringFromCGPoint(brp));
    
    CGSize imageSize = image.size;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float screenRatio = screenSize.width / screenSize.height;
    imageSize.height = imageSize.width / screenRatio;
    
    float a = imageSize.width / screenSize.width;
    float b = imageSize.height / screenSize.height;
    float c = MAX(a, b);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, image.size.width, image.size.height, 8, 4 * image.size.width, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, rect);
    
    CGColorRef fillColor = [[UIColor whiteColor] CGColor];
    CGContextSetFillColor(context, CGColorGetComponents(fillColor));
    
    CGContextMoveToPoint(context, tlp.x * c, tlp.y * c);
    CGContextAddLineToPoint(context, trp.x * c, trp.y * c);
    CGContextAddLineToPoint(context, brp.x * c, brp.y * c);
    CGContextAddLineToPoint(context, blp.x * c, blp.y * c);
    
    CGContextClosePath(context);
    CGContextClip(context);

    CGContextDrawImage(context, rect, image.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    return newImage;
}

//- (UIImage *)correctPerspectiveForImage:(UIImage *)image withFeatures:(Rectangle *)rectangle
//{
//    // 定义左上角，右上角，左下角，右下角
//    CGPoint tlp, trp, blp, brp;
//    /*
//    if (rectangle.topLeftY - rectangle.topRightY > 0)
//    {
//        //(36,61),(245,56),(27,350),(330,317)
//        if (rectangle.topLeftX - rectangle.bottomLeftX > 0)
//        {
//            tlp = CGPointMake(rectangle.topLeftX - rectangle.bottomLeftX, rectangle.topLeftY - rectangle.topRightY);
//            trp = CGPointMake(rectangle.topRightX - rectangle.bottomLeftX, 1);
//            blp = CGPointMake(1, rectangle.bottomLeftY - rectangle.topRightY);
//            brp = CGPointMake(rectangle.bottomRightX - rectangle.bottomLeftX, rectangle.bottomRightY - rectangle.topRightY);
//        }
//        else{
//            tlp = CGPointMake(1, rectangle.topLeftY - rectangle.topRightY);
//            trp = CGPointMake(rectangle.topRightX - rectangle.topLeftX, 1);
//            blp = CGPointMake(rectangle.bottomLeftX - rectangle.topLeftX, rectangle.bottomLeftY - rectangle.topRightY);
//            brp = CGPointMake(rectangle.bottomRightX - rectangle.topLeftX, rectangle.bottomLeftY - rectangle.topRightY);
//        }
//    }
//    else {
//        if (rectangle.topLeftX - rectangle.bottomLeftX > 0)
//        {
//            tlp = CGPointMake(rectangle.topLeftX - rectangle.bottomLeftX, 1);
//            trp = CGPointMake(rectangle.topRightX - rectangle.bottomLeftX, rectangle.topRightY - rectangle.topLeftY);
//            blp = CGPointMake(1, rectangle.bottomRightY - rectangle.topLeftY);
//            brp = CGPointMake(rectangle.bottomRightX - rectangle.bottomLeftX, rectangle.bottomRightY - rectangle.topLeftY);
//        }else{
//            tlp = CGPointMake(1, 1);
//            trp = CGPointMake(rectangle.topRightX - rectangle.topLeftX, rectangle.topRightY - rectangle.topLeftY);
//            blp = CGPointMake(rectangle.bottomLeftX - rectangle.topLeftX, rectangle.bottomLeftY - rectangle.topLeftY);
//            brp = CGPointMake(rectangle.bottomRightX - rectangle.topLeftX, rectangle.bottomRightY - rectangle.topLeftY);
//        }
//    }
//    */
//    
//    tlp = CGPointMake(rectangle.topLeftX, rectangle.topLeftY);
//    trp = CGPointMake(rectangle.topRightX, rectangle.topRightY);
//    blp = CGPointMake(rectangle.bottomLeftX, rectangle.bottomLeftY);
//    brp = CGPointMake(rectangle.bottomRightX, rectangle.bottomRightY);
//    
//    NSLog(@"LT:%@ RT:%@ LB:%@ RB:%@", NSStringFromCGPoint(tlp),NSStringFromCGPoint(trp),NSStringFromCGPoint(blp),NSStringFromCGPoint(brp));
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
//    CGContextMoveToPoint(context, tlp.x * a, tlp.y * a);
//    CGContextAddLineToPoint(context, trp.x * a, trp.y * a);
//    CGContextAddLineToPoint(context, brp.x * a, brp.y * a);
//    CGContextAddLineToPoint(context, blp.x * a, blp.y * a);
//    
//    CGContextClosePath(context);
//    CGContextClip(context);
//    //CGContextRotateCTM (context, -90/180*M_PI);
//    image = [image flipHorizontal];
//    CGContextDrawImage(context, rect, image.CGImage);
//    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
//    UIImage *newImage = [UIImage imageWithCGImage:imageMasked];
//    CGImageRelease(imageMasked);
//    return newImage;
//}

void saveCGImageAsJPEGToFilePath(CGImageRef imageRef, NSString *filePath)
{
//    UIImage *uiImage = [UIImage imageWithCGImage:imageRef];
//    NSData *jpgData = UIImageJPEGRepresentation(uiImage, 1.0f);
//    [jpgData writeToFile:filePath atomically:NO];
    
    @autoreleasepool
    {
        CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:filePath];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypeJPEG, 1, NULL);
        CGImageDestinationAddImage(destination, imageRef, nil);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
    }
}

@end
