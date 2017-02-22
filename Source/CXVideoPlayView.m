//
//  CXVideoPlayView.m
//  OpenCV-iOS-demo
//
//  Created by 刘伟 on 2/21/17.
//  Copyright © 2017 上海凌晋信息技术有限公司. All rights reserved.
//

#import "CXVideoPlayView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPVolumeView.h>

typedef enum  {
    ChangeNone,
    ChangeVoice
}Change;

@interface CXVideoPlayView ()

@property (nonatomic ,readwrite) AVPlayerItem *item;

@property (nonatomic ,readwrite) AVPlayerLayer *playerLayer;

@property (nonatomic ,readwrite) AVPlayer *player;

@property (nonatomic ,strong)  id timeObser;

@property (nonatomic ,assign) float videoLength;

@property (nonatomic ,assign) Change changeKind;

@property (nonatomic ,assign) CGPoint lastPoint;

@property (nonatomic, assign) BOOL shouldFlushSlider;

//Gesture
@property (nonatomic ,strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic ,strong) MPVolumeView *volumeView;
@property (nonatomic ,weak) UISlider *volumeSlider;

@end

@implementation CXVideoPlayView

- (id)initWithUrl:(NSURL *)url delegate:(id<VideoSomeDelegate>)delegate {
    if (self = [super init]) {
        _playerUrl = url;
        _someDelegate = delegate;
        [self setBackgroundColor:[UIColor blackColor]];
        [self setUpAVPlayer];
        [self addSwipeGesture];
    }
    return self;
}

- (void)setUpAVPlayer {
    _item = [[AVPlayerItem alloc] initWithURL:_playerUrl];
    _player = [AVPlayer playerWithPlayerItem:_item];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:_playerLayer];
    
    [self addVideoKVO];
    [self addVideoTimerObserver];
    [self addVideoNotic];
}

- (void)tearDownAVPlayer
{
    [self removeVideoTimerObserver];
    [self removeVideoNotic];
    [self removeVideoKVO];

    [_player pause];
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
    [_player replaceCurrentItemWithPlayerItem:nil];
    _player = nil;
    _item = nil;
}

- (void)seekValue:(float)value {
    
    _shouldFlushSlider = NO;
    
    float toBeTime = value *_videoLength;
    
    [_player seekToTime:CMTimeMake(toBeTime, 1) completionHandler:^(BOOL finished) {
        
        NSLog(@"seek Over finished:%@",finished ? @"success ":@"fail");
        
        _shouldFlushSlider = finished;
        
    }];
}

#pragma mark - KVO
- (void)addVideoKVO
{
    //KVO
    [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeVideoKVO {
    [_item removeObserver:self forKeyPath:@"status"];
    [_player removeObserver:self forKeyPath:@"rate"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = _item.status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                
                if ([self.someDelegate respondsToSelector:@selector(videoDidPlaying)]) {
                    [self.someDelegate videoDidPlaying];
                }
                
                [_player play];
                _shouldFlushSlider = YES;
                _videoLength = floor(_item.asset.duration.value * 1.0/ _item.asset.duration.timescale);
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"AVPlayerItemStatusUnknown");
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                NSLog(@"AVPlayerItemStatusFailed");
                NSLog(@"%@",_item.error);
                
                if ([self.someDelegate respondsToSelector:@selector(videoDidError:)]) {
                    [self.someDelegate videoDidError:_item.error];
                }
            }
                break;
                
            default:
                break;
        }
    }
    else if ([keyPath isEqualToString:@"rate"])
    {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        if (rate == 0.0) {
            //
            NSLog(@"Playback stopped");
            
            if ([self.someDelegate respondsToSelector:@selector(videoDidPause)]) {
                [self.someDelegate videoDidPause];
            }
            
        } else if (rate == 1.0) {
            //
            NSLog(@"Normal playback");
            if ([self.someDelegate respondsToSelector:@selector(videoDidPlaying)]) {
                [self.someDelegate videoDidPlaying];
            }
        } else if (rate == -1.0) {
            //
            NSLog(@"Reverse playback");
            
        }
    }
}
#pragma mark - Notic
- (void)addVideoNotic
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
- (void)removeVideoNotic {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)movieToEnd:(NSNotification *)notic {
    NSLog(@"movieToEnd:%@",NSStringFromSelector(_cmd));
    if ([self.someDelegate respondsToSelector:@selector(videoDidEnd)]) {
        [self.someDelegate videoDidEnd];
    }
}

