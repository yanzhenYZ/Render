//
//  YZVideoPlayer.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import <MetalKit/MetalKit.h>
#import "YZVideoDevice.h"
#import "YZVideoData.h"

@interface YZVideoPlayer : MTKView
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property (nonatomic, strong, readonly) YZVideoDevice *videoDevice;
@property (nonatomic, assign) int rotation;
@property (nonatomic, assign) BOOL crop;

- (instancetype)initWithDevice:(YZVideoDevice *)device;

- (void)showBuffer:(YZVideoData *)videoData;
- (void)draw:(size_t)width height:(size_t)height videoData:(YZVideoData *)data;
- (simd_float8)getTextureCoordinates;
@end

