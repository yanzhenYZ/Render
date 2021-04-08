//
//  YZDataViewController.m
//  MetalRender
//
//  Created by yanzhen on 2021/3/17.
//

#import "YZDataViewController.h"
#import "YZDataCapture.h"
#import <YZVideoRender/YZVideoRender.h>

#define I420 0

@interface YZDataViewController ()<YZDataCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;

@property (nonatomic, strong) YZDataCapture *capture;
@property (nonatomic, strong) YZVideoShow *display;
@end

@implementation YZDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    YZVideoOptions *options = [[YZVideoOptions alloc] init];
//    options.output = YES;
//#if I420
//    options.format = YZVideoFormatI420;
//#else
//    options.format = YZVideoFormatNV21;
//#endif
//    _videoShow = [[YZVideoShow alloc] initWithOptions:options];
//    [_videoShow setVideoShowView:self.showPlayer];
    
    _display = [[YZVideoShow alloc] init];
    [_display setViewFillMode:YZVideoFillModeScaleAspectFit];
    [_display setVideoShowView:self.showPlayer];
    
    _capture = [[YZDataCapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
}

#pragma mark - YZDataCaptureDelegate
- (void)capture:(YZDataCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
#if I420
    [self testI420:pixelBuffer];
#else
    [self testNV21:pixelBuffer];
#endif
    
}


- (void)testNV21:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t yWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t yheight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    int8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    size_t yBytesPow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    
    size_t uvheight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    int8_t *uvBuffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    size_t uvBytesPow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    YZVideoData *data = [[YZVideoData alloc] init];
    data.format = YZVideoFormatNV12;
    data.width = (int)CVPixelBufferGetWidth(pixelBuffer);
    data.height = (int)CVPixelBufferGetHeight(pixelBuffer);
    data.yStride = (int)yBytesPow;
    data.yBuffer = yBuffer;
    
    data.uvStride = (int)uvBytesPow;
    data.uvBuffer = uvBuffer;
    
    data.cropTop = 60;
    data.cropBottom = 60;
    data.rotation = [self getOutputRotation];
    [_display displayVideo:data];
//    [_videoShow displayVideo:data];
}

- (void)testI420:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t yWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
    size_t yheight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
    int8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    size_t yBytesPow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    //NSLog(@"___1234:%d:%d:%d", yWidth, yheight, yBytesPow);
    
    //size_t uvWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
    size_t uvheight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    int8_t *uvBuffer = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    size_t uvBytesPow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    //NSLog(@"___1234:%d:%d:%d", uvWidth, uvheight, uvBytesPow);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    YZVideoData *data = [[YZVideoData alloc] init];
    data.format = YZVideoFormatI420;
    data.width = (int)yWidth;
    data.height = (int)yheight;
    data.yStride = (int)yBytesPow;
    data.yBuffer = yBuffer;
    
    int8_t *uBuffer = malloc(uvBytesPow * uvheight / 2);
    int8_t *vBuffer = malloc(uvBytesPow * uvheight / 2);
    
    for (int i = 0; i < uvBytesPow * uvheight / 2; i++) {
        uBuffer[i] = uvBuffer[2*i];
        vBuffer[i] = uvBuffer[2*i+1];
    }
    data.format = YZVideoFormatI420;
    data.uStride = uvBytesPow / 2;
    data.uBuffer = uBuffer;
    data.vStride = uvBytesPow / 2;
    data.vBuffer = vBuffer;
    data.rotation = [self getOutputRotation];
    data.cropTop = 60;
    data.cropBottom = 60;
    [_display displayVideo:data];
    
    free(uBuffer);
    free(vBuffer);
}

- (void)test:(CVPixelBufferRef)pixelBuffer  {
    YZVideoData *data = [[YZVideoData alloc] init];
    data.pixelBuffer = pixelBuffer;
    data.rotation = [self getOutputRotation];
//    [_videoShow displayVideo:data];
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
