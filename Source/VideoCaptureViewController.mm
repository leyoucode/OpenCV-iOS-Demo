//
//  OpenCVClientViewController.m
//  OpenCVClient
//
//  Created by Robin Summerhill on 02/09/2011.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "VideoCaptureViewController.h"
#import "UIView+Ext.h"

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>

// Private interface
@interface VideoCaptureViewController ()
- (BOOL)createCaptureSessionForCamera:(NSInteger)camera qualityPreset:(NSString *)qualityPreset grayscale:(BOOL)grayscale;
- (void)destroyCaptureSession;
- (void)processFrame:(cv::Mat&)mat videoRect:(CGRect)rect videoOrientation:(AVCaptureVideoOrientation)orientation;
@end


@interface VideoCaptureViewController()
/**
 顶部容器视图
 */
@property (strong, nonatomic) UIView *topContentView;
/**
 闪光灯
 */
@property (strong, nonatomic) UIButton *torchButton;
/**
 前后摄像头切换
 */
@property (strong, nonatomic) UIButton *cameraButton;
/**
 录制视频时长显示
 */
@property (strong, nonatomic) UILabel *recordDurationLabel;
/**
 底部容器视图
 */
@property (strong, nonatomic) UIView *bottomContentView;
/**
 拍照/录制按钮
 */
@property (strong, nonatomic) UIButton *takeButton;
/**
 切换为视屏录制模式
 */
@property (strong, nonatomic) UIButton *videoTabButton;
/**
 切换为拍照模式
 */
@property (strong, nonatomic) UIButton *photoTabButton;
/**
 切换为拍摄文档模式
 */
@property (strong, nonatomic) UIButton *documentTabButton;
/**
 取消按钮
 */
@property (strong, nonatomic) UIButton *cancelButton;
@end

@implementation VideoCaptureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _camera = -1;
        _qualityPreset = AVCaptureSessionPresetHigh;//AVCaptureSessionPresetMedium
        _captureGrayscale = YES;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _captureQueue = dispatch_queue_create("com.linkim.AVCameraCaptureQueue", DISPATCH_QUEUE_SERIAL);
    [self createCaptureSessionForCamera:_camera qualityPreset:_qualityPreset grayscale:_captureGrayscale];
    [_captureSession startRunning];
    
    [self setupControl];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self destroyCaptureSession];
}

// Set torch on or off (if supported)
- (void)setTorchOn:(BOOL)torch
{
    NSError *error = nil;
    if ([_captureDevice hasTorch]) {
        BOOL locked = [_captureDevice lockForConfiguration:&error];
        if (locked) {
            _captureDevice.torchMode = (torch)? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
            [_captureDevice unlockForConfiguration];
        }
    }
}

// Return YES if the torch is on
- (BOOL)torchOn
{
    return (_captureDevice.torchMode == AVCaptureTorchModeOn);
}


// Switch camera 'on-the-fly'
//
// camera: 0 for back camera, 1 for front camera
//
- (void)setCamera:(int)camera
{
    if (camera != _camera)
    {
        _camera = camera;
        
        if (_captureSession) {
            NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            
            [_captureSession beginConfiguration];
            
            [_captureSession removeInput:[[_captureSession inputs] lastObject]];

            if (_camera >= 0 && _camera < [devices count]) {
                _captureDevice = [devices objectAtIndex:camera];
            }
            else {
                _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            }
         
            // Create device input
            NSError *error = nil;
            AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:_captureDevice error:&error];
            [_captureSession addInput:input];
            
            [_captureSession commitConfiguration];
        }
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate delegate methods

// AVCaptureVideoDataOutputSampleBufferDelegate delegate method called when a video frame is available
//
// This method is called on the video capture GCD queue. A cv::Mat is created from the frame data and
// passed on for processing with OpenCV.
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection
{
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    OSType format = CVPixelBufferGetPixelFormatType(pixelBuffer);
    CGRect videoRect = CGRectMake(0.0f, 0.0f, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    AVCaptureVideoOrientation videoOrientation = [[[_videoOutput connections] objectAtIndex:0] videoOrientation];
    
    if (format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        // For grayscale mode, the luminance channel of the YUV data is used
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void *baseaddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        
        cv::Mat mat(videoRect.size.height, videoRect.size.width, CV_8UC1, baseaddress, 0);
        
        [self processFrame:mat videoRect:videoRect videoOrientation:videoOrientation];
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0); 
    }
    else if (format == kCVPixelFormatType_32BGRA) {
        // For color mode a 4-channel cv::Mat is created from the BGRA data
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void *baseaddress = CVPixelBufferGetBaseAddress(pixelBuffer);
        
        cv::Mat mat(videoRect.size.height, videoRect.size.width, CV_8UC4, baseaddress, 0);
        
        [self processFrame:mat videoRect:videoRect videoOrientation:videoOrientation];
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);    
    }
    else {
        NSLog(@"Unsupported video format");
    }
}


