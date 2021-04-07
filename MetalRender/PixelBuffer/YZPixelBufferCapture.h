//
//  YZPixelBufferCapture.h
//  MetalRender
//
//  Created by yanzhen on 2021/3/12.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

static const int VIDEOTYPE = 2;

@protocol YZPixelBufferCaptureDelegate;
@interface YZPixelBufferCapture : NSObject
@property (nonatomic, weak) id<YZPixelBufferCaptureDelegate> delegate;

- (instancetype)initWithPlayer:(UIView *)player;

- (void)startRunning;
- (void)stopRunning;
@end

@protocol YZPixelBufferCaptureDelegate <NSObject>

- (void)capture:(YZPixelBufferCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
