import Foundation
import AudioToolbox
import CoreAudioKit

class PluginCore: AUAudioUnit {
    // MARK: - Properties
    private let commandProcessor = CommandProcessor.shared
    private var currentState: PluginState
    
    // MARK: - Initialization
    override init(componentDescription: AudioComponentDescription,
                 options: AudioComponentInstantiationOptions = []) throws {
        currentState = PluginState()
        try super.init(componentDescription: componentDescription, options: options)
        
        // Setup observers for state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange),
            name: .stateDidChange,
            object: nil
        )
    }
    
    // MARK: - Command Processing
    func processCommand(_ command: String) {
        // Process command on background queue to avoid blocking audio thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let action = self.commandProcessor.processCommand(command) {
                self.executeAction(action)
                self.logStateChange(command: command, action: action)
            }
        }
    }
    
    private func executeAction(_ action: Action) {
        switch action {
        case .adjustModulation(let depth):
            currentState.modulationDepth += depth
            // Clamp between 0 and 1
            currentState.modulationDepth = min(1, max(0, currentState.modulationDepth))
            notifyStateChange()
            
        case .addEffect(let type):
            currentState.activeEffects.insert(type)
            notifyStateChange()
            
        case .removeModulator(let type):
            currentState.activeModulators.remove(type)
            notifyStateChange()
        }
    }
    
    // MARK: - State Management
    private func logStateChange(command: String, action: Action) {
        let snapshot: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "command": command,
            "action": action.toJSON(),
            "state": currentState.toJSON()
        ]
        
        MemoryBridge.shared.writeSnapshot(snapshot)
    }
    
    @objc private func handleStateChange() {
        // Notify UI of state changes
        NotificationCenter.default.post(
            name: .pluginStateDidUpdate,
            object: nil,
            userInfo: ["state": currentState]
        )
    }
    
    private func notifyStateChange() {
        NotificationCenter.default.post(name: .stateDidChange, object: nil)
    }
}

// MARK: - Plugin State
struct PluginState {
    var modulationDepth: Float = 0.5
    var activeEffects: Set<EffectType> = []
    var activeModulators: Set<ModulatorType> = []
    
    func toJSON() -> [String: Any] {
        return [
            "modulation_depth": modulationDepth,
            "active_effects": activeEffects.map { $0.rawValue },
            "active_modulators": activeModulators.map { $0.rawValue }
        ]
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let stateDidChange = Notification.Name("com.threadspace.plugin.stateDidChange")
    static let pluginStateDidUpdate = Notification.Name("com.threadspace.plugin.stateDidUpdate")
}
