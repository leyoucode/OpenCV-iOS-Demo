//
//  CXVideoCaptureView.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXVideoCaptureView.h"
#import "UIView+Ext.h"
#import "UIImage+utils.h"

@implementation CXVideoCaptureView

#pragma mark - Views

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

#pragma mark - 初始化页面
- (void)initVideoView
{
    //self.translatesAutoresizingMaskIntoConstraints = NO;
    self.userInteractionEnabled = YES;
    
    [self addSubview:self.topContentView];
    self.topContentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    
    [self.topContentView addSubview:self.torchButton];
    self.torchButton.frame = CGRectMake(0, 0, VIEW_HEIGHT(self.topContentView), VIEW_HEIGHT(self.topContentView));
    
    [self.topContentView addSubview:self.cameraButton];
    self.cameraButton.frame = CGRectMake(0, 0, VIEW_HEIGHT(self.topContentView), VIEW_HEIGHT(self.topContentView));
    [self.cameraButton modifyX:SCREEN_WIDTH - VIEW_WIDTH(self.cameraButton)];
    
    [self.topContentView addSubview:self.recordDurationLabel];
    self.recordDurationLabel.frame = CGRectMake(VIEW_WIDTH(self.torchButton), 0, (SCREEN_WIDTH - VIEW_WIDTH(self.torchButton) - VIEW_WIDTH(self.cameraButton)), VIEW_HEIGHT(self.topContentView));
    
    self.bottomContentView.frame = CGRectMake(0, SCREEN_HEIGHT - 120, SCREEN_WIDTH, 120);
    [self addSubview:self.bottomContentView];
    
    [self addSubview:self.takeButton];
    [self.takeButton modifySize:CGSizeMake(57, 57)];
    [self.takeButton modifyCenterX:self.bottomContentView.center.x];
    [self.takeButton modifyCenterY:self.bottomContentView.center.y + 10];
    [self.takeButton modifyY:VIEW_TOP(self.takeButton) + 10];
    
    [self addSubview:self.cancelButton];
    [self.cancelButton modifyX:10];
    [self.cancelButton modifySize:CGSizeMake(50, 40)];
    [self.cancelButton modifyCenterY:self.takeButton.center.y];
    
    
    [self.bottomContentView addSubview:self.videoTabButton];
    [self.bottomContentView addSubview:self.photoTabButton];
    [self.bottomContentView addSubview:self.documentTabButton];
    
}

#pragma mark ---------------------System---------------------
#pragma mark 初始化
- (id)initWithFrame:(CGRect)frame andCameraMediaType:(CameraMediaType)type
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _cameraMediaType = type;
        
        //初始化页面
        [self initVideoView];
        [self setupTabWithAnimated:NO];
        [self setSwipe];
        [self setClick];
    }
    return self;
}

#pragma mark - 

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
    
    self.cameraButton.hidden = false;
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
    
    self.cameraButton.hidden = false;
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
    
    self.cameraButton.hidden = true;
}

#pragma mark - Swipe Gesture

- (void) setSwipe
{
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self addGestureRecognizer:swipeRight];
    [self addGestureRecognizer:swipeLeft];
}

