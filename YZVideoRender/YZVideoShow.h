//
//  YZVideoShow.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import <UIKit/UIKit.h>

@class YZVideoData;
@class YZVideoOptions;
@interface YZVideoShow : NSObject
/**
 *  YZDeviceSupport
 *  @abstract   Determine whether a YZVideoRender.framework supports the device.
 *  @discussion Use this function to determine whether the device can be used in YZVideoRender.framework.
 *
 *  @return     YES             The device is supported.
 *              NO              The device is not supported
 */
+ (BOOL)YZDeviceSupport;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithOptions:(YZVideoOptions *)options;

- (void)setVideoPlayer:(UIView *)player;

- (void)displayVideo:(YZVideoData *)videoData;
@end


