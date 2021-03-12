//
//  YZPixelBufferViewController.m
//  MetalRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZPixelBufferViewController.h"
#import "YZPixelBufferCapture.h"

@interface YZPixelBufferViewController ()<YZPixelBufferCaptureDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *mainPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *showPlayer;

@property (nonatomic, strong) YZPixelBufferCapture *capture;
@end

@implementation YZPixelBufferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _capture = [[YZPixelBufferCapture alloc] initWithPlayer:_mainPlayer];
    _capture.delegate = self;
    [_capture startRunning];
}

#pragma mark - YZPixelBufferCaptureDelegate
- (void)capture:(YZPixelBufferCapture *)capture pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
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
