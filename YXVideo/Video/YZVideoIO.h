//
//  YZVideoIO.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/6.
//

#import <UIKit/UIKit.h>
#import "YZVideoDevice.h"
#import "YXVideoData.h"

@interface YZVideoIO : NSObject
@property (nonatomic, strong) YZVideoDevice *device;

- (void)displayVideo:(YXVideoData *)videoData;

- (void)setVideoShowViewInMainThread:(UIView *)view;

-(void)setContentModeInMainThread:(UIViewContentMode)contentMode;
@end


