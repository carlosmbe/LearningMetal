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
    
    let triangle: MTLBuffer
    let quad : Mesh
    
    var pipeline: MTLRenderPipelineState
    
    init(_ parent : ContentView) {
        self.parent = parent
       
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        }
        
        self.commandQueue = device.makeCommandQueue()
        
        //Adding our Pipeline Builder
        pipeline = buildPipeline(device: device)
        
        let meshBuilder = MeshBuilder(device: device)
        triangle = meshBuilder.makeTriangle()
        quad = meshBuilder.makeQuad()
        
        super.init()
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    ///Drawing Pass
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {    return  }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        //Render Pass - Clear - Set Clear Colour
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.7, green: 0.3, blue: 0.6, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        //Updates so draw calls are made
        renderEncoder.setRenderPipelineState(pipeline)
        
        renderEncoder.setVertexBuffer(quad.vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: quad.indexCount, indexType: .uint16, indexBuffer: quad.indexBuffer, indexBufferOffset: 0)
        
        renderEncoder.setVertexBuffer(triangle, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        
        
        renderEncoder.endEncoding()
        
        //Commit and present the state of the buffer
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
}
