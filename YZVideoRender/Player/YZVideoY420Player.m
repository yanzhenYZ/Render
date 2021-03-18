//
//  YZVideoY420Player.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/18.
//

#import "YZVideoY420Player.h"
#import "YZVFOrientation.h"

@interface YZVideoY420Player ()
@property (nonatomic, strong) id<MTLTexture> textureY;
@property (nonatomic, strong) id<MTLTexture> textureU;
@property (nonatomic, strong) id<MTLTexture> textureV;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;

@property (nonatomic, assign) int rotation;
@end

@implementation YZVideoY420Player

- (void)dealloc {
    if (_textureCache) {
        CVMetalTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
    }
}

- (instancetype)initWithDevice:(YZVideoDevice *)device {
    self = [super initWithDevice:device];
    if (self) {
        CVMetalTextureCacheCreate(kCFAllocatorDefault, NULL, device.device, NULL, &_textureCache);
    }
    return self;
}

- (void)showBuffer:(YZVideoData *)videoData {
    CVPixelBufferRef pixelBuffer = videoData.pixelBuffer;
    CVMetalTextureRef textureRef = NULL;
    //y
    size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, MTLPixelFormatR8Unorm, width, height, 0, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    _textureY = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, MTLPixelFormatR8Unorm, width/2, height/2, 1, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    _textureU = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, MTLPixelFormatR8Unorm, width/2, height/2, 2, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    _textureV = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    _rotation = (int)videoData.rotation;
    if (_rotation == 90 || _rotation == 270) {
        self.drawableSize = CGSizeMake(height, width);
    } else {
        self.drawableSize = CGSizeMake(width, height);
    }
    [self draw];
}

#pragma mark - MTKViewDelegate
- (void)drawInMTKView:(MTKView *)view {
    if (!view.currentDrawable || !_textureY || !_textureU || !_textureV) { return; }
    id<MTLTexture> outTexture = view.currentDrawable.texture;
    
    MTLRenderPassDescriptor *desc = [YZVideoDevice newRenderPassDescriptor:outTexture];
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    
    id<MTLCommandBuffer> commandBuffer = [self.videoDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZI420Player render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.videoDevice.pipelineState];

    simd_float8 vertices = [YZVFOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];

    simd_float8 textureCoordinates = [YZVFOrientation getRotationTextureCoordinates:_rotation];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:_textureY atIndex:0];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:2];
    [encoder setFragmentTexture:_textureU atIndex:1];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:3];
    [encoder setFragmentTexture:_textureV atIndex:2];

    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];

    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
    _textureY = nil;
    _textureU = nil;
    _textureV = nil;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}


@end
