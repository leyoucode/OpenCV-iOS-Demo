//
//  CXFileUtils.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/23/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CXCameraMediaType.h"

@interface CXFileUtils : NSObject

// 根据路径创建文件
+(bool) deleteFileWithFilePath:(NSString *)filePath;

// 判断文件是否存在
+ (BOOL) isExistsFilePath:(NSString *)filePath;

/**
 *  创建目录
 */
+(BOOL)createDirectory:(NSString *)directory;

+(NSString*) getMediaObjectPathWithType:(CXCameraMediaType) type;

@end
