#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    /** kCVPixelFormatType_32BGRA  */
    YZVideoFormat32BGRA,
    /** kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange  */
    YZVideoFormat420YpCbCr8BiPlanarVideoRange,
    /** kCVPixelFormatType_420YpCbCr8BiPlanarFullRange  */
    YZVideoFormat420YpCbCr8BiPlanarFullRange,
    /** kCVPixelFormatType_420YpCbCr8Planar  */
    YZVideoFormat420YpCbCr8Planar,
    /** I420 */
    YZVideoFormatI420,
    /** NV21 */
    YZVideoFormatNV21,
} YZVideoFormat;

@interface YZVideoOptions : NSObject
/** see YZVideoFormat */
@property (nonatomic, assign) YZVideoFormat format;
/** YES: use YZVideoData's cropLeft, cropTop, cropRight, cropBottom to show video*/
@property (nonatomic, assign) BOOL renderCrop;

@end

