//
//  YZMetalFormatNV12.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/8.
//

#import "YZMetalFormatNV12.h"

@interface YZMetalFormatNV12 ()
@property (nonatomic, strong) id<MTLTexture> textureY;
@property (nonatomic, strong) id<MTLTexture> textureUV;
@end

@implementation YZMetalFormatNV12
- (instancetype)initWithDevice:(YZVideoDevice *)device {
    self = [super initWithDevice:device];
    if (self) {
        
    }
    return self;
}

- (void)displayVideo:(YZVideoData *)videoData {
    
}

- (void)drawTexture:(id<CAMetalDrawable>)currentDrawable {
    
}
@end
