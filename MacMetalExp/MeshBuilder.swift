//
//  MeshBuilder.swift
//  MacMetalExp
//
//  Created by Carlos Mbendera on 09/01/2025.
//

import MetalKit

struct Mesh{
    //Makes it easier to bundle together data
    let vertexBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    let indexCount: Int
}

class MeshBuilder {
    
    let device: MTLDevice
    
    init(device: MTLDevice) {
        self.device = device
    }
    
    func makeTriangle() -> MTLBuffer {
        
        let vertices: [Vertex] = [
            Vertex(position: [-0.75, -0.75, 0.0, 1.0], color: [1,1.0, 1.0]),
            Vertex(position: [0.75, -0.75, 0.0, 1.0], color: [1.0,1.0, 1.0]),
            Vertex(position: [0.0, 0.75, 0.0, 1.0], color: [1,0.3, 0.7])
        ]
        
        return device.makeBuffer(bytes: vertices,
                                 length: vertices.count * MemoryLayout<Vertex>.stride)!
        
    }
    
    
    func makeQuad() -> Mesh {
        
        //Points in our quad
        let vertices: [Vertex] = [
            Vertex(position: [-0.75, -0.75, 0.0, 1.0], color: [1,1, 1]),
            Vertex(position: [0.75, -0.75, 0.0, 1.0], color: [1,1, 1]),
            Vertex(position: [0.75, 0.75, 0.0, 1.0], color: [1,1, 1]),
            Vertex(position: [-0.75, 0.75, 0.0, 1.0], color: [1,1,1])
        ]
        
        //Order in which we want to draw lines between points
        let indices: [UInt16] = [ 0, 1, 2, 2, 3, 0 ]
        
        
        //Making and combining the buffers for both the Vertices and indices
        let vertexBuffer = device.makeBuffer(bytes: vertices,
                                             length: vertices.count * MemoryLayout<Vertex>.stride)!
        
        let indexBuffer = device.makeBuffer(bytes: indices,
                                            length: indices.count * MemoryLayout<UInt16>.stride)!
        
        
        return Mesh(vertexBuffer: vertexBuffer,
                    indexBuffer: indexBuffer,
                    indexCount: indices.count)
    }
    
    func makeCube() -> Mesh {
        let s = Float(0.5)
        let vertices: [Vertex] = [
            Vertex(position: SIMD4<Float>(-s, -s,  s, 1), color: SIMD3<Float>(1, 0, 0)),
            Vertex(position: SIMD4<Float>( s, -s,  s, 1), color: SIMD3<Float>(0, 1, 0)),
            Vertex(position: SIMD4<Float>( s,  s,  s, 1), color: SIMD3<Float>(0, 0, 1)),
            Vertex(position: SIMD4<Float>(-s,  s,  s, 1), color: SIMD3<Float>(1, 1, 0)),
            Vertex(position: SIMD4<Float>(-s, -s, -s, 1), color: SIMD3<Float>(1, 0, 1)),
            Vertex(position: SIMD4<Float>( s, -s, -s, 1), color: SIMD3<Float>(0, 1, 1)),
            Vertex(position: SIMD4<Float>( s,  s, -s, 1), color: SIMD3<Float>(1, 1, 1)),
            Vertex(position: SIMD4<Float>(-s,  s, -s, 1), color: SIMD3<Float>(0, 0, 0))
        ]
        let indices: [UInt16] = [
            0,1,2,2,3,0,
            1,5,6,6,2,1,
            5,4,7,7,6,5,
            4,0,3,3,7,4,
            3,2,6,6,7,3,
            4,5,1,1,0,4
        ]
        let vb = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])!
        let ib = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.stride, options: [])!
        return Mesh(vertexBuffer: vb, indexBuffer: ib, indexCount: indices.count)
    }
    
}
