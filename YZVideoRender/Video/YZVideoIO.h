//
//  YZVideoIO.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/6.
//

#import <UIKit/UIKit.h>
#import "YZVideoDevice.h"
#import "YZVideoData.h"

@interface YZVideoIO : NSObject
@property (nonatomic, strong) YZVideoDevice *device;

- (void)displayVideo:(YZVideoData *)videoData;

- (void)setVideoShowViewInMainThread:(UIView *)view;

-(void)setContentModeInMainThread:(UIViewContentMode)contentMode;
@end


