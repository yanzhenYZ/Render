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
//@property (nonatomic, strong) YZVideoShow *videoShow;
@property (nonatomic, strong) YZVideoShow *display;
@end

@implementation YZPixelBufferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    YZVideoOptions *options = [[YZVideoOptions alloc] init];
//    options.output = YES;
//    if (VIDEOTYPE == 0) {
//        options.format = YZVideoFormat32BGRA;
//    } else if (VIDEOTYPE == 1) {
//        options.format = YZVideoFormat420YpCbCr8BiPlanarVideoRange;
//    } else if (VIDEOTYPE == 2) {
//        options.format = YZVideoFormat420YpCbCr8BiPlanarFullRange;
//    }
//    _videoShow = [[YZVideoShow alloc] initWithOptions:options];
//    _videoShow.delegate = self;
//    [_videoShow setVideoShowView:self.showPlayer];
    
    _display = [[YZVideoShow alloc] init];
    [_display setViewFillMode:YZVideoFillModeScaleAspectFit];
    [_display setVideoShowView:self.showPlayer];
    
    _capture = [[YZPixelBufferCapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_display setViewFillMode:YZVideoFillModeScaleAspectFit];
}
//#pragma mark - YZVideoShowDelegate
//- (void)videoShow:(YZVideoShow *)videoShow pixelBuffer:(CVPixelBufferRef)pixelBuffer {
//    NSLog(@"todo:%d:%d", CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
//}

#pragma mark - YZPixelBufferCaptureDelegate
- (void)capture:(YZPixelBufferCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    //NSLog(@"___%d", [YZVideoShow YZDeviceSupport]);
    YZVideoData *data = [[YZVideoData alloc] init];
    data.pixelBuffer = pixelBuffer;
    data.rotation = [self getOutputRotation];
    data.cropTop = 60;
    data.cropBottom = 60;
    data.format = YZVideoFormatPixelBuffer;
    [_display displayVideo:data];
}

- (YZVideoRotation)getOutputRotation {//test code
    YZVideoRotation ratation = YZVideoRotation0;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return YZVideoRotation90;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return YZVideoRotation270;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return YZVideoRotation180;
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
