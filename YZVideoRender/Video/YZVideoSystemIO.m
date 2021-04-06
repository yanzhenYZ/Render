//
//  YZVideoSystemIO.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/6.
//

#import "YZVideoSystemIO.h"
#import "YZSystemPlayer.h"

@interface YZVideoSystemIO ()
@property (nonatomic, strong) YZSystemPlayer *player;
@end

@implementation YZVideoSystemIO
- (void)displayVideo:(YZVideoData *)videoData {
    if (videoData.pixelBuffer) {
        [_player displayVideo:videoData.pixelBuffer];
    } else {
        NSLog(@"todo--001");
    }
}

- (void)setVideoShowViewInMainThread:(UIView *)view {
    if (_player.superview) {
        [_player removeFromSuperview];
    }
    if (view) {
        [view addSubview:self.player];
        self.player.frame = view.bounds;
    } else {
        _player = nil;
    }
}

- (void)setContentModeInMainThread:(UIViewContentMode)contentMode {
    _player.contentMode = contentMode;
}
#pragma mark - lazy var
- (YZSystemPlayer *)player {
    if (!_player) {
        _player = [[YZSystemPlayer alloc] init];
        _player.backgroundColor = UIColor.blackColor;
        _player.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _player;
}
@end
