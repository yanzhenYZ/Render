//
//  YZDataCapture.h
//  MetalRender
//
//  Created by yanzhen on 2021/3/17.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

static const int VIDEOTYPE = 1;

@protocol YZDataCaptureDelegate;
@interface YZDataCapture : NSObject
@property (nonatomic, weak) id<YZDataCaptureDelegate> delegate;

- (instancetype)initWithPlayer:(UIView *)player;

- (void)startRunning;
- (void)stopRunning;
@end

@protocol YZDataCaptureDelegate <NSObject>

- (void)capture:(YZDataCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

