//
//  YZFullRangeFilter.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/17.
//

#import "YZFullRangeFilter.h"
#import "YZVFOrientation.h"

@implementation YZFullRangeFilter
- (void)displayVideo:(YZVideoData *)videoData {
    if (!self.outout) {
        [self.player showBuffer:videoData];
        return;
    }
    CVPixelBufferRef pixelBuffer = videoData.pixelBuffer;
    size_t w = (int)CVPixelBufferGetWidth(videoData.pixelBuffer);
    size_t h = (int)CVPixelBufferGetHeight(videoData.pixelBuffer);
    if (![self cropTextureSize:CGSizeMake(w, h) videoData:videoData]) {
        return;
    }
    const float *colorConversion;
    CFTypeRef attachment = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
    if (attachment != NULL) {
        if(CFStringCompare(attachment, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
            colorConversion = kYZColorConversion601FullRange;
        } else {
            colorConversion = kYZColorConversion709;
        }
    } else {
        colorConversion = kYZColorConversion601FullRange;
    }
    
    CVMetalTextureRef textureRef = NULL;
    //y
    size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatR8Unorm, width, height, 0, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    id<MTLTexture> textureY = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    //uv
    width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, NULL, MTLPixelFormatRG8Unorm, width, height, 1, &textureRef);
    if(status != kCVReturnSuccess) {
        return;
    }
    id<MTLTexture> textureUV = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    MTLRenderPassDescriptor *desc = [YZVideoDevice newRenderPassDescriptor:self.texture];
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    
    id<MTLCommandBuffer> commandBuffer = [self.device commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZVideoRangeFilter render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
//    [encoder setRenderPipelineState:self.device.pipelineState];

    simd_float8 vertices = [YZVFOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [self getTextureCoordinates:CGSizeMake(w, h) videoData:videoData];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:textureY atIndex:0];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:2];
    [encoder setFragmentTexture:textureUV atIndex:1];
    
    id<MTLBuffer> uniformBuffer = [self.device.device newBufferWithBytes:colorConversion length:sizeof(float) * 12 options:MTLResourceCPUCacheModeDefaultCache];
    [encoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    [self showTexture];
}
@end
