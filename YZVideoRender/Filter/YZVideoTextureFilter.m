//
//  YZVideoTextureFilter.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoTextureFilter.h"

@implementation YZVideoTextureFilter

- (void)displayVideo:(YZVideoData *)videoData {
    [self.player showBuffer:videoData];
}

@end
