//
//  YZVideoPlayer.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoPlayer.h"
#import "YZVideoData.h"

@implementation YZVideoPlayer
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"____%@", self);
    }
    return self;
}

- (void)showBGRABuffer:(YZVideoData *)videoData {
    int width = (int)CVPixelBufferGetWidth(videoData.pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(videoData.pixelBuffer);
    NSLog(@"___%d:%d:%d", width, height, videoData.rotation);
}
@end
