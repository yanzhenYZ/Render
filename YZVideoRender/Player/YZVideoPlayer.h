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

- (instancetype)initWithDevice:(YZVideoDevice *)device;

@property (nonatomic, strong, readonly) YZVideoDevice *videoDevice;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;

- (void)showBGRABuffer:(YZVideoData *)videoData;
@end

