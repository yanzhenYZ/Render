//
//  YZVideoPlayer.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoPlayer.h"
#import "YZVFOrientation.h"

@interface YZVideoPlayer ()<MTKViewDelegate>
//@property (nonatomic, strong)
@end

@implementation YZVideoPlayer

- (void)dealloc {
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
    }
}

- (instancetype)initWithDevice:(YZVideoDevice *)device {
    self = [super initWithFrame:CGRectZero device:device.device];
    if (self) {
        _videoDevice = device;
        self.paused = YES;
        self.delegate = self;
        self.framebufferOnly = NO;
        self.enableSetNeedsDisplay = NO;
        self.contentMode = UIViewContentModeScaleAspectFit;
        CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, device.device, NULL, &_textureCache);
    }
    return self;
}

- (void)showBuffer:(YZVideoData *)videoData {
    //int width = (int)CVPixelBufferGetWidth(videoData.pixelBuffer);
    //int height = (int)CVPixelBufferGetHeight(videoData.pixelBuffer);
    //NSLog(@"___%d:%d:%d", width, height, videoData.rotation);
}

- (void)draw:(size_t)width height:(size_t)height rotation:(int)rotation {
    self.rotation = rotation;
    if (rotation == 90 || rotation == 270) {
        self.drawableSize = CGSizeMake(height, width);
    } else {
        self.drawableSize = CGSizeMake(width, height);
    }
    [self draw];
}

- (simd_float8)getTextureCoordinates {
    return [YZVFOrientation getRotationTextureCoordinates:_rotation];
}
#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView *)view {
    
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}
@end
