import Foundation
import CoreMIDI

class MIDIManager {
    static let shared = MIDIManager()
    
    // MARK: - Properties
    private var virtualPorts: [String: MIDIPortRef] = [:]
    private var destinations: [String: MIDIEndpointRef] = [:]
    private var isSetup = false
    
    // MARK: - Setup
    func setup() throws {
        guard !isSetup else { return }
        
        var client = MIDIClientRef()
        let status = MIDIClientCreate("ThreadSpace" as CFString, nil, nil, &client)
        
        guard status == noErr else {
            throw MIDIError.clientCreationFailed(status)
        }
        
        isSetup = true
    }
    
    // MARK: - Port Management
    func createVirtualPort(name: String) throws -> MIDIPortRef {
        guard isSetup else {
            throw MIDIError.notInitialized
        }
        
        if let existingPort = virtualPorts[name] {
            return existingPort
        }
        
        var port = MIDIPortRef()
        let status = MIDIOutputPortCreate(MIDIClientRef(), name as CFString, &port)
        
        guard status == noErr else {
            throw MIDIError.portCreationFailed(status)
        }
        
        virtualPorts[name] = port
        return port
    }
    
    // MARK: - Destination Management
    func addDestination(_ endpoint: MIDIEndpointRef, name: String) {
        destinations[name] = endpoint
    }
    
    func removeDestination(name: String) {
        destinations.removeValue(forKey: name)
    }
    
    // MARK: - MIDI Sending
    func sendMIDIEvent(_ event: MIDIEvent, to destinationNames: [String]) {
        for name in destinationNames {
            guard let destination = destinations[name] else {
                print("⚠️ Warning: No destination found for name: \(name)")
                continue
            }
            
            do {
                try send(event, to: destination)
            } catch {
                print("❌ Error sending MIDI to \(name): \(error)")
            }
        }
    }
    
    private func send(_ event: MIDIEvent, to destination: MIDIEndpointRef) throws {
        var packet = MIDIPacket()
        packet.timeStamp = 0
        packet.length = UInt16(event.data.count)
        
        // Copy event data into packet
        for (index, byte) in event.data.enumerated() {
            packet.data.0 = byte
            if index < event.data.count - 1 {
                packet.data.1 = event.data[index + 1]
            }
        }
        
        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        let status = MIDISend(MIDIPortRef(), destination, &packetList)
        
        guard status == noErr else {
            throw MIDIError.sendFailed(status)
        }
    }
}

// MARK: - MIDI Types
struct MIDIEvent {
    let data: [UInt8]
    
    static func noteOn(note: UInt8, velocity: UInt8, channel: UInt8) -> MIDIEvent {
        return MIDIEvent(data: [0x90 | channel, note, velocity])
    }
    
    static func noteOff(note: UInt8, velocity: UInt8, channel: UInt8) -> MIDIEvent {
        return MIDIEvent(data: [0x80 | channel, note, velocity])
    }
    
    static func controlChange(controller: UInt8, value: UInt8, channel: UInt8) -> MIDIEvent {
        return MIDIEvent(data: [0xB0 | channel, controller, value])
    }
}

// MARK: - Errors
enum MIDIError: Error {
    case notInitialized
    case clientCreationFailed(OSStatus)
    case portCreationFailed(OSStatus)
    case sendFailed(OSStatus)
}

// MARK: - Error Descriptions
extension MIDIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "MIDI Manager not initialized. Call setup() first."
        case .clientCreationFailed(let status):
            return "Failed to create MIDI client (status: \(status))"
        case .portCreationFailed(let status):
            return "Failed to create MIDI port (status: \(status))"
        case .sendFailed(let status):
            return "Failed to send MIDI message (status: \(status))"
        }
    }
}
