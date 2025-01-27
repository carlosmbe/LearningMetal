//
//  PipelineBuilder.swift
//  MacMetalExp
//
//  Created by Carlos Mbendera on 06/01/2025.
//

import Metal

func buildPipeline(device: MTLDevice) -> MTLRenderPipelineState {
    
    let pipeline : MTLRenderPipelineState
    
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    let library =  device.makeDefaultLibrary()!
    
   
    pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexMain")
    pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentMain")
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    //New Line
    pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
    
    do{
        pipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        return pipeline
    }catch{
        print(error.localizedDescription)
        fatalError()
    }
    
}
