//
//  YZVideoDevice.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoDevice.h"
#import "YZVertexFragment.h"
#import "YZYUVToRGBConversion.h"
#import "YZI420MetalString.h"

@interface YZVideoDevice ()
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLLibrary> yuvRGBLibrary;
@property (nonatomic, strong) id<MTLLibrary> defaultLibrary;
@end

@implementation YZVideoDevice

+ (BOOL)isDeviceSupport {
    return MPSSupportsMTLDevice(MTLCreateSystemDefaultDevice());
}

- (instancetype)initWithFormat:(YZVideoFormat)format
{
    self = [super init];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        
        _commandQueue = [_device newCommandQueue];
        switch (format) {
            case YZVideoFormat32BGRA:
                _defaultLibrary = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZVertexFragment] options:NULL error:nil];
                assert(_defaultLibrary);
                _pipelineState = [self createRenderPipeline:_defaultLibrary vertex:@"YZInputVertex" fragment:@"YZFragment"];
                break;
            case YZVideoFormat420YpCbCr8BiPlanarVideoRange:
                _defaultLibrary = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZYUVToRGBString] options:NULL error:nil];
                assert(_defaultLibrary);
                _pipelineState = [self createRenderPipeline:_defaultLibrary vertex:@"YZYUVToRGBVertex" fragment:@"YZYUVConversionVideoRangeFragment"];
                break;
            case YZVideoFormat420YpCbCr8BiPlanarFullRange:
                _defaultLibrary = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZYUVToRGBString] options:NULL error:nil];
                assert(_defaultLibrary);
                _pipelineState = [self createRenderPipeline:_defaultLibrary vertex:@"YZYUVToRGBVertex" fragment:@"YZYUVConversionFullRangeFragment"];
                break;
            case YZVideoFormatI420:
                _defaultLibrary = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZI420MetalString] options:NULL error:nil];
                assert(_defaultLibrary);
                _pipelineState = [self createRenderPipeline:_defaultLibrary vertex:@"YZYUVDataToRGBVertex" fragment:@"YZYUVDataConversionFullRangeFragment"];
                break;
            default:
                break;
        }
//        _yuvRGBLibrary = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZYUVToRGBString] options:NULL error:nil];
//        assert(_yuvRGBLibrary);
    }
    return self;
}

#pragma mark - metal
- (id<MTLCommandBuffer>)commandBuffer {
    return [_commandQueue commandBuffer];
}

+ (MTLRenderPassDescriptor *)newRenderPassDescriptor:(id<MTLTexture>)texture {
    MTLRenderPassDescriptor *desc = [[MTLRenderPassDescriptor alloc] init];
    desc.colorAttachments[0].texture = texture;
    desc.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1);
    desc.colorAttachments[0].storeAction = MTLStoreActionStore;
    desc.colorAttachments[0].loadAction = MTLLoadActionClear;
    return desc;
}

- (id<MTLRenderPipelineState>)newRenderPipeline:(NSString *)vertex fragment:(NSString *)fragment {
    if ([vertex isEqualToString:@"YZInputVertex"]) {
        return [self createRenderPipeline:_defaultLibrary vertex:vertex fragment:fragment];
    } else if ([vertex isEqualToString:@"YZYUVToRGBVertex"]) {
        return [self createRenderPipeline:_yuvRGBLibrary vertex:vertex fragment:fragment];
    }
    return nil;
}

- (id<MTLRenderPipelineState>)createRenderPipeline:(id<MTLLibrary>)library vertex:(NSString *)vertex fragment:(NSString *)fragment {
    id<MTLFunction> vertexFunction = [library newFunctionWithName:vertex];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:fragment];
    MTLRenderPipelineDescriptor *desc = [[MTLRenderPipelineDescriptor alloc] init];
    desc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;//bgra
    desc.rasterSampleCount = 1;
    desc.vertexFunction = vertexFunction;
    desc.fragmentFunction = fragmentFunction;
    
    NSError *error = nil;
    id<MTLRenderPipelineState> pipeline = [_device newRenderPipelineStateWithDescriptor:desc error:&error];
    if (error) {
        NSLog(@"YZMetalDevice new renderPipelineState failed: %@", error);
    }
    return pipeline;
}
@end
