//
//  CXVideoCaptureView.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraMediaType.h"
#import <AVFoundation/AVFoundation.h>

@protocol CXVideoCaptureViewDelegate<NSObject>

// It will be triggered when you switch the Tabs by swipe view to right or left with your finger
-(void) onViewChanged:(CameraMediaType)type;

/* The follow events will be triggered when you click relative Buttons */
-(void) onCancelButtonClick;
-(void) onTorchButtonClick;
-(void) onCameraButtonClick;
-(void) onVideoCaptureStartButtonClick;
-(void) onVideoCaptureStopButtonClick;
-(void) onCaptureImageButtonCick;
-(void) onCaptureDocumentButtonCick;

-(void) didStartVideoRecording;
-(void) didStopVideoRecording:(NSString*)videoPath;

@end

@interface CXVideoCaptureView : UIView<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, assign, readonly) CameraMediaType cameraMediaType;

@property (nonatomic, assign) id<CXVideoCaptureViewDelegate> delegate;

#pragma mark - View Elements
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

#pragma maek - Initialization
- (id)initWithFrame:(CGRect)frame andCameraMediaType:(CameraMediaType)type;

@end
