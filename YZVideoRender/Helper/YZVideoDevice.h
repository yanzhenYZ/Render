//
//  YZVideoDevice.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import <Foundation/Foundation.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import "YZVideoData.h"

@interface YZVideoDevice : NSObject

+ (BOOL)isDeviceSupport;

-(instancetype)initWithFormat:(YZVideoFormat)format;

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLRenderPipelineState> defaultPipelineState;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;

- (BOOL)deviceSupport;

- (id<MTLCommandBuffer>)commandBuffer;
+ (MTLRenderPassDescriptor *)newRenderPassDescriptor:(id<MTLTexture>)texture;
- (void)newDefaultRenderPipeline;

//new display
- (id<MTLRenderPipelineState>)getBGRAPipeline;
- (id<MTLRenderPipelineState>)getVideoRangePipeline;
- (id<MTLRenderPipelineState>)getFullRangePipeline;
@end


