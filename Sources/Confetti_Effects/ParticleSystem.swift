//
//  ParticleSystem.swift
//  Confetti_Effects
//
//  Created by Taric on 2025-04-23.
//
// Particle.swift remains the same as in the manual
import SwiftUI
import Observation // Import Observation framework (often implicitly included with SwiftUI)

/// The ParticleSystem manages a collection of confetti particles, including their creation, 
/// movement, and lifecycle. It handles physics simulation including gravity, rotation, and aging.
@available(macOS 14.0, *)
@Observable
// Add @MainActor for safe UI updates from the update loop driven by TimelineView
@MainActor
class ParticleSystem {
    /// The current set of active particles being managed by the system
    var particles: Set<Particle> = []

    /// Timestamp of the last update call, used for calculating elapsed time between frames
    private var lastUpdateTime: TimeInterval?

    /// Controls how fast particles accelerate downward (points per second squared)
    let gravityConstant: Double = 150.0
    
    /// Reduces velocity each frame to simulate air resistance (0-1, where 1 = no dampening)
    let dampingFactor: Double = 0.99

    /// Updates the physics simulation for all particles
    /// - Parameters:
    ///   - date: Current timestamp from TimelineView
    ///   - size: Current canvas size
    func update(date: TimeInterval, size: CGSize) {
        // Calculate time elapsed since the last update
        let elapsedTime = date - (lastUpdateTime ?? date)
        lastUpdateTime = date

        // Prevent huge jumps if update loop was paused (e.g., background)
        let clampedElapsedTime = min(elapsedTime, 0.05)

        var particlesToRemove: Set<UUID> = []
        // Note: Modifying Set elements requires removing and re-inserting
        let currentParticles = particles

        for particle in currentParticles {
             var modifiedParticle = particle // Make a mutable copy

            // 1. Apply Acceleration (Gravity)
             modifiedParticle.velocity.dy += gravityConstant * clampedElapsedTime

            // 2. Apply Damping (Air Resistance)
            modifiedParticle.velocity.dx *= dampingFactor
            modifiedParticle.velocity.dy *= dampingFactor

            // 3. Update Rotation
            modifiedParticle.rotation += Angle(radians: modifiedParticle.angularVelocity * clampedElapsedTime)

            // 4. Update Position
            modifiedParticle.position.x += modifiedParticle.velocity.dx * clampedElapsedTime
            modifiedParticle.position.y += modifiedParticle.velocity.dy * clampedElapsedTime

            // 5. Check Lifetime
            let age = date - modifiedParticle.creationDate
            if age > modifiedParticle.lifespan {
                particlesToRemove.insert(modifiedParticle.id)
            } else {
                 // Update the particle in the main set by removing the old and inserting the new
                 particles.remove(particle)
                 particles.insert(modifiedParticle)
             }
        }

        // Remove expired particles efficiently
        if !particlesToRemove.isEmpty {
            // Filter the particles set to keep only those that aren't in particlesToRemove
            particles = particles.filter { particle in
                !particlesToRemove.contains(particle.id)
            }
        }
    }

    /// Creates and adds a burst of confetti particles to the system
    /// - Parameters:
    ///   - count: Number of particles to create
    ///   - origin: Starting position for the particles
    ///   - size: Current canvas size
    ///   - emissionAngleRange: Range of angles for initial velocity (in degrees, upwards)
    ///   - initialVelocityRange: Range of initial speeds (points per second)
    ///   - lifespanRange: Range of particle lifetimes (in seconds)
    ///   - angularVelocityRange: Range of rotation speeds (radians per second)
    func emitBurst(count: Int, origin: CGPoint, size: CGSize,
                   emissionAngleRange: ClosedRange<Angle> = Angle.degrees(-120)...Angle.degrees(-60),
                   initialVelocityRange: ClosedRange<Double> = 150.0...400.0,
                   lifespanRange: ClosedRange<TimeInterval> = 3.0...6.0,
                   angularVelocityRange: ClosedRange<Double> = -Double.pi...Double.pi) {
        let creationTime = Date.now.timeIntervalSinceReferenceDate
        let availableColors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange, .cyan]
        let availableShapes = ConfettiShape.allCases

        for _ in 0..<count {
            // Random initial properties
             let randomAngle = Angle.radians(Double.random(in: emissionAngleRange.lowerBound.radians...emissionAngleRange.upperBound.radians))
             let randomSpeed = Double.random(in: initialVelocityRange)
             let randomLifespan = TimeInterval.random(in: lifespanRange)
             let randomColor = availableColors.randomElement() ?? .red
             let randomShape = availableShapes.randomElement() ?? .rectangle
             let randomRotation = Angle.degrees(Double.random(in: 0...360))
             let randomAngularVelocity = Double.random(in: angularVelocityRange)

             // Calculate initial velocity vector
             let velocity = CGVector(
                 dx: cos(randomAngle.radians) * randomSpeed,
                 dy: sin(randomAngle.radians) * randomSpeed // Negative dy is upwards
             )

             // Create the new particle
             let newParticle = Particle(
                 position: origin,
                 velocity: velocity,
                 acceleration: CGVector(dx: 0, dy: 0), // Gravity applied in update()
                 creationDate: creationTime,
                 lifespan: randomLifespan,
                 color: randomColor,
                 shapeType: randomShape,
                 rotation: randomRotation,
                 angularVelocity: randomAngularVelocity
             )

             // Add to the system
             particles.insert(newParticle)
        }
    }
}
