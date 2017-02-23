//
//  CXCameraViewController.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/16/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXCameraMediaType.h"

@interface CXCameraViewController : NSObject


/**
 You should delete the file with `filePath` in callback `CXCameraResult`,
 or the file will exists all the time.
 */
-(void)showIn:(UIViewController *)controller result:(CXCameraResult)result;
-(void)showIn:(UIViewController *)controller withType:(CXCameraMediaType)cameraMediaType result:(CXCameraResult)result;

@end
