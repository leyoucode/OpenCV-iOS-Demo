//
//  CXVideoPlayView.h
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol VideoSomeDelegate <NSObject>

@required

- (void)flushCurrentTime:(NSString *)timeString sliderValue:(float)sliderValue;

//- (void)flushVideoLength:(float)videoLength;

@end

@interface CXVideoPlayView : UIView

@property (nonatomic ,strong) NSString *playerUrl;

@property (nonatomic ,readonly) AVPlayerItem *item;

@property (nonatomic ,readonly) AVPlayerLayer *playerLayer;

@property (nonatomic ,readonly) AVPlayer *player;

@property (nonatomic ,weak) id <VideoSomeDelegate> someDelegate;

- (id)initWithUrl:(NSString *)path delegate:(id<VideoSomeDelegate>)delegate;

- (void)seekValue:(float)value;

- (void)stop;

@end

@interface CXVideoPlayView  (Guester)

- (void)addSwipeView;

@end
