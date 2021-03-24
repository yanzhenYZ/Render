//
//  YZVideoFilter.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoFilter.h"
#import "YZVFOrientation.h"

@interface YZVideoFilter ()
@property (nonatomic) CGSize size;
@end

@implementation YZVideoFilter {
    CVPixelBufferRef _pixelBuffer;
}

- (void)dealloc
{
    if (_pixelBuffer) {
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = nil;
    }
    
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
}

- (instancetype)initWithDevice:(YZVideoDevice *)device output:(BOOL)output {
    self = [super init];
    if (self) {
        _device = device;
        _outout = output;
        if (output) {
            [device newDefaultRenderPipeline];
            CVMetalTextureCacheCreate(NULL, NULL, device.device, NULL, &_textureCache);
        }
    }
    return self;
}


- (void)displayVideo:(YZVideoData *)videoData { }

- (BOOL)cropTextureSize:(CGSize)size videoData:(YZVideoData *)data {
    CGFloat width = size.width - data.cropLeft - data.cropRight;
    CGFloat height = size.height - data.cropTop - data.cropBottom;
    CGSize outoutSize = CGSizeMake(width, height);
    if (data.rotation == 90 || data.rotation == 270) {
        [self newDealTextureSize:CGSizeMake(outoutSize.height, outoutSize.width)];
    } else {
        [self newDealTextureSize:outoutSize];
    }
    return [self continueMetal];
}

- (simd_float8)getTextureCoordinates:(CGSize)size videoData:(YZVideoData *)data {
    CGRect crop = [self getCropWith:size videoData:data];
    return [YZVFOrientation getCropRotationTextureCoordinates:(int)data.rotation crop:crop];
}

- (void)showTexture {
    [self.player displayTexture:self.texture];
    if ([self.delegate respondsToSelector:@selector(filter:pixelBuffer:)]) {
        [self.delegate filter:self pixelBuffer:_pixelBuffer];
    }
}

#pragma mark - helper
- (CGRect)getCropWith:(CGSize)size videoData:(YZVideoData *)data {
    CGFloat x = data.cropLeft / size.width;
    CGFloat y = data.cropTop / size.height;
    CGFloat w =  1 - x - data.cropRight / size.width;
    CGFloat h =  1 - y - data.cropBottom / size.height;
    return CGRectMake(x, y, w, h);
}

- (BOOL)continueMetal {
    if (!_pixelBuffer || !_texture) {
        return NO;
    }
    return YES;
}

- (void)newDealTextureSize:(CGSize)size {
    if (!CGSizeEqualToSize(_size, size)) {
        if (_pixelBuffer) {
            CVPixelBufferRelease(_pixelBuffer);
            _pixelBuffer = nil;
        }
        _size = size;
    }
    
    if (_pixelBuffer) { return; }
    NSDictionary *pixelAttributes = @{(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                            _size.width,
                                            _size.height,
                                            kCVPixelFormatType_32BGRA,
                                            (__bridge CFDictionaryRef)(pixelAttributes),
                                            &_pixelBuffer);
    if (result != kCVReturnSuccess) {
        NSLog(@"YZBGRAPixelBuffer to create cvpixelbuffer %d", result);
        return;
    }
    
    CVMetalTextureRef textureRef = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, _pixelBuffer, nil, MTLPixelFormatBGRA8Unorm, size.width, size.height, 0, &textureRef);
    if (kCVReturnSuccess != status) {
        return;
    }
    _texture = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
}
@end
