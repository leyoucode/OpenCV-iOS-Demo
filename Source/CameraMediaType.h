//
//  CameraMediaType.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/16/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#ifndef CameraMediaType_h
#define CameraMediaType_h

typedef enum :NSInteger {
    kCameraMediaTypeVideo, // 视频模式
    kCameraMediaTypePhoto, // 拍照模式
    kCameraMediaTypeDocument // 拍文档模式
} CameraMediaType;

typedef void (^CXCameraResult)(id responseObject);

#endif /* CameraMediaType_h */
