//
//  YZVideoDisplay.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/6.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YZVideoFillMode) {
    YZVideoFillModeScaleToFill,     /** Same as UIViewContentModeScaleToFill */
    YZVideoFillModeScaleAspectFit,  /** Same as UIViewContentModeScaleAspectFit */
    YZVideoFillModeScaleAspectFill, /** Same as UIViewContentModeScaleAspectFill */
};

@class YZVideoData;
@interface YZVideoDisplay : NSObject
/**
 *  isSupportAdditionalFeatures
 *  @abstract   The additional features contain YZVideoData's cropLeft, cropTop, cropRight, cropBottom and rotation.
 *
 *  @return     YES             The device is supported.
 *              NO              The device is not supported
 */
+ (BOOL)isSupportAdditionalFeatures;

- (void)setVideoShowView:(UIView *)view; //set video show view
- (void)setViewFillMode:(YZVideoFillMode)mode; //see YZVideoFillMode

- (void)displayVideo:(YZVideoData *)videoData; //show video
@end


