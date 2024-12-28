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
        Renderer(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<ContentView>) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        return mtkView
    }
        
    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<ContentView>) {
    }
    
}

#Preview {
    ContentView()
}
