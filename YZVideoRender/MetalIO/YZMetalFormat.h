//
//  YZMetalFormat.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/7.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "YZVideoDevice.h"
#import "YZVideoData.h"
#import "YZMTKView.h"

@interface YZMetalFormat : NSObject
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong, readonly) YZVideoDevice *device;
@property (nonatomic, weak) YZMTKView *mtkView;

- (instancetype)initWithDevice:(YZVideoDevice *)device;

- (void)displayVideo:(YZVideoData *)videoData;

- (void)draw:(size_t)width height:(size_t)height videoData:(YZVideoData *)data;
@end


