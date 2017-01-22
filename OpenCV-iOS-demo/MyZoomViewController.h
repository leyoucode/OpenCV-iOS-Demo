//
//  MyZoomViewController.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 22/01/2017.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyZoomViewController : UIViewController

@property(nonatomic,strong) NSString* imagePath;

@property(nonatomic,strong) UIScrollView* srcollView;

@property(nonatomic,strong) UIImageView* imageView;

@end
