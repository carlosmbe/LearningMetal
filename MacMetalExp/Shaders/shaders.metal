//
//  shaders.metal
//  MacMetalExp
//
//  Created by Carlos Mbendera on 06/01/2025.
//

#include "bridge.h"
#include <metal_stdlib>
using namespace metal;



vertex VertexOut vertexMain(
                            VertexIn v [[stage_in]],
                            constant Uniforms &uniforms[[buffer(2)]])
{
    VertexOut data;
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix
     * uniforms.modelMatrix * v.position;
   data.position = position;
    return data;
};

//Fragment Shader Receives the Output from the Vertex Shader as input
half4 fragment fragmentMain(){
    return half4(1, 1, 1.0, 1);
};

