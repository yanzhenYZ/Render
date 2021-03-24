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
@property (nonatomic, strong) id<MTLLibrary> library;
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
                _library = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZVertexFragment] options:NULL error:nil];
                assert(_library);
                _pipelineState = [self createRenderPipeline:_library vertex:@"YZInputVertex" fragment:@"YZFragment"];
                _defaultPipelineState = _pipelineState;
                break;
            case YZVideoFormat420YpCbCr8BiPlanarVideoRange:
                _library = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZYUVToRGBString] options:NULL error:nil];
                assert(_library);
                _pipelineState = [self createRenderPipeline:_library vertex:@"YZYUVToRGBVertex" fragment:@"YZYUVConversionVideoRangeFragment"];
                break;
            case YZVideoFormat420YpCbCr8BiPlanarFullRange:
            case YZVideoFormatNV21:
                _library = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZYUVToRGBString] options:NULL error:nil];
                assert(_library);
                _pipelineState = [self createRenderPipeline:_library vertex:@"YZYUVToRGBVertex" fragment:@"YZYUVConversionFullRangeFragment"];
                break;
            case YZVideoFormatI420:
                _library = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZI420MetalString] options:NULL error:nil];
                assert(_library);
                _pipelineState = [self createRenderPipeline:_library vertex:@"YZYUVDataToRGBVertex" fragment:@"YZYUVDataConversionFullRangeFragment"];
                break;
            case YZVideoFormat420YpCbCr8Planar://todo
                _library = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZI420MetalString] options:NULL error:nil];
                assert(_library);
                _pipelineState = [self createRenderPipeline:_library vertex:@"YZYUVDataToRGBVertex" fragment:@"YZYUVDataConversionFullRangeFragment"];
                break;
            default:
                break;
        }
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

- (void)newDefaultRenderPipeline {
    if (!_defaultPipelineState) {
        id<MTLLibrary> library = [_device newLibraryWithSource:[NSString stringWithUTF8String:YZVertexFragment] options:NULL error:nil];
        assert(library);
        _defaultPipelineState = [self createRenderPipeline:library vertex:@"YZInputVertex" fragment:@"YZFragment"];
    }
}

- (id<MTLRenderPipelineState>)createRenderPipeline:(id<MTLLibrary>)library vertex:(NSString *)vertex fragment:(NSString *)fragment {
    id<MTLFunction> vertexFunction = [library newFunctionWithName:vertex];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:fragment];
    MTLRenderPipelineDescriptor *desc = [[MTLRenderPipelineDescriptor alloc] init];
    desc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;//bgra
    if (@available(iOS 11.0, macOS 10.13, *)) {
        desc.rasterSampleCount = 1;
    } else {
        desc.sampleCount = 1;
    }
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
