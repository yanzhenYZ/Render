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
 
 4. Layer BGRA nv12 show
  1. BGRA
  2. NV21
  3. I420
 */
@interface YZRenderViewController ()<YZRenderCaptureDelegate>
@property (nonatomic, strong) YZRenderCapture *capture;

@property (nonatomic, strong) YZLayerView *layerView;
@property (nonatomic, strong) YZRenderMTKView *mtkView;

@property (nonatomic, assign) CGSize size;
@end

@implementation YZRenderViewController {
    CVPixelBufferRef _pixelBuffer;
}

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
#if 1
    [self testI420PixelBuffer:pixelBuffer];
#else
    [_layerView displayVideo:pixelBuffer];
    [_mtkView displayVideo:pixelBuffer];
#endif
}


- (void)testI420PixelBuffer:(CVPixelBufferRef)pixelBuffer {
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    [self newDealTextureSize:CGSizeMake(width, height)];
    if (!_pixelBuffer) {
        NSLog(@"error---NO");
        return;
    }
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
    //todo 绿边
    CVPixelBufferLockBaseAddress(_pixelBuffer, 0);
    int8_t *yB = CVPixelBufferGetBaseAddressOfPlane(_pixelBuffer, 0);
    int8_t *uB = CVPixelBufferGetBaseAddressOfPlane(_pixelBuffer, 1);
    int8_t *vB = CVPixelBufferGetBaseAddressOfPlane(_pixelBuffer, 2);
    memcpy(yB, yBuffer, width * height);
    memcpy(uB, uBuffer, width * height / 4);
    memcpy(vB, vBuffer, width * height / 4);
    CVPixelBufferUnlockBaseAddress(_pixelBuffer, 0);
    
    [_layerView displayVideo:_pixelBuffer];
    
    free(uBuffer);
    free(vBuffer);
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
@end
