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

+ (Class)layerClass {
    return [AVSampleBufferDisplayLayer class];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sampleBufferDisplayLayer = (AVSampleBufferDisplayLayer *)self.layer;
        _sampleBufferDisplayLayer.videoGravity = AVLayerVideoGravityResize;
    }
    return self;
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
    switch (contentMode) {
        case UIViewContentModeScaleToFill:
            _sampleBufferDisplayLayer.videoGravity = AVLayerVideoGravityResize;
            break;
        case UIViewContentModeScaleAspectFit:
//            _sampleBufferDisplayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            [_sampleBufferDisplayLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
            break;
        case UIViewContentModeScaleAspectFill:
            _sampleBufferDisplayLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
        default:
            break;
    }
}

- (NSString *)description {
    return @"YZ Video Player";
}
@end
