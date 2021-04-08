//
//  YZPixelBufferViewController.m
//  MetalRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZPixelBufferViewController.h"
#import "YZPixelBufferCapture.h"
#import <YXVideo/YXVideo.h>

@interface YZPixelBufferViewController ()<YZPixelBufferCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;

@property (nonatomic, strong) YZPixelBufferCapture *capture;
//@property (nonatomic, strong) YXVideoShow *videoShow;
@property (nonatomic, strong) YXVideoShow *display;
@end

@implementation YZPixelBufferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    YZVideoOptions *options = [[YZVideoOptions alloc] init];
//    options.output = YES;
//    if (VIDEOTYPE == 0) {
//        options.format = YXVideoFormat32BGRA;
//    } else if (VIDEOTYPE == 1) {
//        options.format = YXVideoFormat420YpCbCr8BiPlanarVideoRange;
//    } else if (VIDEOTYPE == 2) {
//        options.format = YXVideoFormat420YpCbCr8BiPlanarFullRange;
//    }
//    _videoShow = [[YXVideoShow alloc] initWithOptions:options];
//    _videoShow.delegate = self;
//    [_videoShow setVideoShowView:self.showPlayer];
    
    _display = [[YXVideoShow alloc] init];
    [_display setViewFillMode:YXVideoFillModeScaleAspectFit];
    [_display setVideoShowView:self.showPlayer];
    
    _capture = [[YZPixelBufferCapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_display setViewFillMode:YXVideoFillModeScaleAspectFit];
}
//#pragma mark - YXVideoShowDelegate
//- (void)videoShow:(YXVideoShow *)videoShow pixelBuffer:(CVPixelBufferRef)pixelBuffer {
//    NSLog(@"todo:%d:%d", CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
//}

#pragma mark - YZPixelBufferCaptureDelegate
- (void)capture:(YZPixelBufferCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    //NSLog(@"___%d", [YXVideoShow YZDeviceSupport]);
    YXVideoData *data = [[YXVideoData alloc] init];
    data.pixelBuffer = pixelBuffer;
    data.rotation = [self getOutputRotation];
    data.cropTop = 60;
    data.cropBottom = 60;
    data.mirror = YES;
    data.format = YXVideoFormatPixelBuffer;
    [_display displayVideo:data];
}

- (YXVideoRotation)getOutputRotation {//test code
    YXVideoRotation ratation = YXVideoRotation0;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return YXVideoRotation90;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return YXVideoRotation270;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return YXVideoRotation180;
            break;
        default:
            break;
    }
    return ratation;
    
}
#pragma mark - UI
- (IBAction)exitCapture:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

@end
