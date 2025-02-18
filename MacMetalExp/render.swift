 //
//  render.swift
//  MacMetalExp
//
//  Created by Carlos Mbendera on 28/12/2024.
//

import MetalKit
import ModelIO

class Renderer: NSObject {
    // Metal objects.
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipeline: MTLRenderPipelineState!
    
    // Uniforms (you already have this defined)
    var uniforms = Uniforms()
    
    // Mesh properties.
    let allocator: MTKMeshBufferAllocator
    let asset: MDLAsset
    let mdlMesh: MDLMesh
    let mesh: MTKMesh
    
    // Animation timer.
    var timer: Float = 0
    
    // Initializer now simply receives a device.
    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        
        // Set up mesh-related properties.
        allocator = MTKMeshBufferAllocator(device: device)
        // Update the URL/resource name as needed.
        let url = Bundle.main.url(forResource: "12221_Cat_v1_l3", withExtension: "obj")!
        asset = MDLAsset(url: url,
                         vertexDescriptor: .defaultLayout,
                         bufferAllocator: allocator)
        mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        
        super.init()
        
        // Set up initial uniforms.
        uniforms = setUpUniforms()
    }
    
    // Set up your pipeline (move pipeline creation code from your init).
    func setUpPipeline() {
        pipeline = buildPipeline(device: device)
    }
    
    // New render function that accepts a CAMetalLayer.
    func render(to metalLayer: CAMetalLayer) {
        guard let drawable = metalLayer.nextDrawable() else { return }
        
        // Create a command buffer.
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
        // Create a render pass descriptor manually.
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        
        // (Optional) Animate your background color.
        timer += 0.005
       
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: Double(0),
            green: Double(0),
            blue: Double(0),
            alpha: 0
        )
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        // Create a render command encoder.
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        // Update model transformation (for rotation, etc.).
        let rotation = float4x4(
            SIMD4<Float>(cos(timer), 0, sin(timer), 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(-sin(timer), 0, cos(timer), 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
        // Here we’re just using an identity translation.
        let translation = float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
        uniforms.modelMatrix = matrix_multiply(translation, rotation)
        
        // Set up render state.
        renderEncoder.setCullMode(.back)
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<Uniforms>.stride,
                                     index: 2)
        renderEncoder.setRenderPipelineState(pipeline)
        
        // Set vertex buffer for the mesh.
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer,
                                      offset: 0,
                                      index: 0)
        
        // Draw each submesh.
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: submesh.indexCount,
                indexType: submesh.indexType,
                indexBuffer: submesh.indexBuffer.buffer,
                indexBufferOffset: submesh.indexBuffer.offset
            )
        }
        
        renderEncoder.endEncoding()
        
        // Present the drawable and commit the command buffer.
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}



func createFloat4x4Projection(projectionFov fov: Float, near: Float, far: Float, aspect: Float) -> float4x4{
    let y = 1 / tan(fov * 0.5)
    let x = y / aspect
    let z = far / (far - near)
    let X = SIMD4<Float>( x,  0,  0,  0)
    let Y = SIMD4<Float>( 0,  y,  0,  0)
    let Z = SIMD4<Float>( 0,  0,  z, 1)
    let W = SIMD4<Float>( 0,  0,  z * -near,  0)
    return float4x4(columns: (X, Y, Z, W))
}

func setUpUniforms() -> Uniforms{
  
    var uniforms = Uniforms()
    
    let translation = float4x4(
        SIMD4<Float>(1, 0, 0, 0),
        SIMD4<Float>(0, 1, 0, 0),
        SIMD4<Float>(0, 0, 1, 0),
        SIMD4<Float>(0, 0, 0, 1)
    )

   
    let angle = Float.pi / 6
    let rotation = float4x4(
        SIMD4<Float>(cos(angle), 0, sin(angle), 0),
        SIMD4<Float>(0, 1, 0, 0),
        SIMD4<Float>(-sin(angle), 0, cos(angle), 0),
        SIMD4<Float>(0, 0, 0, 1)
    )

    let modelMatrix = matrix_multiply(translation, rotation)
    let viewTranslation = float4x4(
        SIMD4<Float>(1, 0, 0, 0),
        SIMD4<Float>(0, 1, 0, 0),
        SIMD4<Float>(0, 0, 1, 0),
        SIMD4<Float>(0, 0, -4, 1)
    )

    let viewMatrix = viewTranslation.inverse
    
    uniforms.modelMatrix = modelMatrix
    uniforms.viewMatrix = viewMatrix

    return uniforms
}



extension MTLVertexDescriptor {
  static var defaultLayout: MTLVertexDescriptor? {
    MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
  }
}

extension MDLVertexDescriptor {
  static var defaultLayout: MDLVertexDescriptor {
    let vertexDescriptor = MDLVertexDescriptor()
    var offset = 0
    vertexDescriptor.attributes[0] = MDLVertexAttribute(
      name: MDLVertexAttributePosition,
      format: .float3,
      offset: 0,
      bufferIndex: 0)
    offset += MemoryLayout<float3>.stride
    vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
    return vertexDescriptor
  }
}
