//
//  shader.metal
//  aa
//
//  Created by M.Ike on 2016/07/26.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>



struct VertexInput {
    float4 position [[ attribute(SCNVertexSemanticPosition) ]];
};

struct NodeBuffer {
    float4x4 modelViewProjectionTransform;
};

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
};


vertex VertexOut depthVertex(VertexInput in [[ stage_in ]],
                            constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                            constant NodeBuffer& scn_node [[ buffer(1) ]]) {
    VertexOut out;
    out.position = in.position;
    
    out.texcoord = (float2(in.position.x, -in.position.y) + 1.0) * 0.5;
    
    return out;
}

fragment half4 depthFragment(VertexOut in [[ stage_in ]],
                            texture2d<float, access::sample> colorSampler [[ texture(0) ]],
                            texture2d<float, access::sample> depthSampler [[ texture(1) ]]) {
    constexpr sampler repeatSampler = sampler(coord::normalized,
                                              address::repeat,
                                              filter::linear);

    auto out = depthSampler.sample(repeatSampler, in.texcoord);
    out.g = out.b = out.r;
    out.a = 1;
    return half4(out);
}