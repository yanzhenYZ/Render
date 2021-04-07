//
//  YZMetalFormat.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/7.
//

#import "YZMetalFormat.h"
#import "YZVFOrientation.h"

@interface YZMetalFormat ()
@property (nonatomic, assign) int rotation;
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

- (void)displayVideo:(YZVideoData *)videoData { }

- (simd_float8)getTextureCoordinates {
    return [YZVFOrientation getCropRotationTextureCoordinates:_rotation crop:_cropRect];
}

- (void)draw:(size_t)width height:(size_t)height videoData:(YZVideoData *)data {
    self.rotation = (int)data.rotation;
    size_t w = width;
    size_t h = height;
    _cropRect = [self getCropWith:width heigth:height videoData:data];
    w = width - data.cropLeft - data.cropRight;
    h = height - data.cropTop - data.cropBottom;
    if (_rotation == 90 || _rotation == 270) {
        self.mtkView.drawableSize = CGSizeMake(h, w);
    } else {
        self.mtkView.drawableSize = CGSizeMake(w, h);
    }
    [self.mtkView draw];
}

#pragma mark - helper
- (CGRect)getCropWith:(CGFloat)width heigth:(CGFloat)height videoData:(YZVideoData *)data {
    CGFloat x = data.cropLeft / width;
    CGFloat y = data.cropTop / height;
    CGFloat w =  1 - x - data.cropRight / width;
    CGFloat h =  1 - y - data.cropBottom / height;
    return CGRectMake(x, y, w, h);
}
@end
