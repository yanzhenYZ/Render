//
//  YZDataViewController.m
//  MetalRender
//
//  Created by yanzhen on 2021/3/17.
//

#import "YZDataViewController.h"
#import "YZDataCapture.h"
#import <YZVideoRender/YZVideoRender.h>

@interface YZDataViewController ()<YZDataCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;

@property (nonatomic, strong) YZDataCapture *capture;
@property (nonatomic, strong) YZVideoShow *videoShow;
@end

@implementation YZDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    YZVideoOptions *options = [[YZVideoOptions alloc] init];
    if (VIDEOTYPE == 0) {
        options.format = YZVideoFormat32BGRA;
    } else if (VIDEOTYPE == 1) {
        options.format = YZVideoFormat420YpCbCr8BiPlanarVideoRange;
    } else if (VIDEOTYPE == 2) {
        options.format = YZVideoFormat420YpCbCr8BiPlanarFullRange;
    }
    _videoShow = [[YZVideoShow alloc] initWithOptions:options];
    [_videoShow setVideoShowView:self.showPlayer];
    
    _capture = [[YZDataCapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
}

#pragma mark - YZDataCaptureDelegate
- (void)capture:(YZDataCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    //NSLog(@"___%d", [YZVideoShow YZDeviceSupport]);
    [self test:pixelBuffer];
}

//todo
- (void)testI420:(CVPixelBufferRef)pixelBuffer {
    
}

- (void)test:(CVPixelBufferRef)pixelBuffer  {
    YZVideoData *data = [[YZVideoData alloc] init];
    data.pixelBuffer = pixelBuffer;
    data.rotation = [self getOutputRotation];
    [_videoShow displayVideo:data];
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
