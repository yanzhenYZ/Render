//
//  YZVideoMetalIO.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/6.
//

#import "YZVideoMetalIO.h"
#import "YZMetalFormatVideoRange.h"
#import "YZMetalFormatFullRange.h"
#import "YZMetalFormatBGRA.h"
#import "YZMetalFormatY420.h"
#import "YZMetalFormatI420.h"
#import "YZMetalFormatNV12.h"
#import "YZMTKView.h"

@interface YZVideoMetalIO ()<MTKViewDelegate>
@property (nonatomic, strong) YZMTKView *player;
@property (nonatomic, strong) YZMetalFormat *format;
@property (nonatomic, assign) YXVideoFormat videFormat;
@property (nonatomic, assign) UIViewContentMode contentMode;
@end

@implementation YZVideoMetalIO

- (void)displayVideo:(YXVideoData *)videoData {
    if (videoData.format == YXVideoFormatPixelBuffer) {
        [self displayPixelBuffer:videoData];
    } else if (videoData.format == YXVideoFormatI420) {
        if (!_player) { return; }
        if (![_format isKindOfClass:[YZMetalFormatI420 class]]) {
            _format = [[YZMetalFormatI420 alloc] initWithDevice:self.device];
            _format.mtkView = _player;
        }
        [_format displayVideo:videoData];
    } else if (videoData.format == YXVideoFormatNV12) {
        if (!_player) { return; }
        if (![_format isKindOfClass:[YZMetalFormatNV12 class]]) {
            _format = [[YZMetalFormatNV12 alloc] initWithDevice:self.device];
            _format.mtkView = _player;
        }
        [_format displayVideo:videoData];
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

#pragma mark - helper
- (void)displayPixelBuffer:(YXVideoData *)data {
    CVPixelBufferRef pixelBuffer = data.pixelBuffer;
    if (!pixelBuffer || !_player) { return; }
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    if (type == kCVPixelFormatType_32BGRA) {
        if (![_format isKindOfClass:[YZMetalFormatBGRA class]]) {
            _format = [[YZMetalFormatBGRA alloc] initWithDevice:self.device];
            _format.mtkView = _player;
        }
    } else if (type == kCVPixelFormatType_420YpCbCr8Planar) {
        if (![_format isKindOfClass:[YZMetalFormatY420 class]]) {
            _format = [[YZMetalFormatY420 alloc] initWithDevice:self.device];
            _format.mtkView = _player;
        }
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        if (![_format isKindOfClass:[YZMetalFormatFullRange class]]) {
            _format = [[YZMetalFormatFullRange alloc] initWithDevice:self.device];
            _format.mtkView = _player;
        }
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        if (![_format isKindOfClass:[YZMetalFormatVideoRange class]]) {
            _format = [[YZMetalFormatVideoRange alloc] initWithDevice:self.device];
            _format.mtkView = _player;
        }
    }
    [_format displayVideo:data];
}

#pragma mark - MTKViewDelegate
- (void)drawInMTKView:(MTKView *)view {
    if (!view.currentDrawable) { return; }
    [_format drawTexture:view.currentDrawable];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

#pragma mark - lazy var
- (YZMTKView *)player {
    if (!_player) {
        _player = [[YZMTKView alloc] initWithFrame:CGRectZero device:self.device.device];
        _player.delegate = self;
        _player.layer.backgroundColor = UIColor.blackColor.CGColor;
        _player.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _player.contentMode = _contentMode;
    }
    return _player;
}
@end