// MARK: Methods to override

// Override this method to process the video frame with OpenCV
//
// Note that this method is called on the video capture GCD queue. Use dispatch_sync or dispatch_async to update UI
// from the main queue.
//
// mat: The frame as an OpenCV::Mat object. The matrix will have 1 channel for grayscale frames and 4 channels for
//      BGRA frames. (Use -[VideoCaptureViewController setGrayscale:])
// rect: A CGRect describing the video frame dimensions
// orientation: Will generally by AVCaptureVideoOrientationLandscapeRight for the back camera and
//              AVCaptureVideoOrientationLandscapeRight for the front camera
//
- (void)processFrame:(cv::Mat &)mat videoRect:(CGRect)rect videoOrientation:(AVCaptureVideoOrientation)orientation
{

}

// MARK: Geometry methods

// Create an affine transform for converting CGPoints and CGRects from the video frame coordinate space to the
// preview layer coordinate space. Usage:
//
// CGPoint viewPoint = CGPointApplyAffineTransform(videoPoint, transform);
// CGRect viewRect = CGRectApplyAffineTransform(videoRect, transform);
//
// Use CGAffineTransformInvert to create an inverse transform for converting from the view cooridinate space to
// the video frame coordinate space.
//
// videoFrame: a rect describing the dimensions of the video frame
// video orientation: the video orientation
//
// Returns an affine transform
//
- (CGAffineTransform)affineTransformForVideoFrame:(CGRect)videoFrame orientation:(AVCaptureVideoOrientation)videoOrientation
{
    CGSize viewSize = self.view.bounds.size;
    NSString * const videoGravity = _videoPreviewLayer.videoGravity;
    CGFloat widthScale = 1.0f;
    CGFloat heightScale = 1.0f;
    
    // Move origin to center so rotation and scale are applied correctly
    CGAffineTransform t = CGAffineTransformMakeTranslation(-videoFrame.size.width / 2.0f, -videoFrame.size.height / 2.0f);
    
    switch (videoOrientation) {
        case AVCaptureVideoOrientationPortrait:
            widthScale = viewSize.width / videoFrame.size.width;
            heightScale = viewSize.height / videoFrame.size.height;
            break;
            
        case AVCaptureVideoOrientationPortraitUpsideDown:
            t = CGAffineTransformConcat(t, CGAffineTransformMakeRotation(M_PI));
            widthScale = viewSize.width / videoFrame.size.width;
            heightScale = viewSize.height / videoFrame.size.height;
            break;
            
        case AVCaptureVideoOrientationLandscapeRight:
            t = CGAffineTransformConcat(t, CGAffineTransformMakeRotation(M_PI_2));
            widthScale = viewSize.width / videoFrame.size.height;
            heightScale = viewSize.height / videoFrame.size.width;
            break;
            
        case AVCaptureVideoOrientationLandscapeLeft:
            t = CGAffineTransformConcat(t, CGAffineTransformMakeRotation(-M_PI_2));
            widthScale = viewSize.width / videoFrame.size.height;
            heightScale = viewSize.height / videoFrame.size.width;
            break;
    }
    
    // Adjust scaling to match video gravity mode of video preview
    if (videoGravity == AVLayerVideoGravityResizeAspect) {
        heightScale = MIN(heightScale, widthScale);
        widthScale = heightScale;
    }
    else if (videoGravity == AVLayerVideoGravityResizeAspectFill) {
        heightScale = MAX(heightScale, widthScale);
        widthScale = heightScale;
    }
    
    // Apply the scaling
    t = CGAffineTransformConcat(t, CGAffineTransformMakeScale(widthScale, heightScale));
    
    // Move origin back from center
    t = CGAffineTransformConcat(t, CGAffineTransformMakeTranslation(viewSize.width / 2.0f, viewSize.height / 2.0f));
                                
    return t;
}

