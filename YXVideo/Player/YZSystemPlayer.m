//
//  YZSystemPlayer.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/6.
//

#import "YZSystemPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface YZSystemPlayer ()
@property (nonatomic, strong) AVSampleBufferDisplayLayer *sampleBufferDisplayLayer;
@end

@implementation YZSystemPlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createDisplayLayer:AVLayerVideoGravityResize];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _sampleBufferDisplayLayer.frame = self.bounds;
}

- (void)displayVideo:(CVPixelBufferRef)pixelBuffer {
    if (!pixelBuffer) { return; }
    //不设置具体时间信息
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    //获取视频信息
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    NSParameterAssert(result == 0 && videoInfo != NULL);

    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    NSParameterAssert(result == 0 && sampleBuffer != NULL);
    CFRelease(videoInfo);

    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    [_sampleBufferDisplayLayer enqueueSampleBuffer:sampleBuffer];
    if (_sampleBufferDisplayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [_sampleBufferDisplayLayer flush];
    }
    CFRelease(sampleBuffer);
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    AVLayerVideoGravity videoGravity = [self getVideoGravity:contentMode];
    if (![videoGravity isEqualToString:_sampleBufferDisplayLayer.videoGravity]) {
        [self createDisplayLayer:videoGravity];
    }
}

- (NSString *)description {
    return @"YZ Video Player";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _sampleBufferDisplayLayer.frame = self.bounds;
}
#pragma mark - private
- (void)createDisplayLayer:(AVLayerVideoGravity)videoGravity {
    if (_sampleBufferDisplayLayer) {
        [_sampleBufferDisplayLayer stopRequestingMediaData];
        [_sampleBufferDisplayLayer removeFromSuperlayer];
        _sampleBufferDisplayLayer = nil;
    }
    _sampleBufferDisplayLayer = [[AVSampleBufferDisplayLayer alloc] init];
    _sampleBufferDisplayLayer.videoGravity = videoGravity;
    _sampleBufferDisplayLayer.frame = self.bounds;
    [self.layer addSublayer:_sampleBufferDisplayLayer];
}

- (AVLayerVideoGravity)getVideoGravity:(UIViewContentMode)contentMode {
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
            return AVLayerVideoGravityResize;
            break;
        case UIViewContentModeScaleAspectFit:
            return AVLayerVideoGravityResizeAspect;
            break;
        case UIViewContentModeScaleAspectFill:
            return AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }
    return _sampleBufferDisplayLayer.videoGravity;
}
@end
