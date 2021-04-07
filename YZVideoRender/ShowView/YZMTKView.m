//
//  YZMTKView.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/4/7.
//

#import "YZMTKView.h"

@interface YZMTKView ()<MTKViewDelegate>

@end

@implementation YZMTKView

- (instancetype)initWithFrame:(CGRect)frameRect device:(id<MTLDevice>)device {
    self = [super initWithFrame:frameRect device:device];
    if (self) {
        self.paused = YES;
        self.delegate = self;
        self.framebufferOnly = NO;
        self.enableSetNeedsDisplay = NO;
        //self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

#pragma mark - MTKViewDelegate
- (void)drawInMTKView:(MTKView *)view {
    NSLog(@"todo_0_bgra");
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}
@end
