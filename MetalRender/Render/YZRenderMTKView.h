//
//  YZRenderMTKView.h
//  MetalRender
//
//  Created by yanzhen on 2021/3/23.
//

#import <MetalKit/MetalKit.h>

@interface YZRenderMTKView : MTKView

- (void)displayVideo:(CVPixelBufferRef)pixelBuffer;

@end


