//
//  EdgeDetectingViewController.m
//  OpenCVVideoFeedSample
//
//  Created by Dan Bucholtz on 9/2/14.
//  Copyright (c) 2014 NXSW. All rights reserved.
//

#import "CannyEdgeDetectingViewController.h"

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>

#import "Rectangle.h"

@implementation CannyEdgeDetectingViewController


- (IBAction)onToggleTorchClick:(UIButton *)sender {
    [self setTorchOn:![self torchOn]];
}

- (IBAction)onToggleCameraClick:(UIButton *)sender {
    if ( self.camera == 0)
    {
        [self setCamera:1];
    }else{
        [self setCamera:0];
    }
}

- (IBAction)onTakeButtonClick:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    
    [self captureImageWithCompletionHander:^(NSString *imageFilePath) {
       
        UIImageView *captureImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imageFilePath]];
        captureImageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        captureImageView.frame = CGRectOffset(weakSelf.view.bounds, 0, -weakSelf.view.bounds.size.height);
        captureImageView.alpha = 1.0;
        captureImageView.contentMode = UIViewContentModeScaleAspectFit;
        captureImageView.userInteractionEnabled = YES;
        [weakSelf.view addSubview:captureImageView];
        
        UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(dismissPreview:)];
        [captureImageView addGestureRecognizer:dismissTap];
        
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionAllowUserInteraction animations:^
         {
             captureImageView.frame = weakSelf.view.bounds;
         } completion:nil];
        
    }];
}

- (void)dismissPreview:(UITapGestureRecognizer *)dismissTap
{
    [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:^
     {
         dismissTap.view.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.size.height);
     }
                     completion:^(BOOL finished)
     {
         [dismissTap.view removeFromSuperview];
     }];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = YES;
    //[self setShowDebugInfo:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTest:)];
    tap.numberOfTapsRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tap];
}

-(void) tapTest: (UITapGestureRecognizer *)tab
{
    __weak typeof(self) weakSelf = self;
    
    [self captureImageWithCompletionHander:^(NSString *imageFilePath) {
        
        UIImageView *captureImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imageFilePath]];
        captureImageView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        captureImageView.frame = CGRectOffset(weakSelf.view.bounds, 0, -weakSelf.view.bounds.size.height);
        captureImageView.alpha = 1.0;
        captureImageView.contentMode = UIViewContentModeScaleAspectFit;
        captureImageView.userInteractionEnabled = YES;
        [weakSelf.view addSubview:captureImageView];
        
        UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(dismissPreview:)];
        [captureImageView addGestureRecognizer:dismissTap];
        
        [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionAllowUserInteraction animations:^
         {
             captureImageView.frame = weakSelf.view.bounds;
         } completion:nil];
        
    }];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}



