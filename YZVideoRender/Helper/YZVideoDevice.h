//
//  YZVideoDevice.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import <Foundation/Foundation.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import "YZVideoOptions.h"

@interface YZVideoDevice : NSObject

+ (BOOL)isDeviceSupport;

-(instancetype)initWithFormat:(YZVideoTFormat)format;

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLRenderPipelineState> defaultPipelineState;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;

- (BOOL)deviceSupport;

- (id<MTLCommandBuffer>)commandBuffer;
+ (MTLRenderPassDescriptor *)newRenderPassDescriptor:(id<MTLTexture>)texture;
- (void)newDefaultRenderPipeline;

@end


