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

@interface ViewController ()

{
    IBOutlet UILabel* openCVVersionLabel;
    IBOutlet UIImageView* imageView;
    IBOutlet UIButton* button;
}

- (IBAction)actionStart:(id)sender;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    openCVVersionLabel.text = [OpenCVWrapper openCVVersionString];

}

#pragma mark - UI Actions
- (IBAction)actionStart:(id)sender
{
    CannyEdgeDetectingViewController* controller = [[CannyEdgeDetectingViewController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
}


@end