#pragma mark - TimerObserver
- (void)addVideoTimerObserver {
    __weak typeof (self)weakSelf = self;
    _timeObser = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        float currentTimeValue = time.value*1.0/time.timescale/weakSelf.videoLength;
        NSString *currentString = [weakSelf getStringFromCMTime:time];
        
        if ([weakSelf.someDelegate respondsToSelector:@selector(flushCurrentTime:sliderValue:)] && _shouldFlushSlider) {
            [weakSelf.someDelegate flushCurrentTime:currentString sliderValue:currentTimeValue];
        } else {
            NSLog(@"no response");
        }
    }];
}
- (void)removeVideoTimerObserver {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [_player removeTimeObserver:_timeObser];
    _timeObser =  nil;
}


#pragma mark - Utils
- (NSString *)getStringFromCMTime:(CMTime)time
{
    float currentTimeValue = (CGFloat)time.value/time.timescale;//得到当前的播放时
    
    NSDate * currentDate = [NSDate dateWithTimeIntervalSince1970:currentTimeValue];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
    NSDateComponents *components = [calendar components:unitFlags fromDate:currentDate];
    
    if (currentTimeValue >= 3600 )
    {
        return [NSString stringWithFormat:@"%.2d:%.2d:%.2d",components.hour,components.minute,components.second];
    }
    else
    {
        return [NSString stringWithFormat:@"%.2d:%.2d",components.minute,components.second];
    }
}

- (NSString *)getVideoLengthFromTimeLength:(float)timeLength
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:timeLength];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ;
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    if (timeLength >= 3600 )
    {
        return [NSString stringWithFormat:@"%d:%d:%d",components.hour,components.minute,components.second];
    }
    else
    {
        return [NSString stringWithFormat:@"%d:%d",components.minute,components.second];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
}

#pragma mark - release
- (void)dealloc {
    NSLog(@"dealloc %@",NSStringFromSelector(_cmd));
    [self removeVideoTimerObserver];
    [self removeVideoNotic];
    [self removeVideoKVO];
}

@end

#pragma mark - CXVideoPlayView (Guester)

@implementation CXVideoPlayView (Guester)

- (void)addSwipeGesture
{
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    [self addGestureRecognizer:_panGesture];
}

- (void)swipeAction:(UISwipeGestureRecognizer *)gesture {
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            _changeKind = ChangeNone;
            _lastPoint = [gesture locationInView:self];
        }
            break;
        case  UIGestureRecognizerStateChanged:
        {
            [self getChangeKindValue:[gesture locationInView:self]];
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            _changeKind = ChangeNone;
            _lastPoint = CGPointZero;
        }
        default:
            break;
    }
    
}
- (void)getChangeKindValue:(CGPoint)pointNow {
    
    switch (_changeKind) {
            
        case ChangeNone:
        {
            [self changeForNone:pointNow];
        }
            break;
        case ChangeVoice:
        {
            [self changeForVoice:pointNow];
        }
            break;
            
        default:
            break;
    }
}
- (void)changeForNone:(CGPoint) pointNow {
    
    if (fabs(pointNow.x - _lastPoint.x) > fabs(pointNow.y - _lastPoint.y)) {
        
    } else {
        float halfWight = self.bounds.size.width / 2;
        if (_lastPoint.x < halfWight) {
            
        } else {
            _changeKind =   ChangeVoice;
        }
        _lastPoint = pointNow;
    }
}



#pragma mark - increase or reduce volume of the video

- (void)changeForVoice:(CGPoint)pointNow {
    float number = fabs(pointNow.y - _lastPoint.y);
    if (pointNow.y > _lastPoint.y && number > 10) {
        _lastPoint = pointNow;
        [self minVolume];
    } else if (pointNow.y < _lastPoint.y && number > 10) {
        _lastPoint = pointNow;
        [self upperVolume];
    }
}

- (void)upperVolume {
    if (self.volumeSlider.value <= 1.0) {
        self.volumeSlider.value =  self.volumeSlider.value + 0.1 ;
    }
    
}
- (void)minVolume {
    if (self.volumeSlider.value >= 0.0) {
        self.volumeSlider.value =  self.volumeSlider.value - 0.1 ;
    }
}

- (MPVolumeView *)volumeView {
    
    if (_volumeView == nil) {
        _volumeView = [[MPVolumeView alloc] init];
        _volumeView.hidden = YES;
        [self addSubview:_volumeView];
    }
    return _volumeView;
}

- (UISlider *)volumeSlider {
    if (_volumeSlider== nil) {
        NSLog(@"%@",[self.volumeView subviews]);
        for (UIView  *subView in [self.volumeView subviews]) {
            if ([subView.class.description isEqualToString:@"MPVolumeSlider"]) {
                _volumeSlider = (UISlider*)subView;
                break;
            }
        }
    }
    return _volumeSlider;
}

@end
