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

- (void) displayDataForVideoRect:(CGRect)rect videoOrientation:(AVCaptureVideoOrientation)videoOrientation{
    
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

//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
//    
//    NSLog(@"aggregateRectangle => %@",aggregateRectangle);
//    
//    if ( aggregateRectangle ){
//        
//        
//        CGContextSetLineWidth(context, 2.0);
//        CGContextSetStrokeColorWithColor(context, [[UIColor greenColor] CGColor]);
//        CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:1 alpha:0.25] CGColor]);
//        
//        CGContextMoveToPoint(context, aggregateRectangle.topLeftX, aggregateRectangle.topLeftY);
//        
//        CGContextAddLineToPoint(context, aggregateRectangle.topRightX, aggregateRectangle.topRightY);
//        
//        CGContextAddLineToPoint(context, aggregateRectangle.bottomRightX, aggregateRectangle.bottomRightY);
//        
//        CGContextAddLineToPoint(context, aggregateRectangle.bottomLeftX, aggregateRectangle.bottomLeftY);
//        
//        CGContextAddLineToPoint(context, aggregateRectangle.topLeftX, aggregateRectangle.topLeftY);
//        
//        CGContextDrawPath(context, kCGPathFillStroke);
//    }
//}







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
             UIImage* myImage = [[UIImage alloc] initWithData:imageData];
             
             
             
             myImage = [myImage fixOrientation:myImage];
             
//             myImage = [UIImage imageWithCGImage:myImage.CGImage
//                                                         scale:myImage.scale
//                                                   orientation:UIImageOrientationUpMirrored];
             
             myImage = [myImage imageRotatedByDegrees:180];
             
             Rectangle* rectangle = [rectangleCALayer getCurrentRectangle];
             
             
             //UIImage* mm = [self confirmedImage:myImage withFeatures:rectangle];
             
//             NSData *jpgData = UIImageJPEGRepresentation(myImage, 1.0f);
//             
//             CIImage *enhancedImage = [[CIImage alloc] initWithData:jpgData options:@{kCIImageColorSpace:[NSNull null]}];
             
             //myImage = [self confirmedImage:myImage withFeatures:rectangle];
             
             myImage = [self correctPerspectiveForImage:myImage withFeatures:rectangle];
             
             myImage = [myImage flipHorizontal];
             myImage = [myImage imageRotatedByDegrees:180];
             
             NSData *jpgData = UIImageJPEGRepresentation(myImage, 1.0f);
             [jpgData writeToFile:filePath atomically:NO];
             
             NSLog(@"===");
//             int w1 = abs(rectangle.topRightX - rectangle.topLeftX);
//             int w2 = abs(rectangle.topRightX - rectangle.bottomLeftX);
//             int w3 = abs(rectangle.bottomRightX - rectangle.bottomLeftX);
//             int w4 = abs(rectangle.bottomRightX - rectangle.topLeftX);
//             
//             
//             int h1 = abs(rectangle.bottomLeftY - rectangle.topLeftY);
//             int h2 = abs(rectangle.bottomLeftY - rectangle.topRightY);
//             int h3 = abs(rectangle.bottomRightY - rectangle.topRightY);
//             int h4 = abs(rectangle.bottomRightY - rectangle.topLeftY);
//             
//             int maxWidth = MAX(MAX(w1,w2),MAX(w3,w4));
//             int maxHeight = MAX(MAX(h1,h2),MAX(h3,h4));
//
//             CGSize imageSize = myImage.size;
//             CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//             float a = imageSize.width / screenSize.width;
//             float b = imageSize.height / screenSize.height;
//
//             CGRect rect = CGRectMake(MIN(rectangle.topLeftX, rectangle.bottomLeftX) * a,
//                                     MIN(rectangle.topLeftY, rectangle.topRightY) * b,
//                                     maxWidth * a,
//                                     maxHeight * b);
//             // Create bitmap image from original image data,
//             // using rectangle to specify desired crop area
//             CGImageRef imageRef = CGImageCreateWithImageInRect(myImage.CGImage, rect);
//             UIImage *img = [UIImage imageWithCGImage:imageRef];
//             saveCGImageAsJPEGToFilePath(imageRef, filePath);
//             CGImageRelease(imageRef);
             
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                completionHandler(filePath);
                                dispatch_resume(_captureQueue);
                            });
             
             
