//
//  YZVideoShow.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoShow.h"
#import "YZVideoDevice.h"
#import "YZVideoOptions.h"
#import "YZVideoNV12Filter.h"
#import "YZVideoI420Filter.h"
#import "YZVideoTextureFilter.h"
#import "YZVideoBGRAPlayer.h"

@interface YZVideoShow ()
@property (nonatomic, strong) YZVideoDevice *device;
@property (nonatomic, strong) YZVideoOptions *options;
@property (nonatomic, strong) YZVideoFilter *filter;
@property (nonatomic, strong) YZVideoPlayer *player;
@end

@implementation YZVideoShow
+ (BOOL)YZDeviceSupport {
    return [YZVideoDevice isDeviceSupport];
}

- (instancetype)initWithOptions:(YZVideoOptions *)options
{
    self = [super init];
    if (self) {
        _options = options;
        _device = [[YZVideoDevice alloc] initWithFormat:options.format];
        switch (options.format) {
            case YZVideoFormat32BGRA:
                _filter = [[YZVideoTextureFilter alloc] init];
                break;
            case YZVideoFormatI420:
                _filter = [[YZVideoI420Filter alloc] init];
                break;
            case YZVideoFormatNV12:
                _filter = [[YZVideoNV12Filter alloc] init];
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)setVideoShowView:(UIView *)view {
    [YZVideoShow syncMainThread:^{
        if (self.player.superview) {
            [self.player removeFromSuperview];
        }
        
        if (view) {
            [view addSubview:self.player];
            self.player.frame = view.bounds;
            self.filter.player = self.player;
        } else {
            self.filter.player = nil;
        }
    }];
}

- (void)displayVideo:(YZVideoData *)videoData {
    [_filter displayVideo:videoData];
}

#pragma mark - lazy var
- (YZVideoPlayer *)player {
    if (!_player) {
        _player = [[YZVideoBGRAPlayer alloc] initWithDevice:_device];
        _player.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _player;
}

#pragma mark - helper
+ (void)syncMainThread:(void(^)(void))block {
    if (NSThread.isMainThread) {
        if (block) {
            block();
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
@end
