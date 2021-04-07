//
//  YZVideoTextureFilter.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoTextureFilter.h"
#import "YZVFOrientation.h"

@implementation YZVideoTextureFilter

- (void)displayVideo:(YZVideoData *)videoData {
    if (!self.outout) {
        [self.player showBuffer:videoData];
        return;
    }
    int width = (int)CVPixelBufferGetWidth(videoData.pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(videoData.pixelBuffer);
    if (![self cropTextureSize:CGSizeMake(width, height) videoData:videoData]) {
        return;
    }
    CVMetalTextureRef tmpTexture = NULL;
    CVReturn status =  CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, videoData.pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tmpTexture);
    if (status != kCVReturnSuccess) {
        return;
    }
    
    id<MTLTexture> texture = CVMetalTextureGetTexture(tmpTexture);
    CFRelease(tmpTexture);
    
    MTLRenderPassDescriptor *desc = [YZVideoDevice newRenderPassDescriptor:self.texture];
    id<MTLCommandBuffer> commandBuffer = [self.device commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZVideoTextureFilter render endcoder Fail");
        return;
    }

    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
//    [encoder setRenderPipelineState:self.device.pipelineState];
    simd_float8 vertices = [YZVFOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [self getTextureCoordinates:CGSizeMake(width, height) videoData:videoData];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:texture atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    [self showTexture];
}


@end
