//
//  ConfettiCanvasView.swift
//  Confetti_Effects
//
//  Created by Taric Santos de Andrade on 2025-04-23.
//
import SwiftUI

/// A SwiftUI view that renders confetti particles using Canvas and TimelineView
/// Requires macOS 14.0 or later for @Observable support
@available(macOS 14.0, *)
struct ConfettiCanvasView: View {
    /// The particle system that manages all confetti particles
    @State private var particleSystem = ParticleSystem()

    /// Tracks the current size of the canvas for positioning elements
    @State private var canvasSize: CGSize = .zero
    
    /// Standard size for individual confetti pieces
    let confettiDrawingSize = CGSize(width: 10, height: 10)

    var body: some View {
        if #available(macOS 14.0, *) {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    // Update canvas size state if it changes
                    // Using task modifier is often safer for size updates than async dispatch
                    // This example keeps the original async dispatch for simplicity comparison
                    DispatchQueue.main.async {
                        if canvasSize != size {
                            canvasSize = size
                        }
                    }
                    
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    
                    // Update the particle system state - this runs on MainActor
                    particleSystem.update(date: now, size: size)
                    
                    // Drawing logic for each particle
                    for particle in particleSystem.particles {
                        let age = now - particle.creationDate
                        let normalizedAge = age / particle.lifespan
                        let opacity = max(0, 1.0 - normalizedAge)
                        
                        guard opacity > 0 else { continue }
                        
                        context.drawLayer { layerContext in
                            // 1. Set Opacity
                            layerContext.opacity = opacity
                            // 2. Translate to Particle Position
                            layerContext.translateBy(x: particle.position.x, y: particle.position.y)
                            // 3. Rotate by Particle Rotation
                            layerContext.rotate(by: particle.rotation)
                            // 4. Define the Path based on shapeType
                            let confettiRect = CGRect(
                                x: -confettiDrawingSize.width / 2.0,
                                y: -confettiDrawingSize.height / 2.0,
                                width: confettiDrawingSize.width,
                                height: confettiDrawingSize.height
                            )
                            let path: Path
                            switch particle.shapeType {
                            case .rectangle: path = Path(confettiRect)
                            case .circle: path = Path(ellipseIn: confettiRect)
                            }
                            // 5. Fill the Path
                            layerContext.fill(path, with: .color(particle.color))
                        }
                    }
                }
                // .drawingGroup() // Optional performance optimization
                // .background(Color.black)
                .overlay(alignment: .bottom) {
                    // Button to trigger confetti
                    Button("Launch Confetti") {
                        let origin = CGPoint(x: canvasSize.width / 2, y: canvasSize.height)
                        particleSystem.emitBurst(count: 150, origin: origin, size: canvasSize)
                    }
                    .padding()
                }
            }
            .ignoresSafeArea()
        } else {
            // Since this View is only available on macOS 14.0+, we won't need the else clause
            // But we'll keep a simple fallback message for clarity
            Text("Confetti Effects requires macOS 14.0 or later")
        }
    }
}
