// MemoryBridge.swift
// Handles local state sync between the AUV3 plugin and the ThreadSpace memory system

import Foundation

class MemoryBridge {

    static let shared = MemoryBridge()

    private let memoryLogFileName = "ThreadSpaceMemoryLog.json"

    private var memoryLogURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.threadspace.memory")?.appendingPathComponent(memoryLogFileName)
    }

    /// Write a state snapshot (e.g. track configs, modulations, plugin state) to memory log
    func writeSnapshot(_ snapshot: [String: Any]) {
        guard let url = memoryLogURL else { return }
        do {
            let data = try JSONSerialization.data(withJSONObject: snapshot, options: [.prettyPrinted])
            try data.write(to: url)
        } catch {
            print("❌ Error writing to memory log: \(error)")
        }
    }

    /// Read the last known state snapshot from memory
    func readLastSnapshot() -> [String: Any]? {
        guard let url = memoryLogURL else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let snapshot = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            return snapshot
        } catch {
            print("⚠️ Error reading memory snapshot: \(error)")
            return nil
        }
    }

    /// Example structure for a snapshot
    func exampleSnapshot() -> [String: Any] {
        return [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "project": "Morning Jam",
            "tracks": [
                ["id": 1, "name": "Pad", "instrument": "Moog", "modulation": "slow_lfo"],
                ["id": 2, "name": "Lead", "instrument": "Diva", "modulation": "flutter"]
            ],
            "host": "AUM",
            "instance": "ThreadSpaceAUV3_01"
        ]
    }
}
