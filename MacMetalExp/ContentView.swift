//
//  ContentView.swift
//  MacMetalExp
//
//  Created by Carlos Mbendera on 28/12/2024.
//

import SwiftUI
import MetalKit

struct ContentView: UIViewRepresentable {
    ///Create UI Kit View to Set Up Metal Kit View
    
    func makeCoordinator() -> Renderer {
        // We are going to create this class elsewhere, so don't be shocked if you're getting a few errors here
        Renderer(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<ContentView>) -> MTKView {
        // We're using the Metal Kit library to create a Metal Kit view. You can customize this section with your own parameters
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
       // mtkView.enableSetNeedsDisplay = true
        
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        //Needed to draw every frame for the rotations
        mtkView.isPaused = false
        mtkView.enableSetNeedsDisplay = false
        // End comment for rotation draw changes
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        return mtkView
    }
        
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<ContentView>) {
        // Place Holder function for now. We'll implement this later but for now, we need it to meet the UIViewRepresentable Prototype requirements
    }
    
}

#Preview {
    ContentView()
}
