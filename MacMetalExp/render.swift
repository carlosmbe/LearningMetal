 //
//  render.swift
//  MacMetalExp
//
//  Created by Carlos Mbendera on 28/12/2024.
//

import MetalKit

///Put metal code here
class Renderer : NSObject, MTKViewDelegate {
    var parent : ContentView
    var device : MTLDevice!
    var commandQueue : MTLCommandQueue!
    
    let objMesh : Mesh
    
    var pipeline: MTLRenderPipelineState
    
    var uniforms = Uniforms()
    
    init(_ parent : ContentView) {
        self.parent = parent
       
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        }
        
        self.commandQueue = device.makeCommandQueue()
        
        //Adding our Pipeline Builder
        pipeline = buildPipeline(device: device)
        
        let meshBuilder = MeshBuilder(device: device)
        objMesh = meshBuilder.loadObj(from: Bundle.main.url(forResource: "XXX Whatever Model I Decide To Publish The Article With XXX", withExtension: "obj")!)!
      
        uniforms = setUpUniforms()
        
        super.init()
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
          let aspect = Float(view.bounds.width) / Float(view.bounds.height)
          let projectionMatrix =
        createFloat4x4Projection(
            projectionFov: Float.pi / 4,
              near: 0.1,
              far: 100,
              aspect: aspect)
          uniforms.projectionMatrix = projectionMatrix
    }
    
    ///Drawing Pass
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {    return  }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        //Render Pass - Clear - Set Clear Colour
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        renderEncoder.setCullMode(.back)
        
        renderEncoder.setVertexBytes(&uniforms,
                                         length: MemoryLayout<Uniforms>.stride, index: 1)
        
        //Updates so draw calls are made
        renderEncoder.setRenderPipelineState(pipeline)

        renderEncoder.setVertexBuffer(objMesh.vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: objMesh.indexCount, indexType: .uint16, indexBuffer: objMesh.indexBuffer, indexBufferOffset: 0)
        
        renderEncoder.endEncoding()
        
        //Commit and present the state of the buffer
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
