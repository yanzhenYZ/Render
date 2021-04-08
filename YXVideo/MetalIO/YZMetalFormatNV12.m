//
//  YZMetalFormatNV12.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/8.
//

#import "YZMetalFormatNV12.h"
#import "YZVFOrientation.h"

@interface YZMetalFormatNV12 ()
@property (nonatomic, strong) id<MTLTexture> textureY;
@property (nonatomic, strong) id<MTLTexture> textureUV;
@end

@implementation YZMetalFormatNV12
- (instancetype)initWithDevice:(YZVideoDevice *)device {
    self = [super initWithDevice:device];
    if (self) {
        self.pipelineState = [device getFullRangePipeline];
    }
    return self;
}

- (void)displayVideo:(YXVideoData *)videoData {
    int width = videoData.width;
    int height = videoData.height;
    MTLTextureDescriptor *yDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatR8Unorm width:width height:height mipmapped:NO];
    yDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    _textureY = [self.device.device newTextureWithDescriptor:yDesc];
    [_textureY replaceRegion:MTLRegionMake2D(0, 0, _textureY.width, _textureY.height) mipmapLevel:0 withBytes:videoData.yBuffer bytesPerRow:videoData.yStride];

    MTLTextureDescriptor *uvDesc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRG8Unorm width:width / 2 height:height / 2 mipmapped:NO];
    uvDesc.usage = MTLTextureUsageShaderWrite | MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    _textureUV = [self.device.device newTextureWithDescriptor:uvDesc];
    [_textureUV replaceRegion:MTLRegionMake2D(0, 0, _textureUV.width, _textureUV.height) mipmapLevel:0 withBytes:videoData.uvBuffer bytesPerRow:videoData.uvStride];

    [self draw:width height:height videoData:videoData];
}

- (void)drawTexture:(id<CAMetalDrawable>)currentDrawable {
    if (!_textureY || !_textureUV) { return; }
    MTLRenderPassDescriptor *desc = [YZVideoDevice newRenderPassDescriptor:currentDrawable.texture];
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    
    id<MTLCommandBuffer> commandBuffer = [self.device commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:desc];
    if (!encoder) {
        NSLog(@"YZMetalFormatNV12 render endcoder Fail");
        return;
    }
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    [encoder setRenderPipelineState:self.pipelineState];

    simd_float8 vertices = [YZVFOrientation defaultVertices];
    [encoder setVertexBytes:&vertices length:sizeof(simd_float8) atIndex:0];
    
    simd_float8 textureCoordinates = [self getTextureCoordinates];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:1];
    [encoder setFragmentTexture:_textureY atIndex:0];
    [encoder setVertexBytes:&textureCoordinates length:sizeof(simd_float8) atIndex:2];
    [encoder setFragmentTexture:_textureUV atIndex:1];
    
    id<MTLBuffer> uniformBuffer = [self.device.device newBufferWithBytes:kYZColorConversion601 length:sizeof(float) * 12 options:MTLResourceCPUCacheModeDefaultCache];
    [encoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:0 vertexCount:4];
    [encoder endEncoding];
    
    [commandBuffer presentDrawable:currentDrawable];
    [commandBuffer commit];
    _textureY = nil;
    _textureUV = nil;
}
@end
