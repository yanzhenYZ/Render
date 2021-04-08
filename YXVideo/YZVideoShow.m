//
//  YZVideoShow.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/7.
//

#import "YZVideoShow.h"
#import "YZVideoDevice.h"
#import "YZVideoSystemIO.h"
#import "YZVideoMetalIO.h"

@interface YZVideoShow ()
@property (nonatomic, strong) YZVideoDevice *device;
@property (nonatomic, strong) YZVideoIO *videoIO;
@end

@implementation YZVideoShow
+ (BOOL)isSupportAdditionalFeatures {
    return [YZVideoDevice isDeviceSupport];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _device = [[YZVideoDevice alloc] init];
        if ([_device deviceSupport]) {
            _videoIO = [[YZVideoMetalIO alloc] init];
            _videoIO.device = _device;
        } else {
            _videoIO = [[YZVideoSystemIO alloc] init];
            _device = nil;
        }
    }
    return self;
}

- (void)displayVideo:(YZVideoData *)videoData {
    [_videoIO displayVideo:videoData];
}

- (void)setVideoShowView:(UIView *)view {
    [YZVideoShow syncMainThread:^{
        [self.videoIO setVideoShowViewInMainThread:view];
    }];
}

- (void)setViewFillMode:(YZVideoFillMode)mode {
    [YZVideoShow syncMainThread:^{
        [self.videoIO setContentModeInMainThread:(UIViewContentMode)mode];
    }];
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

