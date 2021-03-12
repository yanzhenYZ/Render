//
//  YZVideoData.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

typedef enum : NSUInteger {
    YZVideoRotation0   = 0,
    YZVideoRotation90  = 90,
    YZVideoRotation180 = 180,
    YZVideoRotation270 = 270,
} YZVideoRotation;

@interface YZVideoData : NSObject
/** only use when you set YZVideoOptions.format = YZVideoFormatTexture */
@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;

/** input video width */
@property (assign, nonatomic) int width;

/** input video heigth */
@property (assign, nonatomic) int height;


/** crop video left */
@property (assign, nonatomic) int cropLeft;

/** crop video top */
@property (assign, nonatomic) int cropTop;

/** crop video right */
@property (assign, nonatomic) int cropRight;

/** crop video bottom */
@property (assign, nonatomic) int cropBottom;


/** set the video rotation degree */
@property (assign, nonatomic) YZVideoRotation rotation;


/** I420 or NV12 y stride */
@property (nonatomic) int yStride;

/** I420 u stride */
@property (nonatomic) int uStride;

/** I420 v stride */
@property (nonatomic) int vStride;

/** NV12 uv stride */
@property (nonatomic) int uvStride;


/** I420 or NV12 y buffer */
@property (nonatomic) int8_t *yBuffer;

/** I420 u buffer */
@property (nonatomic) int8_t *uBuffer;

/** I420 v buffer */
@property (nonatomic) int8_t *vBuffer;

/** NV12 uv buffer */
@property (nonatomic) int8_t *uvBuffer;
@end

