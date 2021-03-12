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
#import "YZVideoPlayer.h"

@interface YZVideoShow ()
@property (nonatomic, strong) YZVideoOptions *options;
@property (nonatomic, strong) YZVideoFilter *filter;
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
        switch (_options.format) {
            case YZVideoFormatTexture:
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

- (void)setVideoPlayer:(UIView *)player {
    //todo
}

- (void)displayVideo:(YZVideoData *)videoData {
    [_filter displayVideo:videoData];
}
@end
