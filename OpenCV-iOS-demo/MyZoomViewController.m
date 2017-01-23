//
//  MyZoomViewController.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 22/01/2017.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "MyZoomViewController.h"

#define MRScreenWidth      CGRectGetWidth([[UIScreen mainScreen] bounds])
#define MRScreenHeight     CGRectGetHeight([[UIScreen mainScreen] bounds])

@interface MyZoomViewController ()<UIScrollViewDelegate>

@end

@implementation MyZoomViewController
@synthesize srcollView = _srcollView;
@synthesize imageView = _imageView;
@synthesize imagePath = _imagePath;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _srcollView = [[UIScrollView alloc]init];
    _srcollView.delegate = self;
    
    _srcollView.userInteractionEnabled = YES;
    _srcollView.showsHorizontalScrollIndicator = YES;//是否显示侧边的滚动栏
    _srcollView.showsVerticalScrollIndicator = NO;
    _srcollView.scrollsToTop = NO;
    _srcollView.scrollEnabled = YES;
    _srcollView.frame = CGRectMake(0, 0, MRScreenWidth, MRScreenHeight);
    
    UIImage *img = [UIImage imageWithContentsOfFile:_imagePath];
    _imageView = [[UIImageView alloc]initWithImage:img];
    //设置这个_imageView能被缩放的最大尺寸，这句话很重要，一定不能少,如果没有这句话，图片不能缩放
    _imageView.frame = CGRectMake(0, 0, MRScreenWidth, MRScreenHeight);
    
    [self.view addSubview:_srcollView];
    [_srcollView addSubview:_imageView];
    
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [_srcollView addGestureRecognizer:singleTapGesture];
    
    // Add gesture,double tap zoom imageView.
//    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                       action:@selector(handleDoubleTap:)];
//    [doubleTapGesture setNumberOfTapsRequired:2];
//    [_srcollView addGestureRecognizer:doubleTapGesture];
    
    
    //    float minimumScale = _srcollView.frame.size.width / _imageView.frame.size.width;//最小缩放倍数
    //    [_srcollView setMinimumZoomScale:minimumScale];
    //    [_srcollView setZoomScale:0.5f];
    
    [_srcollView setMinimumZoomScale:0.5f];
    [_srcollView setMaximumZoomScale:3.0f];
    [_srcollView setZoomScale:1.0f animated:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - Zoom methods

- (void)handleSingleTap:(UIGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    NSLog(@"handleDoubleTap");
    float newScale = _srcollView.zoomScale * 1.5;//zoomScale这个值决定了contents当前扩展的比例
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [_srcollView zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = _srcollView.frame.size.height / scale;
    NSLog(@"zoomRect.size.height is %f",zoomRect.size.height);
    NSLog(@"self.frame.size.height is %f",_srcollView.frame.size.height);
    zoomRect.size.width  = _srcollView.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}
//当滑动结束时
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    //把当前的缩放比例设进ZoomScale，以便下次缩放时实在现有的比例的基础上
    NSLog(@"scale is %f",scale);
    [_srcollView setZoomScale:scale animated:NO];
}



@end