// MARK: Private methods

// Sets up the video capture session for the specified camera, quality and grayscale mode
//
//
// camera: -1 for default, 0 for back camera, 1 for front camera
// qualityPreset: [AVCaptureSession sessionPreset] value
// grayscale: YES to capture grayscale frames, NO to capture RGBA frames
//
- (BOOL)createCaptureSessionForCamera:(NSInteger)camera qualityPreset:(NSString *)qualityPreset grayscale:(BOOL)grayscale
{
//    _lastFrameTimestamp = 0;
//    _frameTimesIndex = 0;
//    _captureQueueFps = 0.0f;
//    _fps = 0.0f;
	
    // Set up AV capture
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if ([devices count] == 0) {
        NSLog(@"No video capture devices found");
        return NO;
    }
    
    if (camera == -1) {
        _camera = -1;
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    else if (camera >= 0 && camera < [devices count]) {
        _camera = (int)camera;
        _captureDevice = [devices objectAtIndex:camera];
    }
    else {
        _camera = -1;
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSLog(@"Camera number out of range. Using default camera");
    }
    
    // Create the capture session
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = (qualityPreset)? qualityPreset : AVCaptureSessionPresetMedium;
    
    // Create device input
    NSError *error = nil;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:_captureDevice error:&error];
    
    // Create and configure device output
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    //dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
    [_videoOutput setSampleBufferDelegate:self queue:_captureQueue];
    
    _videoOutput.alwaysDiscardsLateVideoFrames = YES; 
    _videoOutput.minFrameDuration = CMTimeMake(1, 30);
    
    
    // For grayscale mode, the luminance channel from the YUV fromat is used
    // For color mode, BGRA format is used
    OSType format = kCVPixelFormatType_32BGRA;

    /*
    // Check YUV format is available before selecting it (iPhone 3 does not support it)
    if (NO && grayscale && [_videoOutput.availableVideoCVPixelFormatTypes containsObject:
                      [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]]) {
        format = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    }
     */
    
    _videoOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:format]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    
    // Connect up inputs and outputs
    if ([_captureSession canAddInput:input]) {
        [_captureSession addInput:input];
    }
    
    if ([_captureSession canAddOutput:_videoOutput]) {
        [_captureSession addOutput:_videoOutput];
    }
    
    if ([_captureSession canAddOutput:_stillImageOutput]) {
        [_captureSession addOutput:_stillImageOutput];
    }
    
    
    // Create the preview layer
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setFrame:self.view.bounds];
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
    
    return YES;
}

// Tear down the video capture session
- (void)destroyCaptureSession
{
    [_captureSession stopRunning];
    
    [_videoPreviewLayer removeFromSuperlayer];
    
    _videoPreviewLayer = nil;
    _videoOutput = nil;
    _captureDevice = nil;
    _captureSession = nil;
}

#pragma mark - UI Element

