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
#import "YZMTKView.h"

@interface YZVideoMetalIO ()<MTKViewDelegate>
@property (nonatomic, strong) YZMTKView *player;
@property (nonatomic, strong) YZMetalFormat *format;
@property (nonatomic, assign) YZVideoFormat videFormat;
@property (nonatomic, assign) UIViewContentMode contentMode;
@end

@implementation YZVideoMetalIO

- (void)displayVideo:(YZVideoData *)videoData {
    if (videoData.format == YZVideoFormatPixelBuffer) {
        [self displayPixelBuffer:videoData];
    } else if (videoData.format == YZVideoFormatI420) {
        
    } else if (videoData.format == YZVideoFormatNV12) {
        
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
- (void)displayPixelBuffer:(YZVideoData *)data {
    CVPixelBufferRef pixelBuffer = data.pixelBuffer;
    if (!pixelBuffer || !_player) { return; }
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    if (type == kCVPixelFormatType_32BGRA) {
        if (![_format isKindOfClass:[YZMetalFormatBGRA class]]) {
            _format = [[YZMetalFormatBGRA alloc] initWithDevice:self.device];
            _format.mtkView = _player;
        }
    } else if (type == kCVPixelFormatType_420YpCbCr8Planar) {
        NSLog(@"todo_420");
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        NSLog(@"todo_full");
    } else if (type == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        NSLog(@"todo_video");
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
