//
//  CXVideoPreviewViewController.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXVideoPreviewViewController.h"
#import "CXVideoPlayView.h"
#import "CXMarcos.h"
#import "CXImageUtils.h"
#import "CXFileUtils.h"

@interface CXVideoPreviewViewController ()<VideoSomeDelegate>

@property (nonatomic ,strong) CXVideoPlayView *videoView;

@property (nonatomic ,strong) NSMutableArray<NSLayoutConstraint *> *array;

@property (nonatomic ,strong) UISlider *videoSlider;

@property(nonatomic,strong) UIView* bottomView;

@property(nonatomic,strong) UIButton* cancelButton;

@property(nonatomic,strong) UIButton* confirmButton;

@property(nonatomic,strong) UIButton* playOrPauseButton;

@property (nonatomic ,strong) NSMutableArray<NSLayoutConstraint *> *sliderArray;

@end

@implementation CXVideoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initVideoView];
}

- (void)initVideoView {
    
    //NSString *path = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
    //self.videoPath = @"http://bly-video-in.oss-cn-hangzhou.aliyuncs.com/test/2017/02/1c58e5e94048e8de7f110b62056e9339.mov?Expires=1487760713&OSSAccessKeyId=TMP.AQHbN_CDZS4VlQFHUkp0pqwgC5t-5sT7sKdL8NNjEk81nb1gcKWnTl1lEb_KMC4CFQCvnB6KC5tNQnsyCCRxYVc3GnH7YAIVAKRl3tpQZMszNzERtlfd1cICYz-q&Signature=NWFGmoVDNIGKMbD29NQWPqBWMJY%3D";
    //self.videoPath = [self.videoPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    @autoreleasepool
    {
        _videoView = [[CXVideoPlayView alloc] initWithUrl:self.videoUrl delegate:self];
        _videoView.someDelegate = self;
        [_videoView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:_videoView];
    }
    
    [self initVideoSlider];
    
    if (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        //[self installLandspace];
    } else {
        [self installVertical];
    }
}
- (void)installVertical {
    if (_array != nil) {
        [self.view removeConstraints:_array];
        [_array removeAllObjects];
        [self.view removeConstraints:_sliderArray];
        [_sliderArray removeAllObjects];
    } else {
        _array = [NSMutableArray array];
        _sliderArray = [NSMutableArray array];
    }
    //id topGuide = self.topLayoutGuide;
    //NSDictionary *dic = @{@"top":@100,@"height":@180,@"edge":@20,@"space":@80};
   
    [_array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_videoView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_videoView)]];
    [_array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_videoView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_videoView)]];
    
    [_array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20)-[_videoSlider]-(20)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_videoSlider)]];
    [_array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[_videoSlider]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_videoSlider)]];
    
    //[_array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide]-(top)-[_videoView(==height)]-(space)-[_videoSlider]" options:0 metrics:dic views:NSDictionaryOfVariableBindings(_videoView,topGuide,_videoSlider)]];
    
    [self.view addConstraints:_array];
    
    
    
}