- (void) setupControl
{
    [self.view addSubview:self.topContentView];
    self.topContentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    
    [self.topContentView addSubview:self.torchButton];
    self.torchButton.frame = CGRectMake(0, 0, VIEW_HEIGHT(self.topContentView), VIEW_HEIGHT(self.topContentView));
    
    [self.topContentView addSubview:self.cameraButton];
    self.cameraButton.frame = CGRectMake(0, 0, VIEW_HEIGHT(self.topContentView), VIEW_HEIGHT(self.topContentView));
    [self.cameraButton modifyX:SCREEN_WIDTH - VIEW_WIDTH(self.cameraButton)];
    
    [self.topContentView addSubview:self.recordDurationLabel];
    self.recordDurationLabel.frame = CGRectMake(VIEW_WIDTH(self.torchButton), 0, (SCREEN_WIDTH - VIEW_WIDTH(self.torchButton) - VIEW_WIDTH(self.cameraButton)), VIEW_HEIGHT(self.topContentView));
    
    self.bottomContentView.frame = CGRectMake(0, SCREEN_HEIGHT - 120, SCREEN_WIDTH, 120);
    [self.view addSubview:self.bottomContentView];
    
    [self.view addSubview:self.takeButton];
    [self.takeButton modifySize:CGSizeMake(57, 57)];
    [self.takeButton modifyCenterX:self.bottomContentView.center.x];
    [self.takeButton modifyCenterY:self.bottomContentView.center.y + 10];
    [self.takeButton modifyY:VIEW_TOP(self.takeButton) + 10];
    
    [self.view addSubview:self.cancelButton];
    [self.cancelButton modifyX:10];
    [self.cancelButton modifySize:CGSizeMake(50, 40)];
    [self.cancelButton modifyCenterY:self.takeButton.center.y];

    
    [self.bottomContentView addSubview:self.videoTabButton];
    [self.bottomContentView addSubview:self.photoTabButton];
    [self.bottomContentView addSubview:self.documentTabButton];
    
    [self setupTabWithAnimated:NO];
    
    [self setSwipe];
    [self setClick];
}

- (void) setSwipe
{
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:swipeRight];
    [self.view addGestureRecognizer:swipeLeft];
}

