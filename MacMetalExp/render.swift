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
    
    var pipeline: MTLRenderPipelineState
    
    var uniforms = Uniforms()
    
    //New Properties
    let allocator : MTKMeshBufferAllocator
    let asset : MDLAsset
    let mdlMesh : MDLMesh
    let mesh : MTKMesh
    
    var timer: Float = 0
    
    init(_ parent : ContentView) {
        self.parent = parent
        
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        }
        
        self.commandQueue = device.makeCommandQueue()
        
        //Adding our Pipeline Builder
        pipeline = buildPipeline(device: device)
        
        uniforms = setUpUniforms()
        
        //New logic that intitalises our new properties
        allocator = MTKMeshBufferAllocator(device: device)
        
        //Copyright of Cat Model Belongs to @printable_models from free3d.com https://free3d.com/3d-model/cat-v1--522281.html
        asset = MDLAsset(url: Bundle.main.url(forResource: "12221_Cat_v1_l3", withExtension: "obj")!,
                         vertexDescriptor: .defaultLayout,
                         bufferAllocator: allocator)
        
        mdlMesh = asset.childObjects(of: MDLMesh.self).first as! MDLMesh
        
        mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        
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
        //Render Pass - Set Clear Colour - Basically Background
        //renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        
        // Start: THIS NOT FOR SHIPPING CODE. IT'S JUST ME HAVING DEBUG CODE THAT Changes the background
        timer += 0.005
         // Changes  background color using the timer
         let red = (sin(timer) + 1) / 2  // Maps sin(timer) from [-1, 1] to [0, 1]
         let green = (cos(timer) + 1) / 2
         let blue = (sin(timer * 0.5) + 1) / 2
         
         renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            alpha: 1.0
         )
        //End: THIS NOT FOR SHIPPING CODE. IT'S JUST ME HAVING DEBUG CODE THAT Changes the background
        
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        //Start : THIS NOT FOR SHIPPING CODE. IT'S JUST ME HAVING DEBUG CODE THAT ROTATES MODELS
      //  timer += 0.005
        
        let rotation = float4x4(
            SIMD4<Float>(cos(timer), 0, sin(timer), 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(-sin(timer), 0, cos(timer), 0),
            SIMD4<Float>(0, 0, 0, 1)
        )

        let translation = float4x4(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )

        // Combine translation and rotation to create the modelMatrix
        uniforms.modelMatrix = matrix_multiply(translation, rotation)
        
        //End: THIS NOT FOR SHIPPING CODE. IT'S JUST ME HAVING DEBUG CODE THAT ROTATES MODELS
        
        renderEncoder.setCullMode(.back)
       
        renderEncoder.setVertexBytes(&uniforms,
                                         length: MemoryLayout<Uniforms>.stride, index: 2)
        
        
        renderEncoder.setRenderPipelineState(pipeline)

        //Draw our new Mesh from the Asset
        renderEncoder.setVertexBuffer(
          mesh.vertexBuffers[0].buffer,
          offset: 0,
          index: 0)
        
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
