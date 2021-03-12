//
//  YZVideoOptions.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    /*!
     Support CVPixelBuffer type
     1. kCVPixelFormatType_32BGRA
     2. kCVPixelFormatType_420YpCbCr8Planar
     3. kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
     4. kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
     */
    YZVideoFormatTexture,
    /** I420 */
    YZVideoFormatI420,
    /** NV12 */
    YZVideoFormatNV12,
} YZVideoFormat;

@interface YZVideoOptions : NSObject

@property (nonatomic, assign) YZVideoFormat format;

@end

