//
//  YZFullRangeFilter.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/17.
//

#import "YZFullRangeFilter.h"

@implementation YZFullRangeFilter
- (void)displayVideo:(YZVideoData *)videoData {
    [self.player showBuffer:videoData];
}
@end
