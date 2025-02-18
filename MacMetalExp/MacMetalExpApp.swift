//
//  MacMetalExpApp.swift
//  MacMetalExp
//
//  Created by Carlos Mbendera on 28/12/2024.
//

import SwiftUI

// Wrap your MetalView (a UIView subclass) in a UIViewRepresentable.
struct MetalViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> MetalView {
        // Create and return your MetalView.
        return MetalView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MetalView, context: Context) {
        // Update the view if needed.
    }
}

@main
struct MacMetalExpApp: App {
    var body: some Scene {
        WindowGroup {
            // Use the wrapper instead of MetalView directly.
            MetalViewRepresentable()
        }
    }
}
