import AVFoundation

/// Every effect is synthesized on the fly rather than bundled as an asset,
/// matching the rest of the game's procedural (no-image-files) art style.
enum SoundEffect {
    case tap
    case ageUp
    case cash
    case diagnose
    case treat
    case hired
    case rejected
    case fight
    case death
    case success
    case alert
    case graduate
    case ouch
    case friendJoin
    case friendLeave
    case danger
    case cheer
    case sad
    case heartbreak
    case achievement
    case glassBreak
    case sick
    case pet
    case party
    case notify
}

private struct Note {
    let frequency: Double
    let duration: Double
    let volume: Double
    /// Target frequency to glide to by the end of the note; nil holds steady.
    let glideTo: Double?
    /// Extra overtones layered above the fundamental, as (harmonic multiple, relative volume).
    let harmonics: [(Double, Double)]
    /// Vibrato rate in Hz (0 = none) and depth as a fraction of the base frequency.
    let vibratoRate: Double
    let vibratoDepth: Double

    init(_ frequency: Double, _ duration: Double, _ volume: Double, glideTo: Double? = nil, harmonics: [(Double, Double)] = [], vibratoRate: Double = 0, vibratoDepth: Double = 0) {
        self.frequency = frequency
        self.duration = duration
        self.volume = volume
        self.glideTo = glideTo
        self.harmonics = harmonics
        self.vibratoRate = vibratoRate
        self.vibratoDepth = vibratoDepth
    }
}

final class SoundManager {
    static let shared = SoundManager()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private var buffers: [SoundEffect: AVAudioPCMBuffer] = [:]

