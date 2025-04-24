//
//  Particle_Struct.swift
//  Confetti_Effects
//
//  Created by Taric on 2025-04-23.
//
import SwiftUI
import Foundation // For TimeInterval, UUID

/// Defines the possible shapes for confetti particles
enum ConfettiShape: CaseIterable {
    /// Rectangular confetti piece
    case rectangle
    /// Circular confetti piece
    case circle
}

/// Represents a single confetti particle with position, movement, and appearance properties
@available(macOS 14.0, *)
struct Particle: Identifiable, Hashable {
    /// Unique identifier for each particle
    let id: UUID = UUID()
    
    /// Current 2D location on the canvas
    var position: CGPoint
    
    /// Current speed and direction (dx, dy per second)
    var velocity: CGVector
    
    /// Rate of change in velocity (e.g., gravity)
    var acceleration: CGVector
    
    /// Timestamp of creation for age calculation
    let creationDate: TimeInterval
    
    /// How long the particle should exist (in seconds)
    let lifespan: TimeInterval
    
    /// Fill color of the particle
    let color: Color
    
    /// The shape to draw (rectangle or circle)
    let shapeType: ConfettiShape
    
    /// Current 2D rotation angle
    var rotation: Angle
    
    /// Speed of rotation (radians per second)
    var angularVelocity: Double

    /// Conformance to Hashable protocol
    /// - Parameter hasher: The hasher to use
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Conformance to Equatable protocol
    /// - Parameters:
    ///   - lhs: Left-hand side particle
    ///   - rhs: Right-hand side particle
    /// - Returns: True if particles have the same ID
    static func == (lhs: Particle, rhs: Particle) -> Bool {
        lhs.id == rhs.id
    }
}
