//
//  CXVideoCaptureViewController.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 12/01/2017.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraMediaType.h"

@interface CXVideoCaptureViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, assign) CameraMediaType cameraMediaType;

@property (nonatomic, strong)  NSString * qualityPreset;

@property (nonatomic, assign) BOOL torchOn;

// AVFoundation components
@property (nonatomic, readonly) AVCaptureSession *captureSession;
@property (nonatomic, readonly) AVCaptureDevice *captureDevice;
@property (nonatomic, readonly) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, readonly) AVCaptureAudioDataOutput *audioDataOutput;
@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

@property (nonatomic, readonly) AVCaptureConnection *captureConnection;
@property (nonatomic, readonly) AVAssetWriter *assetWriter;
@property (nonatomic, readonly) AVAssetWriterInput *assetWriterInput;


// -1: default, 0: back camera, 1: front camera
@property (nonatomic, assign) int camera;

// These should only be modified in the initializer
@property (nonatomic, assign) BOOL captureGrayscale;

- (CGAffineTransform)affineTransformForVideoFrame:(CGRect)videoFrame orientation:(AVCaptureVideoOrientation)videoOrientation;

@end
