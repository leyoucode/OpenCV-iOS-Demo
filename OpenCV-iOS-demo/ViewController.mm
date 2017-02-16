//
//  ViewController.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 12/01/2017.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "ViewController.h"
#import "OpenCVWrapper.h"
#import "CannyEdgeDetectingViewController.h"
#import "HoughLineEdgeDetectingViewController.h"

#import "CXCameraViewController.h"


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
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self withType:kCameraMediaTypeVideo result:^(id responseObject) {
        
    }];
}

- (IBAction)takeNormalPhoto:(id)sender {
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self withType:kCameraMediaTypePhoto result:^(id responseObject) {
        
    }];
}

- (IBAction)takeDocumentPhoto:(id)sender {
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self withType:kCameraMediaTypeDocument result:^(id responseObject) {
        
    }];
}

- (IBAction)defaultTest:(id)sender {
    CXCameraViewController *controller = [[CXCameraViewController alloc] init];
    [controller showIn:self result:^(id responseObject) {
        
    }];
}


//- (IBAction)OnHoughLineEdgeDetectButtonClick:(id)sender
//{
//    HoughLineEdgeDetectingViewController* controller = [[HoughLineEdgeDetectingViewController alloc] init];
//    [self presentViewController:controller animated:YES completion:nil];
//}

@end
