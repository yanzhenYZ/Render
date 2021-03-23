//
//  YZRenderViewController.m
//  MetalRender
//
//  Created by yanzhen on 2021/3/23.
//

#import "YZRenderViewController.h"
#import "YZLayerView.h"
#import "YZRenderMTKView.h"
#import "YZRenderCapture.h"
/**todo
 1. Layer show
 2. MTKView show
 3. MTKView shader show
 4. BGRA nv12 show
 */
@interface YZRenderViewController ()<YZRenderCaptureDelegate>
@property (nonatomic, strong) YZRenderCapture *capture;
@end

@implementation YZRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    YZVideoOptions *options = [[YZVideoOptions alloc] init];
//#if I420
//    options.format = YZVideoFormatI420;
//#else
//    options.format = YZVideoFormatNV21;
//#endif
//    _videoShow = [[YZVideoShow alloc] initWithOptions:options];
//    [_videoShow setVideoShowView:self.showPlayer];
    
    _capture = [[YZRenderCapture alloc] initWithPlayer:self.view];
    _capture.delegate = self;
    [_capture startRunning];
}

#pragma mark - YZRenderCaptureDelegate
-(void)capture:(YZRenderCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    NSLog(@"todo");
}





-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
@end
