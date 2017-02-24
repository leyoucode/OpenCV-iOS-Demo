//
//  CXImagePreviewViewController.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXImagePreviewViewController.h"
#import "CXMarcos.h"
#import "CXFileUtils.h"

@interface CXImagePreviewViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong) UIScrollView* mainScrollView;

@property(nonatomic,strong) UIImageView* mainImageView;

@property(nonatomic,strong) UIButton* cancelButton;

@property(nonatomic,strong) UIButton* confirmButton;

@end

@implementation CXImagePreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mainScrollView = [[UIScrollView alloc]init];
    self.mainScrollView.backgroundColor = [UIColor darkGrayColor];
    self.mainScrollView.delegate = self;
    
    self.mainScrollView.userInteractionEnabled = YES;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.scrollsToTop = NO;
    self.mainScrollView.scrollEnabled = YES;
    self.mainScrollView.alwaysBounceHorizontal = YES;
    self.mainScrollView.alwaysBounceVertical = YES;
    self.mainScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.mainScrollView];
    
    // Creates a view Dictionary to be used in constraints
    NSDictionary *viewsDictionary;
    
    // Creates an image view with a test image
    self.mainImageView = [[UIImageView alloc] init];
    UIImage *turnImage = [UIImage imageWithContentsOfFile:_imagePath];
    [self.mainImageView setImage:turnImage];
    [self.mainScrollView addSubview:self.mainImageView];
    
    // Add the imageview to the scrollview
    [self.mainScrollView addSubview:self.mainImageView];
    
    // Sets the following flag so that auto layout is used correctly
    self.mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Sets the scrollview delegate as self
    self.mainScrollView.delegate = self;
    
    // Creates references to the views
    UIScrollView *scrollView = self.mainScrollView;
    
    // Sets the image frame as the image size
    self.mainImageView.frame = CGRectMake(0, 0, turnImage.size.width, turnImage.size.height);
    
    // Tell the scroll view the size of the contents
    self.mainScrollView.contentSize = turnImage.size;
    
    // Set the constraints for the scroll view
    viewsDictionary = NSDictionaryOfVariableBindings(scrollView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]-(50)-|" options:0 metrics: 0 views:viewsDictionary]];
    
    // Add doubleTap recognizer to the scrollView
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.mainScrollView addGestureRecognizer:doubleTapRecognizer];
    
    // Add two finger recognizer to the scrollView
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    [self.mainScrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setTitle:@"重拍" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.confirmButton];
    
    NSDictionary *cancelDic = NSDictionaryOfVariableBindings(_cancelButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_cancelButton(==60)]" options:0 metrics:nil views:cancelDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_cancelButton(==40)]-5-|" options:0 metrics:nil views:cancelDic]];
    
    NSDictionary *confirmDic = NSDictionaryOfVariableBindings(_confirmButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_confirmButton(==60)]-10-|" options:0 metrics:nil views:confirmDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_confirmButton(==40)]-5-|" options:0 metrics:nil views:confirmDic]];
    
    [self.cancelButton addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Setup the scrollview scales on viewWillAppear
    [self setupScales];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)onButtonClick:(UIButton*)sender
{
    if (self.cancelButton == sender)
    {
        [CXFileUtils deleteFileWithFilePath:self.imagePath];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (self.confirmButton == sender)
    {
        [UIApplication sharedApplication].statusBarHidden = self.statusBarHidden;
        [UIApplication sharedApplication].statusBarStyle = self.statusBarStyle;
        self.cameraCaptureResult(self.cameraMediaType, self.imagePath);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark - Scroll View scales setup and center

-(void)setupScales {
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = self.mainScrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.mainScrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.mainScrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    self.mainScrollView.minimumZoomScale = minScale;
    self.mainScrollView.maximumZoomScale = 1.0f;
    self.mainScrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    
    CGSize imgViewSize = self.mainImageView.frame.size;
    CGSize imageSize = self.mainImageView.image.size;
    
    CGSize realImgSize;
    if(imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height) {
        realImgSize = CGSizeMake(imgViewSize.width, imgViewSize.width / imageSize.width * imageSize.height);
    }
    else {
        realImgSize = CGSizeMake(imgViewSize.height / imageSize.height * imageSize.width, imgViewSize.height);
    }
    
    CGRect fr = CGRectMake(0, 0, 0, 0);
    fr.size = realImgSize;
    self.mainImageView.frame = fr;
    
    CGSize scrSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 50);//self.mainScrollView.frame.size;
    float offx = (scrSize.width > realImgSize.width ? (scrSize.width - realImgSize.width) / 2 : 0);
    float offy = (scrSize.height > realImgSize.height ? (scrSize.height - realImgSize.height) / 2 : 0);
    
    // don't animate the change.
    self.mainScrollView.contentInset = UIEdgeInsetsMake(offy, offx, offy, offx);
}

#pragma mark -
#pragma mark - ScrollView Delegate methods
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.mainImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

#pragma mark -
#pragma mark - ScrollView gesture methods
- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // Get the location within the image view where we tapped
    CGPoint pointInView = [recognizer locationInView:self.mainImageView];
    
    // Get a zoom scale that's zoomed in slightly, capped at the maximum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.mainScrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.mainScrollView.maximumZoomScale);
    
    // Figure out the rect we want to zoom to, then zoom to it
    CGSize scrollViewSize = self.mainScrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    [self.mainScrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    // Zoom out slightly, capping at the minimum zoom scale specified by the scroll view
    CGFloat newZoomScale = self.mainScrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.mainScrollView.minimumZoomScale);
    [self.mainScrollView setZoomScale:newZoomScale animated:YES];
}

#pragma mark -
#pragma mark - Rotation

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // When the orientation is changed the contentSize is reset when the frame changes. Setting this back to the relevant image size
    self.mainScrollView.contentSize = self.mainImageView.image.size;
    // Reset the scales depending on the change of values
    [self setupScales];
}

@end
