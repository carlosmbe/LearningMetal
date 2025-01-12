//
//  shaders.metal
//  MacMetalExp
//
//  Created by Carlos Mbendera on 06/01/2025.
//

#include "bridge.h"
#include <metal_stdlib>
using namespace metal;


struct VertexOutput {
    //Similar to how we qualify the Vertex and Fragment shader, we can qualify variables, hence the [[___]]
    //Here, we're telling Metal that this varibale is the actual position and some cool things happen under the hood
    float4 position [[position]];
    half3 color;
};

//Now we have a pointer to our Vertex Buffer as part of the Vertex Shader. Also, we qualify it as a buffer at Index 0
VertexOutput vertex vertexMain(const device Vertex* vertices [[buffer(0)]],
                               uint vertexID [[vertex_id]],
                               constant Uniforms &uniforms [[buffer(1)]])
{
    //Instead of just loading the values from an array, we're now reading from the Vertex Struct we created earlier
    Vertex v = vertices[vertexID];
    VertexOutput data;
    
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix
     * uniforms.modelMatrix * v.position;
    
   data.position = position;
    
   // data.position = v.position;
    data.color = half3(v.color);
    return data;
};

//Fragment Shader Receives the Output from the Vertex Shader as input
half4 fragment fragmentMain(VertexOutput frag [[stage_in]]){
    //Similarly we're qualifiying the input as a [[stage_in]]
    return half4(frag.color, 1.0);
    //Return Color as is, with an alpha of 1
};


