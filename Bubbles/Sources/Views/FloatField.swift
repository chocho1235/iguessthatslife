import SwiftUI

/// Tiny physics sim that keeps the bubbles drifting, bumping into each
/// other and bouncing off the edges of the screen.
final class FloatField {
    enum Mood { case normal, rising, sinking }

    struct Body {
        var position: CGPoint
        var velocity: CGVector
        var radius: CGFloat
        var phase: Double
        var mood: Mood = .normal
    }

    private(set) var bodies: [UUID: Body] = [:]
    private var lastTime: Date?
    private var dragging: Set<UUID> = []

    private let cruiseSpeed: CGFloat = 22

    func step(to now: Date, in bounds: CGRect, items: [(id: UUID, radius: CGFloat, mood: Mood)]) {
        sync(items, in: bounds)

        let dt = CGFloat(min(max(now.timeIntervalSince(lastTime ?? now), 0), 1.0 / 30.0))
        lastTime = now
        guard dt > 0 else { return }
        let t = now.timeIntervalSinceReferenceDate

        for id in bodies.keys where !dragging.contains(id) {
            guard var b = bodies[id] else { continue }

            // Gentle wandering so the motion never looks like straight lines.
            b.velocity.dx += CGFloat(sin(t * 0.6 + b.phase)) * 9 * dt
            b.velocity.dy += CGFloat(cos(t * 0.5 + b.phase * 1.3)) * 9 * dt

            switch b.mood {
            case .rising: b.velocity.dy -= 14 * dt
            case .sinking: b.velocity.dy += 30 * dt
            case .normal: break
            }

            // Ease the speed back toward a calm cruising pace.
            let speed = hypot(b.velocity.dx, b.velocity.dy)
            let target = b.mood == .sinking ? cruiseSpeed * 0.6 : cruiseSpeed
            if speed > 0.001 {
                let blend = min(1, 0.8 * dt)
                let newSpeed = speed + (target - speed) * blend
                b.velocity.dx *= newSpeed / speed
                b.velocity.dy *= newSpeed / speed
            }

            b.position.x += b.velocity.dx * dt
            b.position.y += b.velocity.dy * dt
            bounceOffWalls(&b, in: bounds)
            bodies[id] = b
        }

        resolveCollisions(in: bounds)
    }

    func position(of id: UUID) -> CGPoint? { bodies[id]?.position }

    func drag(_ id: UUID, to point: CGPoint) {
        dragging.insert(id)
        bodies[id]?.position = point
        bodies[id]?.velocity = .zero
    }

    func release(_ id: UUID, velocity: CGSize) {
        dragging.remove(id)
        // Let a flick throw the bubble, but cap it so it doesn't fly off forever.
        let v = CGVector(dx: velocity.width * 0.5, dy: velocity.height * 0.5)
        let speed = hypot(v.dx, v.dy)
        let cap: CGFloat = 500
        let scale = speed > cap ? cap / speed : 1
        bodies[id]?.velocity = CGVector(dx: v.dx * scale, dy: v.dy * scale)
    }

    private func sync(_ items: [(id: UUID, radius: CGFloat, mood: Mood)], in bounds: CGRect) {
        let wanted = Set(items.map(\.id))
        for id in bodies.keys where !wanted.contains(id) {
            bodies[id] = nil
        }
        for item in items {
            if bodies[item.id] == nil {
                let r = item.radius
                let x = CGFloat.random(in: (bounds.minX + r)...max(bounds.minX + r, bounds.maxX - r))
                let y = CGFloat.random(in: (bounds.minY + r)...max(bounds.minY + r, bounds.maxY - r))
                let angle = Double.random(in: 0..<(2 * .pi))
                bodies[item.id] = Body(
                    position: CGPoint(x: x, y: y),
                    velocity: CGVector(dx: cos(angle) * cruiseSpeed, dy: sin(angle) * cruiseSpeed),
                    radius: r,
                    phase: Double.random(in: 0..<(2 * .pi))
                )
            }
            bodies[item.id]?.radius = item.radius
            bodies[item.id]?.mood = item.mood
        }
    }

    private func bounceOffWalls(_ b: inout Body, in bounds: CGRect) {
        let r = b.radius
        if b.position.x < bounds.minX + r { b.position.x = bounds.minX + r; b.velocity.dx = abs(b.velocity.dx) }
        if b.position.x > bounds.maxX - r { b.position.x = bounds.maxX - r; b.velocity.dx = -abs(b.velocity.dx) }
        if b.position.y < bounds.minY + r { b.position.y = bounds.minY + r; b.velocity.dy = abs(b.velocity.dy) }
        if b.position.y > bounds.maxY - r { b.position.y = bounds.maxY - r; b.velocity.dy = -abs(b.velocity.dy) * 0.5 }
    }

    private func resolveCollisions(in bounds: CGRect) {
        let ids = Array(bodies.keys)
        guard ids.count > 1 else { return }
        for i in 0..<(ids.count - 1) {
            for j in (i + 1)..<ids.count {
                guard var a = bodies[ids[i]], var b = bodies[ids[j]] else { continue }
                let dx = b.position.x - a.position.x
                let dy = b.position.y - a.position.y
                let dist = max(hypot(dx, dy), 0.01)
                let overlap = a.radius + b.radius - dist
                guard overlap > 0 else { continue }

                let nx = dx / dist
                let ny = dy / dist
                let aHeld = dragging.contains(ids[i])
                let bHeld = dragging.contains(ids[j])

                // Push them apart. A bubble you're holding doesn't move.
                let aShare: CGFloat = aHeld ? 0 : (bHeld ? 1 : 0.5)
                let bShare: CGFloat = bHeld ? 0 : (aHeld ? 1 : 0.5)
                a.position.x -= nx * overlap * aShare
                a.position.y -= ny * overlap * aShare
                b.position.x += nx * overlap * bShare
                b.position.y += ny * overlap * bShare

                // Soft bounce along the line between their centres.
                let rel = (b.velocity.dx - a.velocity.dx) * nx + (b.velocity.dy - a.velocity.dy) * ny
                if rel < 0 {
                    let impulse = -rel * 0.9
                    if !aHeld { a.velocity.dx -= nx * impulse; a.velocity.dy -= ny * impulse }
                    if !bHeld { b.velocity.dx += nx * impulse; b.velocity.dy += ny * impulse }
                }

                if !aHeld { bounceOffWalls(&a, in: bounds) }
                if !bHeld { bounceOffWalls(&b, in: bounds) }
                bodies[ids[i]] = a
                bodies[ids[j]] = b
            }
        }
    }
}
