//
//  YZMetalFormatBGRA.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/7.
//

#import "YZMetalFormatBGRA.h"

@interface YZMetalFormatBGRA ()
@property (nonatomic, strong) id<MTLTexture> texture;
@end

@implementation YZMetalFormatBGRA
- (instancetype)initWithDevice:(YZVideoDevice *)device {
    self = [super initWithDevice:device];
    if (self) {
        self.pipelineState = [device getBGRAPipeline];
    }
    return self;
}

- (void)displayVideo:(YZVideoData *)videoData {
    CVPixelBufferRef pixelBuffer = videoData.pixelBuffer;
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    CVMetalTextureRef textureRef = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.textureCache, pixelBuffer, nil, MTLPixelFormatBGRA8Unorm, width, height, 0, &textureRef);
    if (kCVReturnSuccess != status) {
        return;
    }
    _texture = CVMetalTextureGetTexture(textureRef);
    CFRelease(textureRef);
    textureRef = NULL;
    
    [self draw:width height:height videoData:videoData];
}
@end
