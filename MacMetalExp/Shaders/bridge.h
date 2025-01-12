//
//  bridge.h
//  MacMetalExp
//
//  Created by Carlos Mbendera on 09/01/2025.
//

#ifndef bridge_h
#define bridge_h
#include <simd/simd.h>

struct Vertex{
    vector_float4 position;
    vector_float3 color;
};

struct Uniforms{
  matrix_float4x4 modelMatrix;
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
};

#endif /* bridge_h */
