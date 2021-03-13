//
//  YZVFOrientation.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/13.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MetalKit/MetalKit.h>

extern float *kYZColorConversion601;
extern float *kYZColorConversion601FullRange;
extern float *kYZColorConversion709;

@interface YZVFOrientation : NSObject

+ (simd_float8)defaultVertices;
+ (simd_float8)defaultTextureCoordinates;
+ (simd_float8)getRotationTextureCoordinates:(int)rotation;

+ (simd_float8)getCropRotationTextureCoordinates:(int)rotation crop:(CGRect)crop;

@end


