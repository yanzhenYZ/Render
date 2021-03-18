//
//  YZTestCapture.h
//  MetalRender
//
//  Created by yanzhen on 2021/3/18.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

static const int VIDEOTYPE = 1;

@protocol YZTestCaptureDelegate;
@interface YZTestCapture : NSObject
@property (nonatomic, weak) id<YZTestCaptureDelegate> delegate;

- (instancetype)initWithPlayer:(UIView *)player;

- (void)startRunning;
- (void)stopRunning;
@end

@protocol YZTestCaptureDelegate <NSObject>

- (void)capture:(YZTestCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
