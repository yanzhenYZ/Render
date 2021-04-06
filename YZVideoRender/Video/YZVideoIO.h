//
//  YZVideoIO.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/6.
//

#import <UIKit/UIKit.h>
#import "YZVideoData.h"

@interface YZVideoIO : NSObject

- (void)displayVideo:(YZVideoData *)videoData;

- (void)setVideoShowViewInMainThread:(UIView *)view;
@end


