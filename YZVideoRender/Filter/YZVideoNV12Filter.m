//
//  YZVideoNV12Filter.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoNV12Filter.h"
#import "YZVFOrientation.h"

@implementation YZVideoNV12Filter

- (void)displayVideo:(YZVideoData *)videoData {
    if (!self.outout) {
        [self.player showBuffer:videoData];
        return;
    }
    int width = videoData.width;
    int height = videoData.height;
    if (![self cropTextureSize:CGSizeMake(width, height) videoData:videoData]) {
        return;
    }
    
    MTLTextureDescriptor *yDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width height:height mipmapped:NO];
    yDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    id<MTLTexture> textureY = [self.device.device newTextureWithDescriptor:yDesc];
    [textureY replaceRegion:MTLRegionMake2D(0, 0, textureY.width, textureY.height) mipmapLevel:0 withBytes:videoData.yBuffer bytesPerRow:videoData.yStride];

    MTLTextureDescriptor *uvDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRG8Unorm width:width / 2 height:height / 2 mipmapped:NO];
    uvDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    id<MTLTexture> textureUV = [self.device.device newTextureWithDescriptor:uvDesc];
    [textureUV replaceRegion:MTLRegionMake2D(0, 0, textureUV.width, textureUV.height) mipmapLevel:0 withBytes:videoData.uvBuffer bytesPerRow:videoData.uvStride];
    
    MTLRenderPassDescriptor *desc = [YZVideoDevice newRenderPassDescriptor:self.texture];
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    
    id<MTLCommandBuffer> commandBuffer = [self.device commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZVideoNV12Filter render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
//    [encoder setRenderPipelineState:self.device.pipelineState];

    simd_float8 vertices = [YZVFOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [self getTextureCoordinates:CGSizeMake(width, height) videoData:videoData];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:textureY atIndex:0];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:2];
    [encoder setFragmentTexture:textureUV atIndex:1];
    
    id<MTLBuffer> uniformBuffer = [self.device.device newBufferWithBytes:kYZColorConversion601 length:sizeof(float) * 12 options:MTLResourceCPUCacheModeDefaultCache];
    [encoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer commit];
    [commandBuffer waitUntilCompleted];
    
    [self showTexture];
}

@end
