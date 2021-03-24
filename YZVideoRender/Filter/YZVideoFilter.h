//
//  YZVideoFilter.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import <UIKit/UIKit.h>
#import "YZVideoPlayer.h"
#import "YZVideoData.h"

@protocol YZVideoFilterDelegate;
@interface YZVideoFilter : NSObject
@property (nonatomic, weak) id<YZVideoFilterDelegate> delegate;
@property (nonatomic, strong) YZVideoPlayer *player;
//output
@property (nonatomic, strong) YZVideoDevice *device;
@property (nonatomic, assign) BOOL outout;
@property (nonatomic, strong) id<MTLTexture> texture;
@property (nonatomic, assign) CVMetalTextureCacheRef textureCache;

- (instancetype)initWithDevice:(YZVideoDevice *)device output:(BOOL)output;

- (void)displayVideo:(YZVideoData *)videoData;
//outout
- (BOOL)cropTextureSize:(CGSize)size videoData:(YZVideoData *)data;
- (simd_float8)getTextureCoordinates:(CGSize)size videoData:(YZVideoData *)data;
- (void)showTexture;
@end

@protocol YZVideoFilterDelegate <NSObject>

- (void)filter:(YZVideoFilter *)filter pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
