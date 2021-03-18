//
//  YZVideoY420Filter.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/18.
//

#import "YZVideoY420Filter.h"

@implementation YZVideoY420Filter
- (void)displayVideo:(YZVideoData *)videoData {
    [self.player showBuffer:videoData];
}
@end
