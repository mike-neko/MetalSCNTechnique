//
//  drop.metal
//  MetalSCNTechnique
//
//  Created by M.Ike on 2016/07/13.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>



struct VertexInput {
    float4 position [[ attribute(SCNVertexSemanticPosition) ]];
    float2 texcoord [[ attribute(SCNVertexSemanticTexcoord0) ]];
};

struct NodeBuffer {
    float4x4 modelViewProjectionTransform;
};

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
    float time;
};


vertex VertexOut dropVertex(VertexInput in [[ stage_in ]],
                            constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                            constant NodeBuffer& scn_node [[ buffer(1) ]]) {
    VertexOut out;
    out.position = in.position;
    
    out.texcoord = float2(in.texcoord.x, -in.texcoord.y);

    out.time = scn_frame.time * 0.1;
    
    return out;
}

fragment half4 dropFragment(VertexOut in [[ stage_in ]],
                            texture2d<float, access::sample> texture [[ texture(0) ]],
                            texture2d<float, access::sample> normalTexture [[ texture(1) ]]) {
    constexpr sampler repeatSampler = sampler(coord::normalized,
                                              address::repeat,
                                              filter::linear);

    // 縦横比固定を想定
    auto x = in.texcoord.x;
    auto y = in.texcoord.y * (float)texture.get_height() / (float)texture.get_width();
    y -= in.time;

    auto uv = fract(float2(x, y));
    auto normal = normalTexture.sample(repeatSampler, uv) * 2 - 1;
    auto texcoord = clamp(in.texcoord + normal.xy * 0.05, float2(0, -0.9), float2(1, -0.1));

    auto out = texture.sample(repeatSampler, texcoord);
    out.a = 1;
    return half4(out);
}

