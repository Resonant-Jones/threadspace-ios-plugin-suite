import Foundation

/// Manages synchronization between multiple plugin instances
class InstanceSync {
    static let shared = InstanceSync()
    
    // MARK: - Properties
    private var instances: [String: PluginInstance] = [:]
    private let syncQueue = DispatchQueue(label: "com.threadspace.instancesync")
    private let heartbeatTimer: Timer?
    
    // MARK: - Initialization
    private init() {
        // Start heartbeat timer for instance health monitoring
        heartbeatTimer = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: true
        ) { [weak self] _ in
            self?.checkInstanceHealth()
        }
    }
    
    // MARK: - Instance Management
    func registerInstance(id: String, core: PluginCore) {
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            
            let instance = PluginInstance(
                id: id,
                core: core,
                lastHeartbeat: Date()
            )
            
            self.instances[id] = instance
            self.broadcastInstanceUpdate()
        }
    }
    
    func unregisterInstance(id: String) {
        syncQueue.async { [weak self] in
            self?.instances.removeValue(forKey: id)
            self?.broadcastInstanceUpdate()
        }
    }
    
    // MARK: - State Synchronization
    func broadcastStateChange(from sourceId: String, state: PluginState) {
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Update all instances except the source
            for (id, instance) in self.instances where id != sourceId {
                instance.core.updateState(state)
            }
            
            // Log state change to memory bridge
            let snapshot: [String: Any] = [
                "timestamp": ISO8601DateFormatter().string(from: Date()),
                "source_instance": sourceId,
                "state": state.toJSON(),
                "active_instances": Array(self.instances.keys)
            ]
            
            MemoryBridge.shared.writeSnapshot(snapshot)
        }
    }
    
    // MARK: - Health Monitoring
    private func checkInstanceHealth() {
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            
            let now = Date()
            let staleInstances = self.instances.filter { 
                now.timeIntervalSince($0.value.lastHeartbeat) > 5.0
            }
            
            // Remove stale instances
            for (id, _) in staleInstances {
                self.instances.removeValue(forKey: id)
            }
            
            if !staleInstances.isEmpty {
                self.broadcastInstanceUpdate()
            }
        }
    }
    
    func heartbeat(instanceId: String) {
        syncQueue.async { [weak self] in
            self?.instances[instanceId]?.lastHeartbeat = Date()
        }
    }
    
    // MARK: - Private Methods
    private func broadcastInstanceUpdate() {
        NotificationCenter.default.post(
            name: .instancesDidUpdate,
            object: nil,
            userInfo: ["instances": Array(instances.keys)]
        )
    }
}

// MARK: - Supporting Types
private struct PluginInstance {
    let id: String
    let core: PluginCore
    var lastHeartbeat: Date
}

// MARK: - Notifications
extension Notification.Name {
    static let instancesDidUpdate = Notification.Name("com.threadspace.instances.didUpdate")
}

// MARK: - PluginCore Extension
extension PluginCore {
    func updateState(_ state: PluginState) {
        // Implementation in PluginCore.swift
    }
}
