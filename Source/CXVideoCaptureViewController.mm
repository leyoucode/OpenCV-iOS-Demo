//
//  CXVideoCaptureViewController.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 12/01/2017.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXVideoCaptureViewController.h"

#import "CXVideoCaptureView.h"
#import "StringUtils.h"

#import "CXVideoCaptureViewController+CaptureImage.h"
#import "CXVideoCaptureViewController+CaptureDocument.h"
#import "CXVideoCaptureViewController+Configuration.h"

#import "CXImagePreviewViewController.h"
#import "CXVideoPreviewViewController.h"

#import "UIView+Ext.h"

@interface CXVideoCaptureViewController()<CXVideoCaptureViewDelegate>
{
    NSTimer *_calVideoDurationTimer;
    CXVideoCaptureView *rootView;
}

@end

@implementation CXVideoCaptureViewController

#pragma mark - ViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    _camera = 0;
    
    rootView = [[CXVideoCaptureView alloc] initWithFrame:self.view.frame andCameraMediaType:self.cameraMediaType];
    rootView.delegate = self;
    [self.view addSubview:rootView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupAVCapture];
    [self reloadCameraConfiguration];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self tearDownAVCapture];
}

- (NSString *)videoPath {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *moviePath = [basePath stringByAppendingPathComponent:
                           [NSString stringWithFormat:@"%f.mov",[NSDate date].timeIntervalSince1970]];
    return moviePath;
}

- (void)startVideoCapture {
    [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self videoPath]] recordingDelegate:rootView];
}


- (void)stopVideoCapture {
    if ([self.movieFileOutput isRecording]) {
        [self.movieFileOutput stopRecording];
    }
}

#pragma mark - Sensor control

// Set torch on or off (if supported)
- (void)setTorchOn:(BOOL)torch
{
    NSError *error = nil;
    if ([_videoDevice hasTorch]) {
        BOOL locked = [_videoDevice lockForConfiguration:&error];
        if (locked) {
            _videoDevice.torchMode = (torch)? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
            [_videoDevice unlockForConfiguration];
        }
    }
}

// Return YES if the torch is on
- (BOOL)torchOn
{
    return (_videoDevice.torchMode == AVCaptureTorchModeOn);
}

/**
  Choose front/back Camera
 
 @param camera 0:Back 1:Front
 */
- (void)setCamera:(int)camera
{
    if (camera != 0 && camera != 1)
    {
        return;
    }
    
    if (camera != _camera)
    {
        if (_captureSession) {
            
            NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            
            if (camera < 0 && camera >= [devices count]) {
                NSLog(@"摄像头无法访问:%d",camera);
                return;
            }
            [_captureSession beginConfiguration];
            
            /*
            NSArray *inputs = _captureSession.inputs;
            for (AVCaptureDeviceInput *input in inputs ) {
                AVCaptureDevice *device = input.device;
                if ( [device hasMediaType:AVMediaTypeVideo] ) {
                    //AVCaptureDevicePosition position = device.position;
                    [_captureSession removeInput:input];
                    break;
                }
            }
             */
            
            // Remove current camera
            [_captureSession removeInput:_videoInput];
            _videoInput = nil;

            _videoDevice = [devices objectAtIndex:camera];
            _camera = camera;
            
            // Create device input
            NSError *error = nil;
            _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&error];
            [_captureSession addInput:_videoInput];
            
            [_captureSession commitConfiguration];
        }
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.cameraMediaType == kCameraMediaTypeDocument)
    {
        [self processDocumentBuffer:sampleBuffer];
    }
    else if(self.cameraMediaType == kCameraMediaTypePhoto)
    {
        NSLog(@"kCameraMediaTypePhoto");
    }
    else if(self.cameraMediaType == kCameraMediaTypeVideo)
    {
        NSLog(@"kCameraMediaTypeVideo");
    }
}

#pragma mark - AVCapture initilization and destroy

