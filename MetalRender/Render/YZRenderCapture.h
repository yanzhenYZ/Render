//
//  YZRenderCapture.h
//  MetalRender
//
//  Created by yanzhen on 2021/3/23.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

static const int VIDEOTYPE = 0;

@protocol YZRenderCaptureDelegate;
@interface YZRenderCapture : NSObject
@property (nonatomic, weak) id<YZRenderCaptureDelegate> delegate;

- (instancetype)initWithPlayer:(UIView *)player;

- (void)startRunning;
- (void)stopRunning;
@end

@protocol YZRenderCaptureDelegate <NSObject>

- (void)capture:(YZRenderCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end



