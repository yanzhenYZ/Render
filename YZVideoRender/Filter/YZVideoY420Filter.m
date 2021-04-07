//
//  YZVideoY420Filter.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/18.
//

#import "YZVideoY420Filter.h"
#import "YZVFOrientation.h"

@implementation YZVideoY420Filter
- (void)displayVideo:(YZVideoData *)videoData {
    if (!self.outout) {
        [self.player showBuffer:videoData];
        return;
    }
    CVPixelBufferRef pixelBuffer = videoData.pixelBuffer;
    size_t w = (int)CVPixelBufferGetWidth(pixelBuffer);
    size_t h = (int)CVPixelBufferGetHeight(pixelBuffer);
    if (![self cropTextureSize:CGSizeMake(w, h) videoData:videoData]) {
        return;
    }
    
    CVMetalTextureRef textureRef = NULL;
    size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatR8Unorm, width, height, 0, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    id<MTLTexture> textureY = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatR8Unorm, width, height, 1, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    id<MTLTexture> textureU = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 2);
    height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 2);
    status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatR8Unorm, width, height, 2, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    id<MTLTexture> textureV = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    MTLRenderPassDescriptor *desc = [YZVideoDevice newRenderPassDescriptor:self.texture];
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    
    id<MTLCommandBuffer> commandBuffer = [self.device commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZVideoY420Filter render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingClockwise];
//    [encoder setRenderPipelineState:self.device.pipelineState];

    simd_float8 vertices = [YZVFOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];

    simd_float8 textureCoordinates = [self getTextureCoordinates:CGSizeMake(w, h) videoData:videoData];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:textureY atIndex:0];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:2];
    [encoder setFragmentTexture:textureU atIndex:1];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:3];
    [encoder setFragmentTexture:textureV atIndex:2];

    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];

    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    [self showTexture];
}
@end
