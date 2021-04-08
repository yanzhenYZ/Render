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

- (BOOL)deviceSupport;

- (id<MTLCommandBuffer>)commandBuffer;
+ (MTLRenderPassDescriptor *)newRenderPassDescriptor:(id<MTLTexture>)texture;

//new display
- (id<MTLRenderPipelineState>)getBGRAPipeline;
- (id<MTLRenderPipelineState>)getVideoRangePipeline;
- (id<MTLRenderPipelineState>)getFullRangePipeline;
- (id<MTLRenderPipelineState>)getY420Pipeline;
- (id<MTLRenderPipelineState>)getI420Pipeline;
- (id<MTLRenderPipelineState>)getNV12Pipeline;
@end


