//
//  CXFileUtils.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/23/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXFileUtils.h"

@implementation CXFileUtils

// 根据路径创建文件
+(bool) deleteFileWithFilePath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 如果文件存在, 则删除文件
    if([fileManager fileExistsAtPath:filePath])
    {
        if ([fileManager removeItemAtPath:filePath error:nil]) {
         
            NSLog(@"The file is deleted success: %@",filePath);
            return YES;
        }else{
            NSLog(@"The file is deleted falied: %@",filePath);
        }
    }
    return NO;
}

// 判断文件是否存在
+ (BOOL) isExistsFilePath:(NSString *)filePath
{
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return YES;
    }
    
    return NO;
}

+(BOOL)createDirectory:(NSString *)directory
{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                      stringByAppendingPathComponent:directory];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
        
        BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        return bo;
    }
    return YES;
}

+(NSString*) getMediaObjectPathWithType:(CXCameraMediaType) type
{
    NSString *dirName = @"CXMedias";
    [CXFileUtils createDirectory:dirName];
    NSString *basePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                          stringByAppendingPathComponent:dirName];
    NSString *mediaPath = nil;
    
    switch (type) {
        case kCameraMediaTypeVideo:
            mediaPath = [basePath stringByAppendingPathComponent:
                         [NSString stringWithFormat:@"video_%i.mov",(int)[NSDate date].timeIntervalSince1970]];
            break;
        case kCameraMediaTypePhoto:
            mediaPath = [basePath stringByAppendingPathComponent:
                         [NSString stringWithFormat:@"photo_%i.jpeg",(int)[NSDate date].timeIntervalSince1970]];
            break;
        case kCameraMediaTypeDocument:
            mediaPath = [basePath stringByAppendingPathComponent:
                         [NSString stringWithFormat:@"document_%i.jpeg",(int)[NSDate date].timeIntervalSince1970]];
            break;
            
        default:
            break;
    }
    return mediaPath;
}

@end
