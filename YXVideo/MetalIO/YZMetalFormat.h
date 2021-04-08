//
//  YZMetalFormat.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/7.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "YZVideoDevice.h"
#import "YXVideoData.h"
#import "YZMTKView.h"

@interface YZMetalFormat : NSObject
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong, readonly) YZVideoDevice *device;
@property (nonatomic, weak) YZMTKView *mtkView;

- (instancetype)initWithDevice:(YZVideoDevice *)device;

- (void)displayVideo:(YXVideoData *)videoData;

- (simd_float8)getTextureCoordinates;
- (void)drawTexture:(id <CAMetalDrawable>)currentDrawable;
- (void)draw:(size_t)width height:(size_t)height videoData:(YXVideoData *)data;
@end


