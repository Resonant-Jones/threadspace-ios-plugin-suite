import Foundation

/// Processes natural language commands and converts them to plugin actions
class CommandProcessor {
    static let shared = CommandProcessor()
    
    /// Known command patterns and their corresponding actions
    private let commandPatterns: [String: (String) -> Action] = [
        "soften.*modulation": { _ in .adjustModulation(depth: -0.2) },
        "increase.*modulation": { _ in .adjustModulation(depth: 0.2) },
        "add.*shimmer": { _ in .addEffect(type: .shimmer) },
        "remove.*lfo": { _ in .removeModulator(type: .lfo) }
    ]
    
    /// Processes a natural language command and returns the corresponding action
    func processCommand(_ command: String) -> Action? {
        let lowercased = command.lowercased()
        
        for (pattern, handler) in commandPatterns {
            if lowercased.range(of: pattern, options: .regularExpression) != nil {
                return handler(command)
            }
        }
        
        return nil
    }
}

/// Represents possible actions that can be triggered by commands
enum Action {
    case adjustModulation(depth: Float)
    case addEffect(type: EffectType)
    case removeModulator(type: ModulatorType)
    
    /// Converts the action to a JSON representation for logging
    func toJSON() -> [String: Any] {
        switch self {
        case .adjustModulation(let depth):
            return ["type": "modulation_adjust", "depth": depth]
        case .addEffect(let type):
            return ["type": "add_effect", "effect": type.rawValue]
        case .removeModulator(let type):
            return ["type": "remove_modulator", "modulator": type.rawValue]
        }
    }
}

enum EffectType: String {
    case shimmer
    case delay
    case reverb
}

enum ModulatorType: String {
    case lfo
    case envelope
    case random
}
