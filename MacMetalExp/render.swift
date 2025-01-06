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
    
    init(_ parent : ContentView) {
        self.parent = parent
       
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        }
        
        self.commandQueue = device.makeCommandQueue()
        
        //Adding our Pipeline Builder
        pipeline = buildPipeline(device: device)
        
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
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.8, green: 0.3, blue: 0.6, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        //Updates so draw calls are made
        renderEncoder.setRenderPipelineState(pipeline)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderEncoder.endEncoding()
        
        //Commit and present the state of the buffer
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
}