- (BOOL)setupAVCapture
{
    // Get capture devices from current iPhone
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if ([devices count] == 0) {
        NSLog(@"ANTBETA: No any Camera be Found.");
        return NO;
    }
    
    if (_camera < 0 && _camera >= [devices count]) {
        NSLog(@"ANTBETA: The camera[%d] Can not be found from current device.", _camera);
        return NO;
    }
    
    _videoDevice = [devices objectAtIndex:_camera];
    
    // Create a video input with the video device.
    NSError *error = nil;
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&error];
    if (error) {
        NSLog(@"ANTBETA: An error occured when create an AVCaptureDeviceInput with '_videoDevice': %@",[error description]);
        return NO;
    }
    
    // Create a CaptureSession, It coordinates the flow of data between audio and video inputs and outputs.
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // Connect up inputs and outputs
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    
    // Create the preview layer
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setFrame:self.view.bounds];
    
    NSLog(@"%@",NSStringFromCGRect(self.view.bounds));
    
    _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
    
    [_captureSession startRunning];
    
    return YES;
}

// Tear down the video capture session
- (void)tearDownAVCapture
{
    [self.captureSession stopRunning];
    for (AVCaptureOutput *output in self.captureSession.outputs) {
        [self.captureSession removeOutput:output];
    }
    for (AVCaptureInput *input in self.captureSession.inputs) {
        [self.captureSession removeInput:input];
    }
    
    [_rectangleCALayer removeFromSuperlayer];
    _rectangleCALayer = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
    _videoPreviewLayer = nil;
    
    _videoInput = nil;
    _audioInput = nil;
    
    _videoOutput = nil;
    _audioDataOutput = nil;
    
    _videoDevice = nil;
    _audioDevice = nil;
    
    _movieFileOutput = nil;
    _stillImageOutput = nil;
    
    _captureSession = nil;
}

#pragma mark - CXVideoCaptureViewDelegate

// It will be triggered when you switch the Tabs by swipe view to right or left with your finger
- (void) onViewChanged:(CameraMediaType)type
{
    NSLog(@"onViewChanged");
    self.cameraMediaType = type;
    [self reloadCameraConfiguration];
}

/* The follow events will be triggered when you click relative Buttons */
-(void) onCancelButtonClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) onTorchButtonClick
{
    [self setTorchOn:![self torchOn]];
}
-(void) onCameraButtonClick
{
    if ( _camera == 0)
    {
        [self setCamera:1];
    }else{
        [self setCamera:0];
    }
}
-(void) onVideoCaptureStartButtonClick
{
    [self startVideoCapture];
}
-(void) onVideoCaptureStopButtonClick
{
    [self stopVideoCapture];
}
-(void) onCaptureImageButtonCick
{
    __weak typeof(self) weakSelf = self;
    [self captureImageWithCompletionHander:^(NSString *imageFilePath) {
        CXImagePreviewViewController *previewController = [[CXImagePreviewViewController alloc] init];
        previewController.imagePath = imageFilePath;
        previewController.cameraMediaType = self.cameraMediaType;
        previewController.cameraCaptureResult = weakSelf.cameraCaptureResult;
        [weakSelf.navigationController pushViewController:previewController animated:NO];
    }];
}
-(void) onCaptureDocumentButtonCick
{
    __weak typeof(self) weakSelf = self;
    [self captureDocumentWithCompletionHander:^(NSString *imageFilePath) {
        CXImagePreviewViewController *previewController = [[CXImagePreviewViewController alloc] init];
        previewController.imagePath = imageFilePath;
        previewController.cameraMediaType = self.cameraMediaType;
        previewController.cameraCaptureResult = weakSelf.cameraCaptureResult;
        [weakSelf.navigationController pushViewController:previewController animated:NO];
    }];
}
-(void) didStartVideoRecording
{
    if (_calVideoDurationTimer == nil) {
        _calVideoDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleCalVideoDuration:) userInfo:nil repeats:YES];
    }
}

-(void) didStopVideoRecording:(NSString *)videoPath
{
    if (_calVideoDurationTimer != nil) {
        [_calVideoDurationTimer invalidate];
        _calVideoDurationTimer = nil;
    }
    
    CXVideoPreviewViewController *previewController = [[CXVideoPreviewViewController alloc] init];
    previewController.videoPath = videoPath;
    previewController.cameraMediaType = self.cameraMediaType;
    previewController.cameraCaptureResult = self.cameraCaptureResult;
    [self.navigationController pushViewController:previewController animated:NO];
    
//    // Call back when finished capture
//    self.cameraCaptureResult(self.cameraMediaType, videoPath);
//    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)handleCalVideoDuration:(NSTimer*)timer
{
    float totalSeconds = CMTimeGetSeconds(self.movieFileOutput.recordedDuration);
    rootView.recordDurationLabel.text = [StringUtils stringFromInterval:totalSeconds];
}


@end
