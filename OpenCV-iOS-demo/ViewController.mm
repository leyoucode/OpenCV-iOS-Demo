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

}

#pragma mark - UI Actions
- (IBAction)OnCannyEdgeDetectButtonClick:(id)sender
{
    CannyEdgeDetectingViewController* controller = [[CannyEdgeDetectingViewController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)OnHoughLineEdgeDetectButtonClick:(id)sender
{
    HoughLineEdgeDetectingViewController* controller = [[HoughLineEdgeDetectingViewController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