- (void) setClick
{
    [self.cancelButton addTarget:self action:@selector(onControlElementClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.takeButton addTarget:self action:@selector(onControlElementClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.torchButton addTarget:self action:@selector(onControlElementClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton addTarget:self action:@selector(onControlElementClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) onControlElementClick:(id) sender
{
    // 点击取消按钮
    if (sender == self.cancelButton) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    // 点击闪光灯按钮
    if (sender == self.torchButton) {
        [self setTorchOn:![self torchOn]];
    }
    // 点击相机切换按钮
    if (sender == self.cameraButton) {
        if ( self.camera == 0)
        {
            [self setCamera:1];
        }else{
            [self setCamera:0];
        }
    }
    // 点击拍照／录制按钮
    if (sender == self.takeButton) {
        switch (self.cameraMediaType) {
            case kCameraMediaTypeVideo:// 录制视频
                
                if (self.takeButton.tag == 0) {
                    self.takeButton.tag = 1;
                    [self.takeButton setImage:[UIImage imageNamed:@"record_ing"] forState:UIControlStateNormal];
                    self.bottomContentView.hidden = YES;
                    self.cameraButton.hidden = YES;
                    self.cancelButton.hidden = YES;
                    
                }else{
                    self.takeButton.tag = 0;
                    [self.takeButton setImage:[UIImage imageNamed:@"record_idle"] forState:UIControlStateNormal];
                    self.bottomContentView.hidden = NO;
                    self.cameraButton.hidden = NO;
                    self.cancelButton.hidden = NO;
                }
                
                
                
                break;
            case kCameraMediaTypePhoto:// 拍照
                
                
                break;
            case kCameraMediaTypeDocument:// 拍摄文档
                
                
                break;
            default:
                break;
        }
    }
}

- (void) setupTabWithAnimated:(BOOL)animated
{
    switch (self.cameraMediaType) {
        case kCameraMediaTypeVideo:
            if (animated) {
                [UIView animateWithDuration:0.4 animations:^{
                    [self setVideoTabSelected];
                } completion:^(BOOL finished) {
                    
                }];
            }
            else
            {
                [self setVideoTabSelected];
            }
            break;
        case kCameraMediaTypePhoto:
            if (animated) {
                [UIView animateWithDuration:0.4 animations:^{
                    [self setPhotoTabSelected];
                } completion:^(BOOL finished) {
                    
                }];
            }
            else
            {
                [self setPhotoTabSelected];
            }
            break;
        case kCameraMediaTypeDocument:
            if (animated) {
                [UIView animateWithDuration:0.4 animations:^{
                    [self setDocumentTabSelected];
                } completion:^(BOOL finished) {
                    
                }];
            }
            else
            {
                [self setDocumentTabSelected];
            }
            break;
        default:
            break;
    }
}

-(void) setPhotoTabSelected
{
    self.photoTabButton.frame = CGRectMake(0, 6, 50, 30);
    [self.photoTabButton fitToHorizontalCenterWithView:self.bottomContentView];
    
    [self.videoTabButton modifyY:VIEW_TOP(self.photoTabButton)];
    [self.videoTabButton modifySize:CGSizeMake(VIEW_WIDTH(self.photoTabButton), VIEW_HEIGHT(self.photoTabButton))];
    [self.videoTabButton modifyRight:VIEW_LEFT(self.photoTabButton)];
    
    [self.documentTabButton modifyY:VIEW_TOP(self.photoTabButton)];
    [self.documentTabButton modifySize:CGSizeMake(VIEW_WIDTH(self.photoTabButton), VIEW_HEIGHT(self.photoTabButton))];
    [self.documentTabButton modifyX:VIEW_RIGHT(self.photoTabButton)];
    
    [self.videoTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.photoTabButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self.documentTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.takeButton setImage:[UIImage imageNamed:@"takephoto"] forState:UIControlStateNormal];
    self.topContentView.alpha = 1.0;
    self.bottomContentView.alpha = 1.0;
}

-(void) setVideoTabSelected
{
    self.videoTabButton.frame = CGRectMake(0, 6, 50, 30);
    self.videoTabButton.frame = CGRectMake(0, 6, 50, 30);
    [self.videoTabButton fitToHorizontalCenterWithView:self.bottomContentView];
    
    [self.photoTabButton modifyY:VIEW_TOP(self.videoTabButton)];
    [self.photoTabButton modifySize:CGSizeMake(VIEW_WIDTH(self.videoTabButton), VIEW_HEIGHT(self.videoTabButton))];
    [self.photoTabButton modifyX:VIEW_RIGHT(self.videoTabButton)];
    
    [self.documentTabButton modifyY:VIEW_TOP(self.videoTabButton)];
    [self.documentTabButton modifySize:CGSizeMake(VIEW_WIDTH(self.videoTabButton), VIEW_HEIGHT(self.videoTabButton))];
    [self.documentTabButton modifyX:VIEW_RIGHT(self.photoTabButton)];
    
    [self.videoTabButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self.photoTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.documentTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.takeButton setImage:[UIImage imageNamed:@"record_idle"] forState:UIControlStateNormal];
    self.topContentView.alpha = 0.5;
    self.bottomContentView.alpha = 0.5;
}

-(void) setDocumentTabSelected
{
    self.documentTabButton.frame = CGRectMake(0, 6, 50, 30);
    [self.documentTabButton fitToHorizontalCenterWithView:self.bottomContentView];
    
    [self.photoTabButton modifyY:VIEW_TOP(self.documentTabButton)];
    [self.photoTabButton modifySize:CGSizeMake(VIEW_WIDTH(self.documentTabButton), VIEW_HEIGHT(self.documentTabButton))];
    [self.photoTabButton modifyRight:VIEW_LEFT(self.documentTabButton)];
    
    [self.videoTabButton modifyY:VIEW_TOP(self.documentTabButton)];
    [self.videoTabButton modifySize:CGSizeMake(VIEW_WIDTH(self.documentTabButton), VIEW_HEIGHT(self.documentTabButton))];
    [self.videoTabButton modifyRight:VIEW_LEFT(self.photoTabButton)];
    
    [self.videoTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.photoTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.documentTabButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    
    [self.takeButton setImage:[UIImage imageNamed:@"takephoto"] forState:UIControlStateNormal];
    self.topContentView.alpha = 1.0;
    self.bottomContentView.alpha = 1.0;
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        //NSLog(@"right %f, %f, %f",self.photoTabButton.center.x, self.videoTabButton.center.x, self.bottomContentView.center.x);
        if (self.photoTabButton.center.x == self.bottomContentView.center.x) {
            self.cameraMediaType = kCameraMediaTypeVideo;
            [self setupTabWithAnimated:YES];
        }else if (self.documentTabButton.center.x == self.bottomContentView.center.x) {
            self.cameraMediaType = kCameraMediaTypePhoto;
            [self setupTabWithAnimated:YES];
        }
    }
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        //NSLog(@"left %f, %f, %f",self.photoTabButton.center.x, self.videoTabButton.center.x, self.bottomContentView.center.x);
        
        if (self.videoTabButton.center.x == self.bottomContentView.center.x) {
            self.cameraMediaType = kCameraMediaTypePhoto;
            [self setupTabWithAnimated:YES];
        }
        else if (self.photoTabButton.center.x == self.bottomContentView.center.x) {
            self.cameraMediaType = kCameraMediaTypeDocument;
            [self setupTabWithAnimated:YES];
        }
    }
}

/**
 顶部容器视图
 */
- (UIView *) topContentView
{
    if(!_topContentView)
    {
        _topContentView = [[UIView alloc] init];
        [_topContentView setBackgroundColor:[UIColor blackColor]];
    }
    return _topContentView;
}

/**
 闪光灯
 */
- (UIButton *) torchButton
{
    if (!_torchButton) {
        _torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_torchButton setImage:[UIImage imageNamed:@"record_flash_off"] forState:UIControlStateNormal];
    }
    return _torchButton;
}
/**
 前后摄像头切换
 */
- (UIButton *) cameraButton
{
    if (!_cameraButton) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setImage:[UIImage imageNamed:@"record_camera"] forState:UIControlStateNormal];
    }
    return _cameraButton;
}
/**
 录制视频时长显示
 */
- (UILabel *) recordDurationLabel
{
    if (!_recordDurationLabel) {
        _recordDurationLabel = [[UILabel alloc] init];
        _recordDurationLabel.textAlignment = NSTextAlignmentCenter;
        _recordDurationLabel.text = @"00:00:00";
        _recordDurationLabel.textColor = [UIColor whiteColor];
    }
    return _recordDurationLabel;
}
/**
 底部容器视图
 */
- (UIView *) bottomContentView
{
    if (!_bottomContentView) {
        _bottomContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
        [_bottomContentView setBackgroundColor:[UIColor blackColor]];
    }
    return _bottomContentView;
}
/**
 拍照/录制按钮
 */
- (UIButton *) takeButton
{
    if (!_takeButton) {
        _takeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takeButton setImage:[UIImage imageNamed:@"record_idle"] forState:UIControlStateNormal];
    }
    return _takeButton;
}

/**
 切换为视屏录制模式
 */
- (UIButton *) videoTabButton
{
    if (!_videoTabButton) {
        _videoTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoTabButton setTitle:@"视频" forState:UIControlStateNormal];
        _videoTabButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _videoTabButton;
}

/**
 切换为拍照模式
 */
- (UIButton *) photoTabButton
{
    if (!_photoTabButton) {
        _photoTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoTabButton setTitle:@"照片" forState:UIControlStateNormal];
        _photoTabButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _photoTabButton;
}
/**
 切换为拍摄文档模式
 */
- (UIButton *) documentTabButton
{
    if (!_documentTabButton) {
        _documentTabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_documentTabButton setTitle:@"文档" forState:UIControlStateNormal];
        _documentTabButton.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _documentTabButton;
}
/**
 取消按钮
 */
- (UIButton *) cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _cancelButton;
}



@end