//             if (!enhancedImage || CGRectIsEmpty(enhancedImage.extent)) return;
//             
//             static CIContext *ctx = nil;
//             if (!ctx)
//             {
//                 ctx = [CIContext contextWithOptions:@{kCIContextWorkingColorSpace:[NSNull null]}];
//             }
//             
//             CGSize bounds = enhancedImage.extent.size;
//             bounds = CGSizeMake(floorf(bounds.width / 4) * 4,floorf(bounds.height / 4) * 4);
//             CGRect extent = CGRectMake(enhancedImage.extent.origin.x, enhancedImage.extent.origin.y, bounds.width, bounds.height);
//             
//             static int bytesPerPixel = 8;
//             uint rowBytes = bytesPerPixel * bounds.width;
//             uint totalBytes = rowBytes * bounds.height;
//             uint8_t *byteBuffer = (uint8_t *)malloc(totalBytes);
//             
//             CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//             
//             [ctx render:enhancedImage toBitmap:byteBuffer rowBytes:rowBytes bounds:extent format:kCIFormatRGBA8 colorSpace:colorSpace];
//             
//             CGContextRef bitmapContext = CGBitmapContextCreate(byteBuffer,bounds.width,bounds.height,bytesPerPixel,rowBytes,colorSpace,kCGImageAlphaNoneSkipLast);
//             CGImageRef imgRef = CGBitmapContextCreateImage(bitmapContext);
//             CGColorSpaceRelease(colorSpace);
//             CGContextRelease(bitmapContext);
//             free(byteBuffer);
//             
//             if (imgRef == NULL)
//             {
//                 CFRelease(imgRef);
//                 return;
//             }
//             saveCGImageAsJPEGToFilePath(imgRef, filePath);
//             CFRelease(imgRef);
//             
//             dispatch_async(dispatch_get_main_queue(), ^
//                            {
//                                completionHandler(filePath);
//                                dispatch_resume(_captureQueue);
//                            });
         }
     }];
}



- (UIImage *)confirmedImage:(UIImage*)sourceImage withFeatures:(Rectangle *)rectangle
{
    cv::Mat originalRot = [sourceImage CVMat];//[self cvMatFromUIImage:_sourceImage];
    cv::Mat original;
    cv::transpose(originalRot, original);
    
    originalRot.release();
    
    cv::flip(original, original, 1);
    
    
//    CGFloat scaleFactor =  1;//[_sourceImageView contentScale];
//    
//    CGPoint ptBottomLeft = //[_adjustRect coordinatesForPoint:1 withScaleFactor:scaleFactor];
//    CGPoint ptBottomRight = [_adjustRect coordinatesForPoint:2 withScaleFactor:scaleFactor];
//    CGPoint ptTopRight = [_adjustRect coordinatesForPoint:3 withScaleFactor:scaleFactor];
//    CGPoint ptTopLeft = [_adjustRect coordinatesForPoint:4 withScaleFactor:scaleFactor];
//    
//    CGFloat w1 = sqrt( pow(ptBottomRight.x - ptBottomLeft.x , 2) + pow(ptBottomRight.x - ptBottomLeft.x, 2));
//    CGFloat w2 = sqrt( pow(ptTopRight.x - ptTopLeft.x , 2) + pow(ptTopRight.x - ptTopLeft.x, 2));
//    
//    CGFloat h1 = sqrt( pow(ptTopRight.y - ptBottomRight.y , 2) + pow(ptTopRight.y - ptBottomRight.y, 2));
//    CGFloat h2 = sqrt( pow(ptTopLeft.y - ptBottomLeft.y , 2) + pow(ptTopLeft.y - ptBottomLeft.y, 2));
//    
//    CGFloat maxWidth = (w1 < w2) ? w1 : w2;
//    CGFloat maxHeight = (h1 < h2) ? h1 : h2;
    
    CGSize imageSize = sourceImage.size;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float a = imageSize.width / screenSize.width;
    float b = imageSize.height / screenSize.height;
    float c = MAX(a, b);
    
    cv::Point2f src[4], dst[4];
    src[0].x = rectangle.topLeftX * c;//ptTopLeft.x;
    src[0].y = rectangle.topLeftY * c;//ptTopLeft.y;
    src[1].x = rectangle.topRightX * c;//ptTopRight.x;
    src[1].y = rectangle.topRightY * c;//ptTopRight.y;
    src[2].x = rectangle.bottomRightX * c;//ptBottomRight.x;
    src[2].y = rectangle.bottomRightY * c;//ptBottomRight.y;
    src[3].x = rectangle.bottomLeftX * c;//ptBottomLeft.x;
    src[3].y = rectangle.bottomLeftY * c;//ptBottomLeft.y;
    
    
    int w1 = abs(rectangle.topRightX - rectangle.topLeftX);
    int w2 = abs(rectangle.topRightX - rectangle.bottomLeftX);
    int w3 = abs(rectangle.bottomRightX - rectangle.bottomLeftX);
    int w4 = abs(rectangle.bottomRightX - rectangle.topLeftX);
    
    
    int h1 = abs(rectangle.bottomLeftY - rectangle.topLeftY);
    int h2 = abs(rectangle.bottomLeftY - rectangle.topRightY);
    int h3 = abs(rectangle.bottomRightY - rectangle.topRightY);
    int h4 = abs(rectangle.bottomRightY - rectangle.topLeftY);
    
    int maxWidth = MAX(MAX(w1,w2),MAX(w3,w4));
    int maxHeight = MAX(MAX(h1,h2),MAX(h3,h4));

    

    
    dst[0].x = 0;
    dst[0].y = 0;
    dst[1].x = (maxWidth - 1) * c;
    dst[1].y = 0;
    dst[2].x = (maxWidth - 1) * c;
    dst[2].y = (maxWidth - 1) * c;
    dst[3].x = 0;
    dst[3].y = (maxHeight - 1) * c;
    
    cv::Mat undistorted = cv::Mat( cvSize(maxWidth * c,maxHeight * c), CV_8UC1);
    cv::warpPerspective(original, undistorted, cv::getPerspectiveTransform(src, dst), cvSize(maxWidth, maxHeight));
    
    UIImage *newImage = [UIImage imageWithCVMat:undistorted];//[self UIImageFromCVMat:undistorted];
    
    undistorted.release();
    original.release();
   
    return newImage;
}

