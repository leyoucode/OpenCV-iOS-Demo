//
//  CXCameraViewController.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/16/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXCameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CXVideoCaptureViewController.h"

@interface CXCameraViewController ()

@property(strong,nonatomic) CXVideoCaptureViewController *videoCaptureViewController;

@end

@implementation CXCameraViewController

-(void)showIn:(UIViewController *)controller withType:(CXCameraMediaType)cameraMediaType result:(CXCameraResult)result
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        switch (status)
        {
            case AVAuthorizationStatusNotDetermined:{
                
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (granted) {
                            [self showController:controller withType:cameraMediaType result:result];
                        }else{
                            [self showAlertViewToController:controller];
                        }
                    });
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized:{
                [self showController:controller withType:cameraMediaType result:result];
                break;
            }
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                [self showAlertViewToController:controller];
                break;
            default:
                break;
        }
    }
}

-(void)showIn:(UIViewController *)controller result:(CXCameraResult)result
{
    // 默认拍照模式
    [self showIn:controller withType:kCameraMediaTypePhoto result:result];
}

-(void)showController:(UIViewController *)controller withType:(CXCameraMediaType)cameraMediaType result:(CXCameraResult)result
{
    self.videoCaptureViewController.cameraMediaType = cameraMediaType;
    self.videoCaptureViewController.cameraCaptureResult = result;
    
    UINavigationController* navigationVC = [[UINavigationController alloc] initWithRootViewController:self.videoCaptureViewController];
    navigationVC.navigationBarHidden = YES;
    [controller presentViewController:navigationVC animated:YES completion:nil];
}

-(void)showAlertViewToController:(UIViewController *)controller
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"相机无法访问" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        
    }];
    [alert addAction:action1];
    [controller presentViewController:alert animated:YES completion:nil];
}

-(CXVideoCaptureViewController *) videoCaptureViewController
{
    if (!_videoCaptureViewController) {
        _videoCaptureViewController = [[CXVideoCaptureViewController alloc] init];
    }
    return  _videoCaptureViewController;
}

@end
