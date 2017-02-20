//
//  ViewController.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 12/01/2017.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "ViewController.h"
#import "OpenCVWrapper.h"

#import "CXCameraViewController.h"

#import <AliyunOSSiOS/OSSService.h>
#import <AVFoundation/AVFoundation.h>

#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()

{
    IBOutlet UILabel* openCVVersionLabel;
    IBOutlet UIImageView* imageView;
    IBOutlet UIButton* button;
    
    OSSClient *client;
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    openCVVersionLabel.text = [OpenCVWrapper openCVVersionString];
    [self.navigationController setNavigationBarHidden:YES];
    
    NSString *endpoint = @"http://oss-cn-hangzhou.aliyuncs.com";
    // 由阿里云颁发的AccessKeyId/AccessKeySecret构造一个CredentialProvider。
    // 明文设置secret的方式建议只在测试时使用，更多鉴权模式请参考后面的访问控制章节。
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:@"rM2FD1CLpUaG6KHg" secretKey:@"j5qq5O2swHXpS31u0NZktPiPv8uOla"];
    
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 3; // 网络请求遇到异常失败后的重试次数
    conf.timeoutIntervalForRequest = 30; // 网络请求的超时时间
    conf.timeoutIntervalForResource = 24 * 60 * 60; // 允许资源传输的最长时间
    
    client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential clientConfiguration:conf];
    
}

- (NSString*) getOSSObjectKey:(NSString*) path
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localDate = [date  dateByAddingTimeInterval: interval];
    
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM"];
    NSArray *year_month = [[dateFormatter stringFromDate:localDate] componentsSeparatedByString:@"-"];
    NSString *md5Name = [self md5HexDigest:path];
    return [NSString stringWithFormat:@"test/%@/%@/%@.mov",year_month[0],year_month[1],md5Name];
}

- (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

- (void)upload:(NSURL*) path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path.path])
    {
        NSLog(@"文件不存在");
        return;
    }
    
    NSString* objectKey = [self getOSSObjectKey:path.path];
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = @"bly-video-in";
    put.objectKey = objectKey;
    put.uploadingFileURL = path;
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    OSSTask * putTask = [client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"upload object success!");
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
}

- (void)compressVideo:(NSURL*)inputURL
            outputURL:(NSURL*)outputURL
              handler:(void (^)(AVAssetExportSession*))completion  {
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        completion(exportSession);
    }];
}

#pragma mark - UI Actions

- (IBAction)recordVedio:(id)sender {
    __weak typeof(self) weakSelf = self;
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self withType:kCameraMediaTypeVideo result:^(id responseObject) {
        
        NSURL* path = (NSURL*)responseObject;
        
        NSLog(@"recordVedio:%@",path);
        
        [weakSelf performSelectorInBackground:@selector(upload:) withObject:path];
//        MPMoviePlayerViewController* playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:path];
//        [weakSelf.navigationController pushViewController:playerView animated:YES];
        
    }];
}

- (IBAction)takeNormalPhoto:(id)sender {
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self withType:kCameraMediaTypePhoto result:^(id responseObject) {
        NSLog(@"takeNormalPhoto:%@",responseObject);
    }];
}

- (IBAction)takeDocumentPhoto:(id)sender {
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self withType:kCameraMediaTypeDocument result:^(id responseObject) {
        NSLog(@"takeDocumentPhoto:%@",responseObject);
    }];
}

- (IBAction)defaultTest:(id)sender {
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self result:^(id responseObject) {
        NSLog(@"defaultTest:%@",responseObject);
    }];
}

@end
