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
/** iphone6s 640x480 10fps
 1. Layer show           2-3%    29MB
 2. MTKView show         3-4%    33MB
 3. MTKView shader show  3-4%    38MB
 
 todo
 4. Layer BGRA nv12 show
 */
@interface YZRenderViewController ()<YZRenderCaptureDelegate>
@property (nonatomic, strong) YZRenderCapture *capture;

@property (nonatomic, strong) YZLayerView *layerView;
@property (nonatomic, strong) YZRenderMTKView *mtkView;
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
    
    
#if 0
    _mtkView = [[YZRenderMTKView alloc] initWithFrame:self.view.bounds];
    _mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mtkView];
#else
    _layerView = [[YZLayerView alloc] initWithFrame:self.view.bounds];
    _layerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_layerView];
#endif
    _capture = [[YZRenderCapture alloc] initWithPlayer:nil];
    _capture.delegate = self;
    [_capture startRunning];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    _mtkView = [[YZRenderMTKView alloc] initWithFrame:self.view.bounds];
//    _mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self.view addSubview:_mtkView];
}

#pragma mark - YZRenderCaptureDelegate
-(void)capture:(YZRenderCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
//    NSLog(@"todo");
    [_layerView displayVideo:pixelBuffer];
    

    [_mtkView displayVideo:pixelBuffer];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationController.navigationBarHidden = YES;
}
@end
