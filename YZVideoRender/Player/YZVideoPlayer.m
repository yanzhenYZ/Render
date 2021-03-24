//
//  YZVideoPlayer.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoPlayer.h"
#import "YZVFOrientation.h"

@interface YZVideoPlayer ()<MTKViewDelegate>
@property (nonatomic, strong) id<MTLTexture> superTexture;
@property (nonatomic, assign) CGRect cropRect;
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

- (void)draw:(size_t)width height:(size_t)height videoData:(YZVideoData *)data {
    self.rotation = (int)data.rotation;
    size_t w = width;
    size_t h = height;
    _cropRect = [self getCropWith:width heigth:height videoData:data];
    w = width - data.cropLeft - data.cropRight;
    h = height - data.cropTop - data.cropBottom;
    if (_rotation == 90 || _rotation == 270) {
        self.drawableSize = CGSizeMake(h, w);
    } else {
        self.drawableSize = CGSizeMake(w, h);
    }
    [self draw];
}

- (simd_float8)getTextureCoordinates {
    return [YZVFOrientation getCropRotationTextureCoordinates:_rotation crop:_cropRect];
}

- (void)displayTexture:(id<MTLTexture>)texture {
    _superTexture = texture;
    self.drawableSize = CGSizeMake(texture.width, texture.height);
    [self draw];
}
#pragma mark - MTKViewDelegate
//only use output
- (void)drawInMTKView:(MTKView *)view {
    if (!view.currentDrawable || !_superTexture) { return; }
    id<MTLTexture> outTexture = view.currentDrawable.texture;
    
    MTLRenderPassDescriptor *desc = [YZVideoDevice newRenderPassDescriptor:outTexture];
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    
    id<MTLCommandBuffer> commandBuffer = [self.videoDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZVideoPlayer render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.videoDevice.pipelineState];

    simd_float8 vertices = [YZVFOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [YZVFOrientation defaultTextureCoordinates];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:_superTexture atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
    _superTexture = nil;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
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
