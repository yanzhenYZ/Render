//
//  YZVideoSystemIO.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/6.
//

#import "YZVideoSystemIO.h"
#import "YZSystemPlayer.h"

@interface YZVideoSystemIO ()
@property (nonatomic, strong) YZSystemPlayer *player;
@property (nonatomic, assign) UIViewContentMode contentMode;
@property (nonatomic, assign) YZVideoFormat format;
@end

/** todo
 
 1. 步长宽高不相等
 2. fullRange nv12, videoRange nv12
 3. 视频尺寸发生变化
 4. 视频format发生变化
 
 */

@implementation YZVideoSystemIO {
    CVPixelBufferRef _pixelBuffer;
}

- (void)dealloc
{
    if (_pixelBuffer) {
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = nil;
    }
}

- (void)displayVideo:(YZVideoData *)videoData {
    if (videoData.format == YZVideoFormatPixelBuffer) {
        [_player displayVideo:videoData.pixelBuffer];
    } else if (videoData.format == YZVideoFormatNV12) {
        [self displayNV12Video:videoData];
    } else if (videoData.format == YZVideoFormatI420) {
        [self displayI420Video:videoData];
    }
}

- (void)setVideoShowViewInMainThread:(UIView *)view {
    if (_player.superview) {
        [_player removeFromSuperview];
    }
    if (view) {
        [view addSubview:self.player];
        self.player.frame = view.bounds;
    } else {
        _player = nil;
    }
}

- (void)setContentModeInMainThread:(UIViewContentMode)contentMode {
    _contentMode = contentMode;
    _player.contentMode = contentMode;
}

#pragma mark - private helper
- (void)displayNV12Video:(YZVideoData *)data {
    [self createNV12PixelBuffer:data];
    if (!_pixelBuffer) { return; }
    CVPixelBufferLockBaseAddress(_pixelBuffer, 0);
    uint8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(_pixelBuffer, 0);
    uint8_t *uvBuffer = CVPixelBufferGetBaseAddressOfPlane(_pixelBuffer, 1);
    
    size_t yStride = CVPixelBufferGetBytesPerRowOfPlane(_pixelBuffer, 0);
    size_t uvStride = CVPixelBufferGetBytesPerRowOfPlane(_pixelBuffer, 1);
    if (yStride == data.yStride) {
        memcpy(yBuffer, data.yBuffer, yStride * data.height);
    } else {
        NSLog(@"NV12Y__%d:%d", yStride, data.yStride);
    }
    
    if (uvStride == data.uvStride) {
        memcpy(uvBuffer, data.uvBuffer, uvStride * data.height / 2);
    } else {
        NSLog(@"NV12UV__%d:%d", uvStride, data.uvStride);
    }
    
    CVPixelBufferUnlockBaseAddress(_pixelBuffer, 0);
    
    [_player displayVideo:_pixelBuffer];
}

- (void)displayI420Video:(YZVideoData *)data {
    NSLog(@"todo I420");
}


- (void)createNV12PixelBuffer:(YZVideoData *)data {
    if (_pixelBuffer) {
        size_t width = CVPixelBufferGetWidth(_pixelBuffer);
        size_t height = CVPixelBufferGetHeight(_pixelBuffer);
        if (data.width == width && data.height == height) {
            return;
        }
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = nil;
    }
    NSDictionary *pixelAttributes = @{(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                            data.width,
                                            data.height,
                                            kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
                                            (__bridge CFDictionaryRef)(pixelAttributes),
                                            &_pixelBuffer);
    if (result != kCVReturnSuccess) {
        NSLog(@"SystemIO to create cvpixelbuffer %d", result);
        return;
    }
}
#pragma mark - lazy var
- (YZSystemPlayer *)player {
    if (!_player) {
        _player = [[YZSystemPlayer alloc] init];
        _player.backgroundColor = UIColor.blackColor;
        _player.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _player.contentMode = _contentMode;
    }
    return _player;
}
@end
