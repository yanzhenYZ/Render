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
#import "YZVideoRangeFilter.h"
#import "YZVideoBGRAPlayer.h"
#import "YZVideoRangePlayer.h"

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
            case YZVideoFormat420YpCbCr8BiPlanarFullRange:
                _filter = [[YZVideoTextureFilter alloc] init];
                break;
            case YZVideoFormat420YpCbCr8BiPlanarVideoRange:
                _filter = [[YZVideoRangeFilter alloc] init];
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
        switch (_options.format) {
            case YZVideoFormat32BGRA:
            case YZVideoFormat420YpCbCr8BiPlanarFullRange:
                _player = [[YZVideoBGRAPlayer alloc] initWithDevice:_device];
                break;
            case YZVideoFormat420YpCbCr8BiPlanarVideoRange:
                _player = [[YZVideoRangePlayer alloc] initWithDevice:_device];
                break;
            case YZVideoFormatI420:
                _player = [[YZVideoBGRAPlayer alloc] initWithDevice:_device];
                break;
            case YZVideoFormatNV12:
                _player = [[YZVideoBGRAPlayer alloc] initWithDevice:_device];
                break;
            default:
                break;
        }
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
