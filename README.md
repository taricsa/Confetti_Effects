# Confetti_Effects

[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%2014.0%2B-blue)](https://developer.apple.com/swift)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

A beautiful, lightweight confetti animation package for SwiftUI applications. This package provides easy-to-use components for adding celebration animations to your macOS apps with minimal effort.

<p align="center">
  <img src="https://via.placeholder.com/800x400?text=Confetti+Demo+GIF" alt="Confetti Demo" width="800">
</p>

## Features

- 🎉 Ready-to-use confetti animation view
- 🎨 Multiple confetti shapes and colors
- 🔄 Physics-based animation with proper rotations and movement
- 🚀 Built with modern Swift features (@Observable, SwiftUI Canvas)
- 📦 Simple Swift Package Manager integration

## Requirements

- macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/taricsa/Confetti_Effects.git", from: "1.0.0")
]
```

Or add it directly from Xcode:
1. Go to `File` > `Add Package Dependencies...`
2. Paste the repository URL: `https://github.com/taricsa/Confetti_Effects.git`
3. Click `Add Package`

## Usage

### Quick Start

```swift
import SwiftUI
import Confetti_Effects

struct ContentView: View {
    var body: some View {
        ConfettiCanvasView()
            .frame(width: 400, height: 400)
    }
}
```

The `ConfettiCanvasView` includes a "Launch Confetti" button at the bottom that triggers a confetti burst when tapped.

### Custom Implementation

If you want more control over when the confetti animation plays, you can use the `ParticleSystem` class directly:

```swift
import SwiftUI
import Confetti_Effects

struct CustomConfettiView: View {
    @State private var particleSystem = ParticleSystem()
    @State private var canvasSize: CGSize = .zero
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // Store canvas size
                if canvasSize != size {
                    canvasSize = size
                }
                
                // Update particle physics
                let now = timeline.date.timeIntervalSinceReferenceDate
                particleSystem.update(date: now, size: size)
                
                // Draw particles
                for particle in particleSystem.particles {
                    // Drawing code here...
                }
            }
            .overlay(alignment: .bottom) {
                Button("Custom Confetti!") {
                    // Customize confetti properties
                    let origin = CGPoint(x: canvasSize.width / 2, y: canvasSize.height)
                    particleSystem.emitBurst(
                        count: 200,
                        origin: origin,
                        size: canvasSize,
                        emissionAngleRange: Angle.degrees(-160)...Angle.degrees(-20),
                        initialVelocityRange: 200...500
                    )
                }
                .padding()
            }
        }
    }
}
```

## Customization

The `emitBurst` method allows you to customize various aspects of the confetti animation:

```swift
func emitBurst(
    count: Int, 
    origin: CGPoint, 
    size: CGSize,
    emissionAngleRange: ClosedRange<Angle> = Angle.degrees(-120)...Angle.degrees(-60),
    initialVelocityRange: ClosedRange<Double> = 150.0...400.0,
    lifespanRange: ClosedRange<TimeInterval> = 3.0...6.0,
    angularVelocityRange: ClosedRange<Double> = -Double.pi...Double.pi
)
```

| Parameter | Description |
|-----------|-------------|
| `count` | Number of confetti particles to create |
| `origin` | Starting position for the particles |
| `size` | Current canvas size |
| `emissionAngleRange` | Range of angles for initial velocity (in degrees, upwards) |
| `initialVelocityRange` | Range of initial speeds (points per second) |
| `lifespanRange` | Range of particle lifetimes (in seconds) |
| `angularVelocityRange` | Range of rotation speeds (radians per second) |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Built with SwiftUI and the Canvas API
- Inspired by various confetti implementations in the iOS/macOS community

## Contact

Taric Andrade - [GitHub: @taricsa](https://github.com/taricsa)

Feel free to reach out with any questions, issues, or suggestions! 
