//
//  YZVideoDevice.m
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/12.
//

#import "YZVideoDevice.h"
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

@implementation YZVideoDevice

+ (BOOL)isDeviceSupport {
    return MPSSupportsMTLDevice(MTLCreateSystemDefaultDevice());
}

@end
