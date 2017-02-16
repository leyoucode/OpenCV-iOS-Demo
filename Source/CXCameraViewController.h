//
//  CXCameraViewController.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/16/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraMediaType.h"

typedef void (^CXCameraResult)(id responseObject);

@interface CXCameraViewController : NSObject

-(void)showIn:(UIViewController *)controller result:(CXCameraResult)result;

-(void)showIn:(UIViewController *)controller withType:(CameraMediaType)cameraMediaType result:(CXCameraResult)result;

@end