-(void)handleSwipeRight:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        //NSLog(@"right %f, %f, %f",self.photoTabButton.center.x, self.videoTabButton.center.x, self.bottomContentView.center.x);
        if (self.photoTabButton.center.x == self.bottomContentView.center.x) {
            _cameraMediaType = kCameraMediaTypeVideo;
            [self makeAnimation];
            [self setupTabWithAnimated:YES];
            if (_delegate && [_delegate respondsToSelector:@selector(onViewChanged:)]) {
                [_delegate onViewChanged:_cameraMediaType];
            }
        }else if (self.documentTabButton.center.x == self.bottomContentView.center.x) {
            _cameraMediaType = kCameraMediaTypePhoto;
            [self makeAnimation];
            [self setupTabWithAnimated:YES];
            if (_delegate && [_delegate respondsToSelector:@selector(onViewChanged:)]) {
                [_delegate onViewChanged:_cameraMediaType];
            }
        }
    }
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if (self.videoTabButton.center.x == self.bottomContentView.center.x) {
            _cameraMediaType = kCameraMediaTypePhoto;
            [self makeAnimation];
            [self setupTabWithAnimated:YES];
            if (_delegate && [_delegate respondsToSelector:@selector(onViewChanged:)]) {
                [_delegate onViewChanged:_cameraMediaType];
            }
        }
        else if (self.photoTabButton.center.x == self.bottomContentView.center.x) {
            _cameraMediaType = kCameraMediaTypeDocument;
            [self makeAnimation];
            [self setupTabWithAnimated:YES];
            if (_delegate && [_delegate respondsToSelector:@selector(onViewChanged:)]) {
                [_delegate onViewChanged:_cameraMediaType];
            }
        }
    }
}

- (void)makeAnimation
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage createImageWithColor:[UIColor grayColor]]];
    imageView.frame = self.frame;
    [self insertSubview:imageView belowSubview:self.topContentView];
    
    [UIView animateWithDuration:0.8 animations:^{
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}

#pragma mark - Click Control

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
        if (_delegate && [_delegate respondsToSelector:@selector(onCancelButtonClick)]) {
            [_delegate onCancelButtonClick];
        }
    }
    // 点击闪光灯按钮
    if (sender == self.torchButton) {
        if (_delegate && [_delegate respondsToSelector:@selector(onTorchButtonClick)]) {
            [_delegate onTorchButtonClick];
        }
    }
    // 点击相机切换按钮
    if (sender == self.cameraButton) {
        if (_delegate && [_delegate respondsToSelector:@selector(onCameraButtonClick)]) {
            [_delegate onCameraButtonClick];
        }
    }
    // 点击拍照／录制按钮
    if (sender == self.takeButton) {
        switch (self.cameraMediaType) {
            case kCameraMediaTypeVideo:// 录制视频
                if (self.takeButton.tag == 0) {
                    // 开始录制
                    if (_delegate && [_delegate respondsToSelector:@selector(onVideoCaptureStartButtonClick)]) {
                        [_delegate onVideoCaptureStartButtonClick];
                    }
                }else{
                    // 结束录制
                    if (_delegate && [_delegate respondsToSelector:@selector(onVideoCaptureStopButtonClick)]) {
                        [_delegate onVideoCaptureStopButtonClick];
                    }
                }
                break;
            case kCameraMediaTypePhoto:// 拍照
                if (_delegate && [_delegate respondsToSelector:@selector(onCaptureImageButtonCick)]) {
                    [_delegate onCaptureImageButtonCick];
                }
                break;
            case kCameraMediaTypeDocument:// 拍摄文档
                if (_delegate && [_delegate respondsToSelector:@selector(onCaptureDocumentButtonCick)]) {
                    [_delegate onCaptureDocumentButtonCick];
                }
                break;
            default:
                break;
        }
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"Recording is started ...");
    // Hide some control elements
    self.takeButton.tag = 1;
    [self.takeButton setImage:[UIImage imageNamed:@"record_ing"] forState:UIControlStateNormal];
    self.bottomContentView.hidden = YES;
    self.cameraButton.hidden = YES;
    self.cancelButton.hidden = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didStartVideoRecording)]) {
        [_delegate didStartVideoRecording];
    }
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"Recording is stoped ...");
    // Recover control elements' state those be hiddened before
    self.takeButton.tag = 0;
    [self.takeButton setImage:[UIImage imageNamed:@"record_idle"] forState:UIControlStateNormal];
    self.bottomContentView.hidden = NO;
    self.cameraButton.hidden = NO;
    self.cancelButton.hidden = NO;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didStopVideoRecording:)]) {
        [_delegate didStopVideoRecording:outputFileURL.path];
    }
}


@end
