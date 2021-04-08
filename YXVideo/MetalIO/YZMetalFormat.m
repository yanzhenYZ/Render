//
//  YZMetalFormat.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/7.
//

#import "YZMetalFormat.h"
#import "YZVFOrientation.h"

@interface YZMetalFormat ()
@property (nonatomic, strong) YXVideoData *videoData;
@property (nonatomic, assign) CGRect cropRect;
@end

@implementation YZMetalFormat
- (void)dealloc {
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
    }
}

- (instancetype)initWithDevice:(YZVideoDevice *)device {
    self = [super init];
    if (self) {
        _device = device;
        CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, device.device, NULL, &_textureCache);
    }
    return self;
}

- (void)displayVideo:(YXVideoData *)videoData { }
- (void)drawTexture:(id<CAMetalDrawable>)currentDrawable { }

- (simd_float8)getTextureCoordinates {
    simd_float8 t = [YZVFOrientation getCropRotationTextureCoordinates:(int)_videoData.rotation crop:_cropRect];
    if (_videoData.mirror) {
        simd_float8 mirror = {t[2], t[3], t[0], t[1], t[6], t[7], t[4], t[5]};
        return mirror;//todo
    } else {
        return t;
    }
}

- (void)draw:(size_t)width height:(size_t)height videoData:(YXVideoData *)data {
    _videoData = data;
    size_t w = width;
    size_t h = height;
    _cropRect = [self getCropWith:width heigth:height videoData:data];
    w = width - data.cropLeft - data.cropRight;
    h = height - data.cropTop - data.cropBottom;
    if (data.rotation == 90 || data.rotation == 270) {
        self.mtkView.drawableSize = CGSizeMake(h, w);
    } else {
        self.mtkView.drawableSize = CGSizeMake(w, h);
    }
    [self.mtkView draw];
}

#pragma mark - helper
- (CGRect)getCropWith:(CGFloat)width heigth:(CGFloat)height videoData:(YXVideoData *)data {
    CGFloat x = data.cropLeft / width;
    CGFloat y = data.cropTop / height;
    CGFloat w =  1 - x - data.cropRight / width;
    CGFloat h =  1 - y - data.cropBottom / height;
    return CGRectMake(x, y, w, h);
}
@end
