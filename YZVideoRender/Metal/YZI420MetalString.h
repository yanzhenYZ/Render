//
//  YZI420MetalString.h
//  YZVideoRender
//
//  Created by yanzhen on 2021/3/17.
//

#import <Foundation/Foundation.h>

const char* YZI420MetalString =
"using namespace metal;\n"

"constant half3x3 YZYUVDATAMAT = half3x3(half3(1.164,1.164,1.164),half3(0.0,-0.213,2.112),half3(1.793,-0.533,0.0));\n"
"struct YZYUVDataToRGBVertexIO\n"
"{\n"
"    float4 position [[position]];\n"
"    float2 textureCoordinate [[user(texturecoord)]];\n"
"    float2 textureCoordinate2 [[user(texturecoord2)]];\n"
"    float2 textureCoordinate3 [[user(texturecoord3)]];\n"
"};\n"


"vertex YZYUVDataToRGBVertexIO YZYUVDataToRGBVertex(const device packed_float2 *position [[buffer(0)]], const device packed_float2 *texturecoord [[buffer(1)]], const device packed_float2 *texturecoord2 [[buffer(2)]], const device packed_float2 *texturecoord3 [[buffer(3)]], uint vertexID [[vertex_id]])\n"
"{\n"
"    YZYUVDataToRGBVertexIO outputVertices;\n"
"    outputVertices.position = float4(position[vertexID], 0, 1.0);\n"
"    outputVertices.textureCoordinate = texturecoord[vertexID];\n"
"    outputVertices.textureCoordinate2 = texturecoord2[vertexID];\n"
"    outputVertices.textureCoordinate3 = texturecoord3[vertexID];\n"
"    return outputVertices;\n"
"}\n"

"fragment half4 YZYUVDataConversionFullRangeFragment(YZYUVDataToRGBVertexIO fragmentInput [[stage_in]], texture2d<half> inputTexture [[texture(0)]], texture2d<half> inputTexture2 [[texture(1)]], texture2d<half> inputTexture3 [[texture(2)]])\n"
"{\n"
"    constexpr sampler quadSampler;\n"
"    half3 yuv;\n"
"    yuv.x = inputTexture.sample(quadSampler, fragmentInput.textureCoordinate).r - (16.0/255.0);\n"
"    yuv.y = inputTexture2.sample(quadSampler, fragmentInput.textureCoordinate2).r - half(0.5);\n"
"    yuv.z = inputTexture3.sample(quadSampler, fragmentInput.textureCoordinate3).r - half(0.5);\n"
"    half3 rgb = YZYUVDATAMAT * yuv;\n"
"    return half4(rgb, 1.0);\n"
"}\n";
