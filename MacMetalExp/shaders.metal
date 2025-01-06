//
//  shaders.metal
//  MacMetalExp
//
//  Created by Carlos Mbendera on 06/01/2025.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOutput {
    //Similar to how we qualify the Vertex and Fragment shader, we can qualify variables, hence the [[___]]
    //Here, we're telling Metal that this varibale is the actual position and some cool things happen under the hood
    float4 position [[position]];
    half3 color;
};

//Hard coded data for learning purposes, don't this in real projects
constant float4 positions[] = {
    //X -1== Left, 1 == Right, 0 == Centre
    float4(-0.75, -0.75, 0.0, 1.0), //Bottom Left
    float4(0.75, -0.75, 0.0, 1.0), //Bottom Right
    float4(0.0, 0.75, 0.0, 1.0), //Centre Top
};

constant half3 colors[] = {
    //RGB
    half3(1,0.0, 1.0), //Bottom Left
    half3(0.0, 0.0, 1.0), //Bottom Right
    half3(1.0,1.0, 1.0) //Centre Top
};

//Vertex ID is the index of the current Vertex
VertexOutput vertex vertexMain(uint vertexID [[vertex_id]]){
    VertexOutput data;
    data.position = positions[vertexID];
    data.color = colors[vertexID];
    return data;
};

//Fragment Shader Receives the Output from the Vertex Shader as input
half4 fragment fragmentMain(VertexOutput frag [[stage_in]]){
    //Similarly we're qualifiying the input as a [[stage_in]]
    return half4(frag.color, 1.0);
    //Return Color as is, with an alpha of 1
};


