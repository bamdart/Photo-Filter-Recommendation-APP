//
//  MTHelenaVideoFilter.metal
//  MetalFilters
//
//  Created by alexiscn on 2018/6/8.
//

#include <metal_stdlib>
#include "MTIShaderLib.h"
#include "IFShaderLib.h"
using namespace metalpetal;

fragment float4 MTHelenaVideoFragment(VertexOut vertexIn [[ stage_in ]], 
    texture2d<float, access::sample> inputTexture [[ texture(0) ]], 
    texture2d<float, access::sample> map1 [[ texture(1) ]], 
    texture2d<float, access::sample> map2 [[ texture(2) ]], 
    constant float & strength [[ buffer(0)]], 
    sampler textureSampler [[ sampler(0) ]])
{
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    float4 texel = inputTexture.sample(s, vertexIn.textureCoordinate);
    float4 inputTexel = texel;
    // saturation boost
    float luma = dot(float3(0.2126, 0.7152, 0.0722), texel.rgb);
    texel.rgb = mix(texel.rgb, float3(luma), -0.17);

    // apply curves
    texel.r = map1.sample(s, float2(texel.r, 0.5)).r;
    texel.g = map1.sample(s, float2(texel.g, 0.5)).g;
    texel.b = map1.sample(s, float2(texel.b, 0.5)).b;

    // contrast boost - darken shadows with original luma
    texel.rgb = mix(texel.rgb, texel.rgb * texel.rgb, 0.8 * (1.0 - luma));
    // slight boost to highlights
    texel.rgb = mix(texel.rgb, texel.rgb * 1.1, max(0.0, luma - 0.5));

    // apply curves2
    texel.r = map2.sample(s, float2(texel.r, 0.5)).r;
    texel.g = map2.sample(s, float2(texel.g, 0.5)).g;
    texel.b = map2.sample(s, float2(texel.b, 0.5)).b;
    texel.rgb = mix(inputTexel.rgb, texel.rgb, strength);
    return texel;
}
