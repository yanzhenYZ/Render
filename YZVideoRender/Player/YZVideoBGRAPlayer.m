//
//  YZVideoBGRAPlayer.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/13.
//

#import "YZVideoBGRAPlayer.h"

@interface YZVideoBGRAPlayer ()
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@end

@implementation YZVideoBGRAPlayer

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
        self.pipelineState = [device newRenderPipeline:@"YZInputVertex" fragment:@"YZFragment"];
    }
    return self;
}

- (void)showBGRABuffer:(YZVideoData *)videoData {
    CVPixelBufferRef pixelBuffer = videoData.pixelBuffer;
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    CVMetalTextureRef textureRef = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, nil, MTLPixelFormatBGRA8Unorm, width, height, 0, &textureRef);
    if (kCVReturnSuccess != status) {
        return;
    }
    _texture = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    self.drawableSize = CGSizeMake(width, height);
    [self draw];
}

#pragma mark - MTKViewDelegate
- (void)drawInMTKView:(MTKView *)view {
    if (!view.currentDrawable || !_texture) { return; }
    id<MTLTexture> outTexture = view.currentDrawable.texture;
    
    MTLRenderPassDescriptor *desc = [YZVideoDevice newRenderPassDescriptor:outTexture];
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    
    id<MTLCommandBuffer> commandBuffer = [self.videoDevice commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZVideoBGRAPlayer render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];

//    CGFloat w = 1;
//    CGFloat h = 1;
//    if (_fillMode == YZMTKViewFillModeScaleAspectFit) {//for background color
//        CGRect bounds = self.currentBounds;
//        CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(self.drawableSize, bounds);
//        w = insetRect.size.width / bounds.size.width;
//        h = insetRect.size.height / bounds.size.height;
//    }
    
//    simd_float8 vertices = {-w, h, w, h, -w, -h, w, -h};
    
    simd_float8 vertices = {-1, 1, 1, 1, -1, -1, 1, -1};
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = {0, 0, 1, 0, 0, 1, 1, 1};
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:_texture atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
    _texture = nil;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

@end