- (Rectangle *) getLargestRectangleInFrame:(cv::Mat)mat{
    
    std::vector<std::vector<cv::Point>>squares;
    std::vector<cv::Point> largest_square;
    
    find_squares(mat, squares);
    find_largest_square(squares, largest_square);
    Rectangle * rectangle;
    if (largest_square.size() == 4 ){
        NSMutableArray * points = [[NSMutableArray alloc] initWithCapacity:4];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(largest_square[0].x, largest_square[0].y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(largest_square[1].x, largest_square[1].y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(largest_square[2].x, largest_square[2].y)]];
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(largest_square[3].x, largest_square[3].y)]];
        
        // okay, sort it by the X, then split it
        NSArray * sortedArray = [points sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
            CGPoint firstPoint = [obj1 CGPointValue];
            CGPoint secondPoint = [obj2 CGPointValue];
            if (firstPoint.x > secondPoint.x) {
                return NSOrderedDescending;
            } else if (firstPoint.x < secondPoint.x) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        // we're sorted on X, so grab two of those bitches and figure out top and bottom
        NSMutableArray * left = [[NSMutableArray alloc] initWithCapacity:2];
        NSMutableArray * right = [[NSMutableArray alloc] initWithCapacity:2];
        [left addObject:sortedArray[0]];
        [left addObject:sortedArray[1]];
        
        [right addObject:sortedArray[2]];
        [right addObject:sortedArray[3]];
        
        // okay, now sort each of those arrays on the Y access
        NSArray * sortedLeft = [left sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
            CGPoint firstPoint = [obj1 CGPointValue];
            CGPoint secondPoint = [obj2 CGPointValue];
            if (firstPoint.y > secondPoint.y) {
                return NSOrderedDescending;
            } else if (firstPoint.y < secondPoint.y) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        NSArray * sortedRight = [right sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
            CGPoint firstPoint = [obj1 CGPointValue];
            CGPoint secondPoint = [obj2 CGPointValue];
            if (firstPoint.y > secondPoint.y) {
                return NSOrderedDescending;
            } else if (firstPoint.y < secondPoint.y) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        CGPoint topLeftOriginal = [[sortedLeft objectAtIndex:0] CGPointValue];
        
        CGPoint topRightOriginal = [[sortedRight objectAtIndex:0] CGPointValue];
        
        CGPoint bottomLeftOriginal = [[sortedLeft objectAtIndex:1] CGPointValue];
        
        CGPoint bottomRightOriginal = [[sortedRight objectAtIndex:1] CGPointValue];
        
        rectangle = [[Rectangle alloc] init];
        
        
        rectangle.bottomLeftX = bottomLeftOriginal.x;
        rectangle.bottomRightX = bottomRightOriginal.x;
        rectangle.topLeftX = topLeftOriginal.x;
        rectangle.topRightX = topRightOriginal.x;
        
        rectangle.bottomLeftY = bottomLeftOriginal.y;
        rectangle.bottomRightY = bottomRightOriginal.y;
        rectangle.topLeftY = topLeftOriginal.y;
        rectangle.topRightY = topRightOriginal.y;
    }
    
    return rectangle;
}

void find_squares(cv::Mat& image, std::vector<std::vector<cv::Point>>&squares) {
    
    // blur will enhance edge detection
    cv::Mat blurred(image);
    
    /*
        medianBlur函数使用中值滤波器来平滑（模糊）处理一张图片，从src输入，而结果从dst输出。且对于多通道图片，每一个通道都单独进行处理，并且支持就地操作（In-placeoperation）。
        第一个参数，InputArray类型的src，函数的输入参数，填1、3或者4通道的Mat类型的图像；当ksize为3或者5的时候，图像深度需为CV_8U，CV_16U，或CV_32F其中之一，而对于较大孔径尺寸的图片，它只能是CV_8U。
        第二个参数，OutputArray类型的dst，即目标图像，函数的输出参数，需要和源图片有一样的尺寸和类型。我们可以用Mat::Clone，以源图片为模板，来初始化得到如假包换的目标图。
        第三个参数，int类型的ksize，孔径的线性尺寸（aperture linear size），注意这个参数必须是大于1的奇数，比如：3，5，7，9 ...
     */
    medianBlur(image, blurred, 7);
    
    cv::Mat gray0(blurred.size(), CV_8U), gray;
    std::vector<std::vector<cv::Point>> contours;
    
    // find squares in every color plane of the image
    for (int c = 0; c < 3; c++)
    {
        int ch[] = {c, 0};
        mixChannels(&blurred, 1, &gray0, 1, ch, 1);
        
        // try several threshold levels
        const int threshold_level = 4;
        for (int l = 0; l < threshold_level; l++)
        {
            // Use Canny instead of zero threshold level!
            // Canny helps to catch squares with gradient shading
            if (l == 0){
                
                /*
                 采用Canny方法对图像进行边缘检测
                 第一个参数表示输入图像，必须为单通道灰度图。
                 第二个参数表示输出的边缘图像，为单通道黑白图。
                 第三个参数和第四个参数表示阈值，这二个阈值中当中的小阈值用来控制边缘连接，大的阈值用来控制强边缘的初始分割即如果一个像素的梯度大与上限值，则被认为是边缘像素，如果小于下限阈值，则被抛弃。如果该点的梯度在两者之间则当这个点与高于上限值的像素点连接时我们才保留，否则删除。
                 第五个参数表示Sobel 算子大小，默认为3即表示一个3*3的矩阵。
                 
                 */
                Canny(gray0, gray, 100, 100, 3); //
                //Canny(gray0, gray, 1, 3, 5); //
                // Dilate helps to remove potential holes between edge segments
                dilate(gray, gray, cv::Mat(), cv::Point(-1,-1));
            }
            else{
                gray = gray0 >= (l+1) * 255 / threshold_level;
                //cv::Size size = image.size();
                //cv::adaptiveThreshold(gray0, gray, threshold_level, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, (size.width + size.height) / 200, l);
            }
            
            // Find contours and store them in a list
            //findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            /*
             第一个参数：image，单通道图像矩阵，可以是灰度图，但更常用的是二值图像，一般是经过Canny、拉普拉斯等边
             缘检测算子处理过的二值图像；
             第二个参数：contours，定义为“vector<vector<Point>> contours”，是一个向量，并且是一个双重向量，向量
             内每个元素保存了一组由连续的Point点构成的点的集合的向量，每一组Point点集就是一个轮廓。
             有多少轮廓，向量contours就有多少元素。
             第三个参数：int型的mode，定义轮廓的检索模式：
                         取值一：CV_RETR_EXTERNAL只检测最外围轮廓，包含在外围轮廓内的内围轮廓被忽略
                         取值二：CV_RETR_LIST   检测所有的轮廓，包括内围、外围轮廓，但是检测到的轮廓不建立等级关
                         系，彼此之间独立，没有等级关系，这就意味着这个检索模式下不存在父轮廓或内嵌轮廓，
                         所以hierarchy向量内所有元素的第3、第4个分量都会被置为-1，具体下文会讲到
                         取值三：CV_RETR_CCOMP  检测所有的轮廓，但所有轮廓只建立两个等级关系，外围为顶层，若外围
                         内的内围轮廓还包含了其他的轮廓信息，则内围内的所有轮廓均归属于顶层
                         取值四：CV_RETR_TREE， 检测所有轮廓，所有轮廓建立一个等级树结构。外层轮廓包含内层轮廓，内
                         层轮廓还可以继续包含内嵌轮廓。
             第五个参数：int型的method，定义轮廓的近似方法：
                         取值一：CV_CHAIN_APPROX_NONE 保存物体边界上所有连续的轮廓点到contours向量内
                         取值二：CV_CHAIN_APPROX_SIMPLE 仅保存轮廓的拐点信息，把所有轮廓拐点处的点保存入contours
                         向量内，拐点与拐点之间直线段上的信息点不予保留
                         取值三和四：CV_CHAIN_APPROX_TC89_L1，CV_CHAIN_APPROX_TC89_KCOS使用teh-Chinl chain 近
                         似算法
             */
            findContours(gray, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
            
            // Test contours
            std::vector<cv::Point> approx;
            for (size_t i = 0; i < contours.size(); i++)
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
                
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                //if (approx.size() == 4 && fabs(contourArea(cv::Mat(approx))) > 100 && isContourConvex(cv::Mat(approx)))
                if (approx.size() == 4 && fabs(contourArea(cv::Mat(approx))) > 500 ){
                    //if ( approx.size() == 4 ){
                    double maxCosine = 0;
                    
                    for (int j = 2; j < 5; j++){
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }
                    
                    if (maxCosine < 0.3)
                        squares.push_back(approx);
                }
            }
        }
    }
}

// helper function:
// finds a cosine of angle between vectors
// from pt0->pt1 and from pt0->pt2
double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 ) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}


