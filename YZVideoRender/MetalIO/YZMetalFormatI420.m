//
//  YZMetalFormatI420.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/8.
//

#import "YZMetalFormatI420.h"

@interface YZMetalFormatI420 ()
@property (nonatomic, strong) id<MTLTexture> textureY;
@property (nonatomic, strong) id<MTLTexture> textureU;
@property (nonatomic, strong) id<MTLTexture> textureV;

@end

@implementation YZMetalFormatI420
- (instancetype)initWithDevice:(YZVideoDevice *)device {
    self = [super initWithDevice:device];
    if (self) {
        self.pipelineState = [device getY420Pipeline];
    }
    return self;
}

- (void)displayVideo:(YZVideoData *)videoData {
    
}

- (void)drawTexture:(id<CAMetalDrawable>)currentDrawable {
    
}
@end
