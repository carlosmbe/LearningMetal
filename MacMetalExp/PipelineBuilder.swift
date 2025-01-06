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
    
    //We're hardcoding these, but realistically in a more complex app, we'd accept these as and map it accordingly
    pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexMain")
    pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentMain")
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    do{
        pipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        return pipeline
    }catch{
        //Since we're hardcoding things right now, we know that is should work, otherwise in practise, our code would handle this better
        //If it does crash, try cleaning your build folder
        fatalError()
    }
    
}