void find_largest_square(const std::vector<std::vector<cv::Point> >& squares, std::vector<cv::Point>& biggest_square)
{
    if (!squares.size()){
        // no squares detected
        return;
    }
    
    /*int max_width = 0;
     int max_height = 0;
     int max_square_idx = 0;
     
     for (size_t i = 0; i < squares.size(); i++)
     {
     // Convert a set of 4 unordered Points into a meaningful cv::Rect structure.
     cv::Rect rectangle = boundingRect(cv::Mat(squares[i]));
     
     //        cout << "find_largest_square: #" << i << " rectangle x:" << rectangle.x << " y:" << rectangle.y << " " << rectangle.width << "x" << rectangle.height << endl;
     
     // Store the index position of the biggest square found
     if ((rectangle.width >= max_width) && (rectangle.height >= max_height))
     {
     max_width = rectangle.width;
     max_height = rectangle.height;
     max_square_idx = (int) i;
     }
     }
     
     biggest_square = squares[max_square_idx];
     */
    
    double maxArea = 0;
    int largestIndex = -1;
    
    for ( int i = 0; i < squares.size(); i++){
        std::vector<cv::Point> square = squares[i];
        double area = contourArea(cv::Mat(square));
        if ( area >= maxArea){
            largestIndex = i;
            maxArea = area;
        }
    }
    if ( largestIndex >= 0 && largestIndex < squares.size() ){
        biggest_square = squares[largestIndex];
    }
    return;
}

@end