//CFDataRef save_cgimage_to_jpeg (CGImageRef image)
//{
//    CFMutableDataRef cfdata = CFDataCreateMutable(nil,0);
//    CGImageDestinationRef dest = CGImageDestinationCreateWithData(data, CFSTR("public.jpeg"), 1, NULL);
//    CGImageDestinationAddImage(dest, image, NULL);
//    if(!CGImageDestinationFinalize(dest))
//        ; // error
//    CFRelease(dest);
//    return cfdata
//}


- (UIImage *)correctPerspectiveForImage:(UIImage *)image withFeatures:(Rectangle *)rectangle
{
    // 定义左上角，右上角，左下角，右下角
    CGPoint tlp, trp, blp, brp;
    
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
    
    tlp = CGPointMake(rectangle.topLeftX, rectangle.topLeftY);
    trp = CGPointMake(rectangle.topRightX, rectangle.topRightY);
    blp = CGPointMake(rectangle.bottomLeftX, rectangle.bottomLeftY);
    brp = CGPointMake(rectangle.bottomRightX, rectangle.bottomRightY);
    
    NSLog(@"LT:%@ RT:%@ LB:%@ RB:%@", NSStringFromCGPoint(tlp),NSStringFromCGPoint(trp),NSStringFromCGPoint(blp),NSStringFromCGPoint(brp));
    
    CGSize imageSize = image.size;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
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
    //CGContextRotateCTM (context, -90/180*M_PI);
    image = [image flipHorizontal];
    CGContextDrawImage(context, rect, image.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *newImage = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    return newImage;
}
 

/*
- (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeatures:(Rectangle *)rectangle size:(CGSize) imageSize
{
    
//    CGSize imageSize = myImage.size;
     CGSize screenSize = [[UIScreen mainScreen] bounds].size;
     float a = imageSize.width / screenSize.width;
     float b = imageSize.height / screenSize.height;
     float c = MAX(a, b);

//     CGRect rect = CGRectMake(MIN(rectangle.topLeftX, rectangle.bottomLeftX) * a,
//                             MIN(rectangle.topLeftY, rectangle.topRightY) * b,
//                             maxWidth * a,
//                             maxHeight * b);
    
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:CGPointMake(rectangle.topLeftX * c, rectangle.topLeftY * c )];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:CGPointMake(rectangle.topRightX * c, rectangle.topRightY * c)];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:CGPointMake(rectangle.bottomLeftX * c, rectangle.bottomLeftY * c)];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:CGPointMake(rectangle.bottomRightX * c, rectangle.bottomRightY * c)];
    return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}
 */

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
