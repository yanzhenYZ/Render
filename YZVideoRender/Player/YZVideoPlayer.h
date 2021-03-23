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

- (instancetype)initWithDevice:(YZVideoDevice *)device;

- (void)showBuffer:(YZVideoData *)videoData;
@end

