//
//  YZVideoPlayer.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoPlayer.h"

@interface YZVideoPlayer ()<MTKViewDelegate>
//@property (nonatomic, strong)
@end

@implementation YZVideoPlayer

- (instancetype)initWithDevice:(YZVideoDevice *)device {
    self = [super initWithFrame:CGRectZero device:device.device];
    if (self) {
        _videoDevice = device;
        self.paused = YES;
        self.delegate = self;
        self.framebufferOnly = NO;
        self.enableSetNeedsDisplay = NO;
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)showBuffer:(YZVideoData *)videoData {
    //int width = (int)CVPixelBufferGetWidth(videoData.pixelBuffer);
    //int height = (int)CVPixelBufferGetHeight(videoData.pixelBuffer);
    //NSLog(@"___%d:%d:%d", width, height, videoData.rotation);
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView *)view {
    
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}
@end
