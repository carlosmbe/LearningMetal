//
//  ContentView.swift
//  MacMetalExp
//
//  Created by Carlos Mbendera on 28/12/2024.
//

import SwiftUI
import MetalKit

//struct ContentView: UIViewRepresentable {
//    ///Create UI Kit View to Set Up Metal Kit View
//    
//    func makeCoordinator() -> Renderer {
//        // We are going to create this class elsewhere, so don't be shocked if you're getting a few errors here
//        Renderer(self)
//    }
//    
//    func makeUIView(context: UIViewRepresentableContext<ContentView>) -> MTKView {
//        // We're using the Metal Kit library to create a Metal Kit view. You can customize this section with your own parameters
//        let mtkView = MTKView()
//        mtkView.delegate = context.coordinator
//        mtkView.preferredFramesPerSecond = 60
//       // mtkView.enableSetNeedsDisplay = true
//        
//        
//        if let metalDevice = MTLCreateSystemDefaultDevice() {
//            mtkView.device = metalDevice
//        }
//        
//        //Needed to draw every frame for the rotations
//        mtkView.isPaused = false
//        mtkView.enableSetNeedsDisplay = false
//        // End comment for rotation draw changes
//        
//        mtkView.framebufferOnly = false
//        mtkView.drawableSize = mtkView.frame.size
//        return mtkView
//    }
//        
//    func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<ContentView>) {
//        // Place Holder function for now. We'll implement this later but for now, we need it to meet the UIViewRepresentable Prototype requirements
//    }
//    
//}

#Preview {
    MetalView()
}


import UIKit
import Metal

class MetalView: UIView {
    // Override the layer to be a CAMetalLayer.
    override class var layerClass: AnyClass {
        return CAMetalLayer.self
    }
    
    // Convenience accessor.
    var metalLayer: CAMetalLayer {
        return layer as! CAMetalLayer
    }
    
    var renderer: Renderer!
    var displayLink: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Create your Metal device.
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        // Set up the CAMetalLayer.
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.isOpaque = false
        
        // Initialize your renderer.
        renderer = Renderer(device: device)
        renderer.setUpPipeline()  // (Your pipeline & mesh setup)
        
        // Create a display link to drive the render loop.
        displayLink = CADisplayLink(target: self, selector: #selector(renderLoop))
        displayLink?.add(to: .main, forMode: .default)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update the metalLayer's frame and drawable size.
        metalLayer.frame = bounds
        
        // Update your projection matrix (if needed).
        let aspect = Float(bounds.width / bounds.height)
        let projectionMatrix = createFloat4x4Projection(
            projectionFov: Float.pi / 4,
            near: 0.1,
            far: 100,
            aspect: aspect)
        renderer.uniforms.projectionMatrix = projectionMatrix
    }
    
    @objc private func renderLoop() {
        autoreleasepool {
            renderer.render(to: metalLayer)
        }
    }
}

