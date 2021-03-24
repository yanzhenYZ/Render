//
//  YZTestViewController.m
//  MetalRender
//
//  Created by yanzhen on 2021/3/18.
//

#import "YZTestViewController.h"
#import "YZTestCapture.h"
#import <YZVideoRender/YZVideoRender.h>

@interface YZTestViewController ()<YZTestCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, strong) YZTestCapture *capture;
@property (nonatomic, strong) YZVideoShow *videoShow;
@end

@implementation YZTestViewController {
    CVPixelBufferRef _pixelBuffer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    YZVideoOptions *options = [[YZVideoOptions alloc] init];
    options.format = YZVideoFormat420YpCbCr8Planar;
    
    _videoShow = [[YZVideoShow alloc] initWithOptions:options];
    [_videoShow setVideoShowView:self.showPlayer];
    
    _capture = [[YZTestCapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
}

- (void)newDealTextureSize:(CGSize)size {
    if (!CGSizeEqualToSize(_size, size)) {
        if (_pixelBuffer) {
            CVPixelBufferRelease(_pixelBuffer);
            _pixelBuffer = nil;
        }
        _size = size;
    }
    
    if (_pixelBuffer) { return; }
    NSDictionary *pixelAttributes = @{(NSString *)kCVPixelBufferIOSurfacePropertiesKey:@{}};
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                            _size.width,
                                            _size.height,
                                            kCVPixelFormatType_420YpCbCr8Planar,
                                            (__bridge CFDictionaryRef)(pixelAttributes),
                                            &_pixelBuffer);
    if (result != kCVReturnSuccess) {
        NSLog(@"YZBGRAPixelBuffer to create cvpixelbuffer %d", result);
        return;
    }
    size_t count = CVPixelBufferGetPlaneCount(_pixelBuffer);
    size_t y = CVPixelBufferGetBytesPerRowOfPlane(_pixelBuffer, 0);
    size_t u = CVPixelBufferGetBytesPerRowOfPlane(_pixelBuffer, 1);
    size_t v = CVPixelBufferGetBytesPerRowOfPlane(_pixelBuffer, 2);
    
//    size_t y = CVPixelBufferGetHeightOfPlane(_pixelBuffer, 0);
//    size_t u = CVPixelBufferGetHeightOfPlane(_pixelBuffer, 1);
//    size_t v = CVPixelBufferGetHeightOfPlane(_pixelBuffer, 2);
    
    NSLog(@"____%d:%d:%d", y, u, v);
}

#pragma mark - YZDataCaptureDelegate
- (void)capture:(YZTestCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
//todo
    //[self testI420:pixelBuffer];
    [self testIII:pixelBuffer];
}

- (void)testIII:(CVPixelBufferRef)pixelBuffer {
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    [self newDealTextureSize:CGSizeMake(width, height)];
    if (!_pixelBuffer) {
        NSLog(@"error---NO");
        return;
    }
//    return;
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
    int8_t *uBuffer = malloc(uvBytesPow * uvheight / 2);
    int8_t *vBuffer = malloc(uvBytesPow * uvheight / 2);
    
    for (int i = 0; i < uvBytesPow * uvheight / 2; i++) {
        uBuffer[i] = uvBuffer[2*i];
        vBuffer[i] = uvBuffer[2*i+1];
    }
    //local
    CVPixelBufferLockBaseAddress(_pixelBuffer, 0);
    int8_t *yB = CVPixelBufferGetBaseAddressOfPlane(_pixelBuffer, 0);
    int8_t *uB = CVPixelBufferGetBaseAddressOfPlane(_pixelBuffer, 1);
    int8_t *vB = CVPixelBufferGetBaseAddressOfPlane(_pixelBuffer, 2);
    memcpy(yB, yBuffer, width * height);
    memcpy(uB, uBuffer, width * height / 4);
    memcpy(vB, vBuffer, width * height / 4);
    CVPixelBufferUnlockBaseAddress(_pixelBuffer, 0);
    
    YZVideoData *data = [[YZVideoData alloc] init];
    data.pixelBuffer = _pixelBuffer;
    data.rotation = [self getOutputRotation];
    data.cropTop = 60;
    data.cropBottom = 60;
    [_videoShow displayVideo:data];
    
    free(uBuffer);
    free(vBuffer);
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
    
    data.uStride = uvBytesPow / 2;
    data.uBuffer = uBuffer;
    data.vStride = uvBytesPow / 2;
    data.vBuffer = vBuffer;
    data.rotation = [self getOutputRotation];
    [_videoShow displayVideo:data];
    
    free(uBuffer);
    free(vBuffer);
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
