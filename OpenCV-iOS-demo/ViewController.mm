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

#import <AVFoundation/AVFoundation.h>

#import <CommonCrypto/CommonDigest.h>
#import "CXImagePreviewViewController.h"

@interface ViewController ()

{
    IBOutlet UILabel* openCVVersionLabel;
    IBOutlet UIImageView* imageView;
    IBOutlet UIButton* button;
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    openCVVersionLabel.text = [OpenCVWrapper openCVVersionString];
    [self.navigationController setNavigationBarHidden:YES];
}
#pragma mark - UI Actions

- (IBAction)recordVedio:(id)sender {
    __weak typeof(self) weakSelf = self;
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self withType:kCameraMediaTypeVideo result:^(CXCameraMediaType type, NSString* filePath) {
        [weakSelf showResultWithType:type andObject:filePath];
    }];
}

- (IBAction)takeNormalPhoto:(id)sender {
    __weak typeof(self) weakSelf = self;
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self withType:kCameraMediaTypePhoto result:^(CXCameraMediaType type, NSString* filePath) {
        [weakSelf showResultWithType:type andObject:filePath];
    }];
}

- (IBAction)takeDocumentPhoto:(id)sender {
    __weak typeof(self) weakSelf = self;
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self withType:kCameraMediaTypeDocument result:^(CXCameraMediaType type, NSString* filePath) {
        [weakSelf showResultWithType:type andObject:filePath];
    }];
}

- (IBAction)defaultTest:(id)sender {
    __weak typeof(self) weakSelf = self;
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self result:^(CXCameraMediaType type, NSString* filePath) {
        [weakSelf showResultWithType:type andObject:filePath];
    }];
}

- (void)showResultWithType:(CXCameraMediaType)type andObject:(NSString*) filePath
{
    switch (type) {
        case kCameraMediaTypeVideo:
        {
            NSLog(@"Vedio:%@",filePath);
            break;
        }
        case kCameraMediaTypePhoto:
        {
            NSLog(@"Photo:%@",filePath);
            break;
        }
        case kCameraMediaTypeDocument:
        {
            NSLog(@"Document:%@",filePath);
            break;
        }
        default:
            break;
    }
}

@end
