//
//  YZVideoRangeFilter.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/17.
//

#import "YZVideoRangeFilter.h"

@implementation YZVideoRangeFilter
- (void)displayVideo:(YZVideoData *)videoData {
    [self.player showBuffer:videoData];
}
@end
