//
//  YZVideoFilter.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import <UIKit/UIKit.h>
#import "YZVideoPlayer.h"
#import "YZVideoData.h"

@interface YZVideoFilter : NSObject
@property (nonatomic, weak) YZVideoPlayer *player;

- (void)displayVideo:(YZVideoData *)videoData;

@end

