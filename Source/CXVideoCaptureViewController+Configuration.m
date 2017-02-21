//
//  CXVideoCaptureViewController+Configuration.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXVideoCaptureViewController+Configuration.h"
#import <AVFoundation/AVFoundation.h>

@implementation CXVideoCaptureViewController (Configuration)

- (void) reloadCameraConfiguration
{
    switch (self.cameraMediaType) {
        case kCameraMediaTypeVideo:// 录制视频
            [self configurationForVideo];
            if (self.rectangleCALayer) {
                [self.rectangleCALayer removeFromSuperlayer];
                self.rectangleCALayer = nil;
            }
            break;
        case kCameraMediaTypePhoto:// 拍照
            [self configurationForPhoto];
            if (self.rectangleCALayer) {
                [self.rectangleCALayer removeFromSuperlayer];
                self.rectangleCALayer = nil;
            }
            break;
        case kCameraMediaTypeDocument:// 拍摄文档
            [self configurationForDocument];
            if (!self.rectangleCALayer) {
                self.rectangleCALayer = [[RectangleCALayer alloc] init];
            }
            [self.videoPreviewLayer addSublayer:self.rectangleCALayer];
            break;
        default:
            break;
    }
}

// 配置拍照参数
- (void) configurationForPhoto
{
    if (self.captureSession)
    {
        [self.captureSession beginConfiguration];
        
        if (self.videoOutput)
        {
            [self.captureSession removeOutput:self.videoOutput];
            self.videoOutput = nil;
        }
        if (self.audioInput)
        {
            [self.captureSession removeInput:self.audioInput];
            self.audioInput = nil;
            self.audioDevice = nil;
        }
        if (self.audioDataOutput)
        {
            [self.captureSession removeOutput:self.audioDataOutput];
            self.audioDataOutput = nil;
        }
        if (self.movieFileOutput)
        {
            [self.captureSession removeOutput:self.movieFileOutput];
            self.movieFileOutput = nil;
        }
        if (self.stillImageOutput)
        {
            [self.captureSession removeOutput:self.stillImageOutput];
            self.stillImageOutput = nil;
        }
        
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        
        if ([self.captureSession canAddOutput:self.stillImageOutput]) {
            [self.captureSession addOutput:self.stillImageOutput];
        }
        
        [self.captureSession commitConfiguration];
    }
}

// To configure specific video's settings
- (void) configurationForVideo
{
    if (self.captureSession)
    {
        [self.captureSession beginConfiguration];
        
        if (self.videoOutput)
        {
            [self.captureSession removeOutput:self.videoOutput];
            self.videoOutput = nil;
        }
        if (self.audioInput)
        {
            [self.captureSession removeInput:self.audioInput];
            self.audioInput = nil;
            self.audioDevice = nil;
        }
        if (self.audioDataOutput)
        {
            [self.captureSession removeOutput:self.audioDataOutput];
            self.audioDataOutput = nil;
        }
        if (self.movieFileOutput)
        {
            [self.captureSession removeOutput:self.movieFileOutput];
            self.movieFileOutput = nil;
        }
        if (self.stillImageOutput)
        {
            [self.captureSession removeOutput:self.stillImageOutput];
            self.stillImageOutput = nil;
        }
        
        self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        
        // Get audio device
        self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        
        // Create an audio device with the audio device.
        NSError *error = nil;
        self.audioInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioDevice error:&error];
        if (error) {
            NSLog(@"ANTBETA: An error occured when create an AVCaptureDeviceInput with 'self.audioDevice': %@",[error description]);
            return;
        }
        
        // The easiest option to write video to file is through an AVCaptureMovieFileOutput object. Adding it as an output to a capture session will let you write audio and video to a QuickTime file with a minimum amount of configuration:
        self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        self.movieFileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(30, 30);
        
        if ([self.captureSession canAddInput:self.audioInput]) {
            [self.captureSession addInput:self.audioInput];
        }
        if ([self.captureSession canAddOutput:self.movieFileOutput]) {
            [self.captureSession addOutput:self.movieFileOutput];
        }
        
        [self.captureSession commitConfiguration];
    }
    
}

// 配置拍摄文档录制参数
- (void) configurationForDocument
{
    if (self.captureSession)
    {
        [self.captureSession beginConfiguration];
        
        if (self.camera == 1)
        { // 1是前置摄像头，需要换成后置摄像头
            NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            if ([devices count] == 0) {
                NSLog(@"ANTBETA: No any Camera be Found.");
                [self.captureSession commitConfiguration];
                return;
            }
            // Remove current camera
            [self.captureSession removeInput:self.videoInput];
            self.videoInput = nil;
            
            self.videoDevice = [devices objectAtIndex:0];
            self.camera = 0;
            
            // Create device input
            NSError *error = nil;
            self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.videoDevice error:&error];
            [self.captureSession addInput:self.videoInput];
        }
        if (self.videoOutput)
        {
            [self.captureSession removeOutput:self.videoOutput];
            self.videoOutput = nil;
        }
        if (self.audioInput)
        {
            [self.captureSession removeInput:self.audioInput];
            self.audioInput = nil;
            self.audioDevice = nil;
        }
        if (self.audioDataOutput)
        {
            [self.captureSession removeOutput:self.audioDataOutput];
            self.audioDataOutput = nil;
        }
        if (self.movieFileOutput)
        {
            [self.captureSession removeOutput:self.movieFileOutput];
            self.movieFileOutput = nil;
        }
        if (self.stillImageOutput)
        {
            [self.captureSession removeOutput:self.stillImageOutput];
            self.stillImageOutput = nil;
        }
        
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        // Create and configure device output
        self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        dispatch_queue_t captureQueue = dispatch_queue_create("com.antbeta.AVCameraCaptureQueue", DISPATCH_QUEUE_SERIAL);
        [self.videoOutput setSampleBufferDelegate:self queue:captureQueue];
        self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
        self.videoOutput.minFrameDuration = CMTimeMake(1, 30);
        
        // For color mode, BGRA format is used
        OSType format = kCVPixelFormatType_32BGRA;
        self.videoOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:format]
                                                                 forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        
        // Connect up inputs and outputs
        if ([self.captureSession canAddOutput:self.videoOutput]) {
            [self.captureSession addOutput:self.videoOutput];
        }
        
        if ([self.captureSession canAddOutput:self.stillImageOutput]) {
            [self.captureSession addOutput:self.stillImageOutput];
        }
        
        [self.captureSession commitConfiguration];
    }
}


@end
