//
//  YZVideoPlayer.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import <MetalKit/MetalKit.h>

@class YZVideoData;
@interface YZVideoPlayer : MTKView

- (void)showBGRABuffer:(YZVideoData *)videoData;
@end