//- (void)installLandspace {
//    if (_array != nil) {
//        
//        [self.view removeConstraints:_array];
//        [_array removeAllObjects];
//        
//        [self.view removeConstraints:_sliderArray];
//        [_sliderArray removeAllObjects];
//    } else {
//        
//        _array = [NSMutableArray array];
//        _sliderArray = [NSMutableArray array];
//    }
//    
//    id topGuide = self.topLayoutGuide;
//    NSDictionary *dic = @{@"edge":@20,@"space":@30};
//    
//    [_array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_videoView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_videoView)]];
//    [_array addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide][_videoView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_videoView,topGuide)]];
//    [self.view addConstraints:_array];
//    
//    [_sliderArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(edge)-[_videoSlider]-(edge)-|" options:0 metrics:dic views:NSDictionaryOfVariableBindings(_videoSlider)]];
//    [_sliderArray addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_videoSlider]-(space)-|" options:0 metrics:dic views:NSDictionaryOfVariableBindings(_videoSlider)]];
//    [self.view addConstraints:_sliderArray];
//}
- (void)initVideoSlider {
    
    _videoSlider = [[UISlider alloc] init];
    [_videoSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_videoSlider setThumbImage:[CXImageUtils imageNamed:@"sliderButton"] forState:UIControlStateNormal];
    _videoSlider.minimumTrackTintColor = [UIColor orangeColor];
    _videoSlider.maximumTrackTintColor = [UIColor grayColor];
    [_videoSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_videoSlider];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomView.backgroundColor = [UIColor blackColor];
    self.bottomView.alpha = 0.7;
    [self.view addSubview:self.bottomView];
    
    NSDictionary *bottomViewDic = NSDictionaryOfVariableBindings(_bottomView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bottomView(==50)]" options:0 metrics:nil views:bottomViewDic]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_bottomView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[self.playOrPauseButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playOrPauseButton setImage:[CXImageUtils imageNamed:@"video_preview_play"] forState:UIControlStateNormal];
    [self.playOrPauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.confirmButton setTitle:@"使用视频" forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.playOrPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.playOrPauseButton];
    [self.view addSubview:self.confirmButton];
    
    NSDictionary *cancelDic = NSDictionaryOfVariableBindings(_cancelButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_cancelButton(==60)]" options:0 metrics:nil views:cancelDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_cancelButton(==40)]-5-|" options:0 metrics:nil views:cancelDic]];
    
    NSDictionary *ppDic = NSDictionaryOfVariableBindings(_playOrPauseButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_playOrPauseButton(==40)]-5-|" options:0 metrics:nil views:ppDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_playOrPauseButton(60)]" options:0 metrics:nil views:ppDic]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_playOrPauseButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    NSDictionary *confirmDic = NSDictionaryOfVariableBindings(_confirmButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_confirmButton(==80)]-10-|" options:0 metrics:nil views:confirmDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_confirmButton(==40)]-5-|" options:0 metrics:nil views:confirmDic]];
    
    [self.cancelButton addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseButton addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)onButtonClick:(UIButton*)sender
{
    if (self.cancelButton == sender)
    {
        [CXFileUtils deleteFileWithFilePath:[self.videoUrl path]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (self.playOrPauseButton == sender)
    {
        if ([self.videoView.player rate] == 0)
        {
            [self.videoView.player play];
        }else
        {
            [self.videoView.player pause];
        }
    }
    else if (self.confirmButton == sender)
    {
        [UIApplication sharedApplication].statusBarHidden = self.statusBarHidden;
        [UIApplication sharedApplication].statusBarStyle = self.statusBarStyle;
        self.cameraCaptureResult(self.cameraMediaType, [self.videoUrl path]);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        
        if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            //[self installLandspace];
        } else {
            [self installVertical];
        }
        [self.view setNeedsLayout];
    } completion:nil];
    
}

- (void)sliderValueChange:(UISlider *)slider {
    [self.videoView seekValue:slider.value];
}
- (void)dealloc {
    [_videoView tearDownAVPlayer];
    _videoView = nil;
}

#pragma mark -

- (void)flushCurrentTime:(NSString *)timeString sliderValue:(float)sliderValue {
    self.videoSlider.value = sliderValue;
    NSLog(@"timeString:%@",timeString);
}

- (void)videoDidPlaying
{
    //[self.playOrPauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    [self.playOrPauseButton setImage:[CXImageUtils imageNamed:@"video_preview_pause"] forState:UIControlStateNormal];
}

- (void)videoDidPause
{
    //[self.playOrPauseButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playOrPauseButton setImage:[CXImageUtils imageNamed:@"video_preview_play"] forState:UIControlStateNormal];
}

- (void)videoDidEnd
{
//    [self.playOrPauseButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playOrPauseButton setImage:[CXImageUtils imageNamed:@"video_preview_play"] forState:UIControlStateNormal];
    [self.videoView seekValue:0];
    self.videoSlider.value = 0;
}

- (void)videoDidError:(NSError *)error
{
//    [self.playOrPauseButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playOrPauseButton setImage:[CXImageUtils imageNamed:@"video_preview_play"] forState:UIControlStateNormal];
}

@end
