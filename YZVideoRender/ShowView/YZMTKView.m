//
//  YZMTKView.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/7.
//

#import "YZMTKView.h"

@interface YZMTKView ()

@end

@implementation YZMTKView

- (instancetype)initWithFrame:(CGRect)frameRect device:(id<MTLDevice>)device {
    self = [super initWithFrame:frameRect device:device];
    if (self) {
        self.paused = YES;
        self.framebufferOnly = NO;
        self.enableSetNeedsDisplay = NO;
        //self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}
@end