    private init() {
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)
        buildBuffers()
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        engine.prepare()
        try? engine.start()
    }

    func play(_ effect: SoundEffect) {
        guard let buffer = buffers[effect] else { return }
        if !engine.isRunning {
            try? engine.start()
        }
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: .interrupts)
        player.play()
    }

    /// Queues several effects to play back-to-back without cutting each other
    /// off — used when a single year passing fires multiple life events that
    /// each deserve their own sound.
    func playSequence(_ effects: [SoundEffect]) {
        guard !effects.isEmpty else { return }
        if !engine.isRunning {
            try? engine.start()
        }
        player.stop()
        for effect in effects {
            guard let buffer = buffers[effect] else { continue }
            player.scheduleBuffer(buffer, at: nil, options: [])
        }
        player.play()
    }

    // MARK: - Buffer synthesis

    private func buildBuffers() {
        // A gentle two-click tap, like a soft UI knock.
        buffers[.tap] = notes([
            Note(900, 0.035, 0.16, harmonics: [(2, 0.2)]),
        ])

        // A single clean upward swoosh into a soft landing note — quick and
        // unobtrusive since it fires on every single year passing.
        buffers[.ageUp] = notes([
            Note(420, 0.1, 0.14, glideTo: 740, harmonics: [(2, 0.18)]),
            Note(660, 0.11, 0.16, harmonics: [(2, 0.22)]),
        ])

        // Bright coin-register bell with a fast glittering tail.
        buffers[.cash] = notes([
            Note(988, 0.045, 0.2, harmonics: [(2, 0.4), (4, 0.15)]),
            Note(1318, 0.045, 0.2, harmonics: [(2, 0.4), (4, 0.15)]),
            Note(1568, 0.045, 0.2, harmonics: [(2, 0.4), (4, 0.15)]),
            Note(2093, 0.14, 0.24, harmonics: [(2, 0.4), (3, 0.2)]),
        ])

        // Clinical two-tone blip, almost like a heart-rate monitor.
        buffers[.diagnose] = notes([
            Note(740, 0.09, 0.2, harmonics: [(3, 0.18), (5, 0.08)]),
            Note(0, 0.05, 0),
            Note(740, 0.09, 0.2, harmonics: [(3, 0.18), (5, 0.08)]),
            Note(0, 0.04, 0),
            Note(988, 0.14, 0.2, harmonics: [(3, 0.18)]),
        ])

        // Warm healing swell, rising smoothly with soft harmonics.
        buffers[.treat] = notes([
            Note(440, 0.05, 0.0, glideTo: 587, harmonics: [(2, 0.25)]),
            Note(587, 0.1, 0.2, harmonics: [(2, 0.3), (3, 0.1)]),
            Note(880, 0.2, 0.22, harmonics: [(2, 0.3), (3, 0.12)], vibratoRate: 5, vibratoDepth: 0.008),
        ])

        // Big triumphant fanfare chord, arpeggiated then held.
        buffers[.hired] = notes([
            Note(523, 0.11, 0.2, harmonics: [(2, 0.35), (3, 0.15)]),
            Note(659, 0.11, 0.2, harmonics: [(2, 0.35), (3, 0.15)]),
            Note(784, 0.11, 0.2, harmonics: [(2, 0.35), (3, 0.15)]),
            Note(1046, 0.3, 0.26, harmonics: [(2, 0.4), (3, 0.22), (4, 0.1)], vibratoRate: 5, vibratoDepth: 0.006),
        ])

        // Classic "womp womp" — two downward glides.
        buffers[.rejected] = notes([
            Note(392, 0.22, 0.2, glideTo: 294, harmonics: [(2, 0.2)]),
            Note(0, 0.03, 0),
            Note(294, 0.3, 0.2, glideTo: 220, harmonics: [(2, 0.2)]),
        ])

        // Punchy layered impact: noise burst plus a low thump.
        buffers[.fight] = mixed([
            noiseBurst(duration: 0.2, amplitude: 0.32),
            notes([Note(120, 0.18, 0.3, glideTo: 70)]),
        ])

        // Slow somber descending glide with a decaying tail — a bell tolling.
        buffers[.death] = notes([
            Note(330, 0.3, 0.2, glideTo: 277, harmonics: [(2, 0.2)]),
            Note(277, 0.3, 0.16, glideTo: 220, harmonics: [(2, 0.18)]),
            Note(220, 0.5, 0.12, glideTo: 165, harmonics: [(2, 0.15)]),
        ])

        // Quick ascending sparkle — something sneaky went right.
        buffers[.success] = notes([
            Note(700, 0.05, 0.18, harmonics: [(2, 0.25)]),
            Note(933, 0.05, 0.18, harmonics: [(2, 0.25)]),
            Note(1245, 0.12, 0.22, harmonics: [(2, 0.3), (3, 0.12)]),
        ])

        // Sharp two-tone alarm buzzer — you got caught.
        buffers[.alert] = notes([
            Note(880, 0.08, 0.22, harmonics: [(2, 0.2)]),
            Note(0, 0.03, 0),
            Note(660, 0.08, 0.22, harmonics: [(2, 0.2)]),
            Note(0, 0.03, 0),
            Note(880, 0.12, 0.22, harmonics: [(2, 0.2)]),
        ])

        // Cheerful graduation fanfare, distinct from the job-offer one.
        buffers[.graduate] = notes([
            Note(659, 0.1, 0.2, harmonics: [(2, 0.3)]),
            Note(784, 0.1, 0.2, harmonics: [(2, 0.3)]),
            Note(988, 0.1, 0.2, harmonics: [(2, 0.3)]),
            Note(1318, 0.24, 0.24, harmonics: [(2, 0.35), (3, 0.15)]),
        ])

        // A cartoonish "Ow!" — a sharp impact click, a fast rising yelp, then
        // a pained, wobbling fall-off.
        buffers[.ouch] = mixed([
            notes([
                Note(320, 0.035, 0.08, glideTo: 780),
                Note(700, 0.17, 0.26, glideTo: 360, harmonics: [(2, 0.22)], vibratoRate: 15, vibratoDepth: 0.07),
            ]),
            noiseBurst(duration: 0.045, amplitude: 0.28),
        ])

        // Warm welcoming chime for a new friend.
        buffers[.friendJoin] = notes([
            Note(587, 0.08, 0.18, harmonics: [(2, 0.3)]),
            Note(784, 0.16, 0.22, harmonics: [(2, 0.32), (3, 0.1)], vibratoRate: 5, vibratoDepth: 0.006),
        ])

        // Gentle sad descending tone for a friend drifting away.
        buffers[.friendLeave] = notes([
            Note(587, 0.18, 0.16, glideTo: 440, harmonics: [(2, 0.2)]),
            Note(392, 0.26, 0.14, glideTo: 330, harmonics: [(2, 0.15)]),
        ])

        // Low ominous rumble for stepping into something risky.
        buffers[.danger] = notes([
            Note(165, 0.2, 0.22, harmonics: [(2, 0.15)]),
            Note(130, 0.3, 0.2, glideTo: 98, harmonics: [(2, 0.15)]),
        ])

        // Quick, giggly ascending triplet — a fun, lighthearted life event.
        buffers[.cheer] = notes([
            Note(784, 0.05, 0.16, harmonics: [(2, 0.2)]),
            Note(988, 0.05, 0.16, harmonics: [(2, 0.2)]),
            Note(1318, 0.09, 0.2, harmonics: [(2, 0.25)], vibratoRate: 8, vibratoDepth: 0.02),
        ])

        // Slow, plain descending glide — a quietly sad moment.
        buffers[.sad] = notes([
            Note(440, 0.2, 0.15, glideTo: 350, harmonics: [(2, 0.15)]),
            Note(330, 0.28, 0.13, glideTo: 260, harmonics: [(2, 0.12)]),
        ])

        // A longer, wobblier descending ache for a breakup or heavy loss.
        buffers[.heartbreak] = notes([
            Note(392, 0.25, 0.16, glideTo: 330, harmonics: [(2, 0.18)], vibratoRate: 4, vibratoDepth: 0.015),
            Note(294, 0.4, 0.14, glideTo: 220, harmonics: [(2, 0.15)], vibratoRate: 3.5, vibratoDepth: 0.02),
        ])

        // Bright triumphant sting for winning an award or acing something.
        buffers[.achievement] = notes([
            Note(659, 0.08, 0.2, harmonics: [(2, 0.3)]),
            Note(830, 0.08, 0.2, harmonics: [(2, 0.3)]),
            Note(988, 0.18, 0.24, harmonics: [(2, 0.35), (3, 0.15)]),
        ])

        // Sharp bright noise burst with a few high glassy pings — a window
        // (or anything else fragile) just shattered.
        buffers[.glassBreak] = mixed([
            noiseBurst(duration: 0.18, amplitude: 0.35),
            notes([
                Note(2400, 0.05, 0.12),
                Note(0, 0.015, 0),
                Note(3100, 0.04, 0.1),
                Note(0, 0.015, 0),
                Note(1800, 0.07, 0.1),
            ]),
        ])

        // Woozy, detuned wobble — feeling unwell.
        buffers[.sick] = notes([
            Note(300, 0.16, 0.18, harmonics: [(2, 0.1)], vibratoRate: 7, vibratoDepth: 0.04),
            Note(260, 0.24, 0.16, glideTo: 220, harmonics: [(2, 0.1)], vibratoRate: 6, vibratoDepth: 0.05),
        ])

        // Cute little chirp, up then down — a pet moment.
        buffers[.pet] = notes([
            Note(600, 0.045, 0.16, glideTo: 950),
            Note(950, 0.06, 0.16, glideTo: 650),
        ])

        // Upbeat major triad with a touch of sparkle — a celebration.
        buffers[.party] = mixed([
            notes([
                Note(523, 0.07, 0.18, harmonics: [(2, 0.25)]),
                Note(659, 0.07, 0.18, harmonics: [(2, 0.25)]),
                Note(784, 0.13, 0.2, harmonics: [(2, 0.3), (3, 0.1)]),
            ]),
            noiseBurst(duration: 0.08, amplitude: 0.08),
        ])

        // Polite two-tone "someone needs you" notification — plays when a
        // decision popup appears, distinct from the sharper .alert buzzer.
        buffers[.notify] = notes([
            Note(740, 0.09, 0.16, harmonics: [(2, 0.2)]),
            Note(988, 0.12, 0.18, harmonics: [(2, 0.22)]),
        ])
    }

    /// Renders a sequence of notes back to back into one buffer, with additive
    /// harmonics, optional pitch glides, and vibrato for a richer timbre than
    /// a plain sine wave.
    private func notes(_ sequence: [Note]) -> AVAudioPCMBuffer {
        let totalFrames = sequence.reduce(0) { $0 + AVAudioFrameCount($1.duration * sampleRate) }
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: max(totalFrames, 1))!
        buffer.frameLength = max(totalFrames, 1)
        let samples = buffer.floatChannelData![0]

        var offset = 0
        for note in sequence {
            let frameCount = Int(note.duration * sampleRate)
            let fadeFrames = min(frameCount / 6, Int(0.012 * sampleRate))
            for i in 0..<frameCount {
                let t = Double(i) / sampleRate
                let progress = frameCount > 1 ? Double(i) / Double(frameCount - 1) : 0
                var envelope = note.volume
                if i < fadeFrames {
                    envelope *= Double(i) / Double(max(fadeFrames, 1))
                } else if i > frameCount - fadeFrames {
                    envelope *= Double(frameCount - i) / Double(max(fadeFrames, 1))
                }

                guard note.frequency > 0, envelope > 0 else {
                    samples[offset + i] = 0
                    continue
                }

                var baseFreq = note.frequency
                if let target = note.glideTo {
                    baseFreq = note.frequency + (target - note.frequency) * progress
                }
                if note.vibratoRate > 0 {
                    baseFreq += baseFreq * note.vibratoDepth * sin(2.0 * Double.pi * note.vibratoRate * t)
                }

                var value = sin(2.0 * Double.pi * baseFreq * t)
                for (multiple, relativeVolume) in note.harmonics {
                    value += sin(2.0 * Double.pi * baseFreq * multiple * t) * relativeVolume
                }
                let normalized = value / (1 + note.harmonics.reduce(0) { $0 + $1.1 })
                samples[offset + i] = Float(normalized * envelope)
            }
            offset += frameCount
        }
        return buffer
    }

    private func noiseBurst(duration: Double, amplitude: Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let samples = buffer.floatChannelData![0]
        let total = Int(frameCount)
        for i in 0..<total {
            let decay = 1.0 - Double(i) / Double(total)
            samples[i] = Float(Double.random(in: -1...1) * amplitude * decay)
        }
        return buffer
    }

    /// Sums multiple buffers sample-for-sample (shorter ones are padded with
    /// silence), for layering e.g. a noise burst under a tone.
    private func mixed(_ layers: [AVAudioPCMBuffer]) -> AVAudioPCMBuffer {
        let frameCount = layers.map(\.frameLength).max() ?? 0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let out = buffer.floatChannelData![0]
        for layer in layers {
            let layerSamples = layer.floatChannelData![0]
            for i in 0..<Int(layer.frameLength) {
                out[i] += layerSamples[i]
            }
        }
        return buffer
    }
}
