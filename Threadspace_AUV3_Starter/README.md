# ThreadSpace AUv3 Plugin Suite

A modular, AI-assisted MIDI effect plugin collection built for iOS hosts. ThreadSpace plugins are designed to be conversational, memory-aware, and deeply integrated with the ThreadSpace creative ecosystem.

## 🎯 Core Features

### Natural Language Control
- Process voice or text commands to control plugin parameters
- Example: "soften that modulation from yesterday" or "add shimmer to the lead"
- AI-assisted parameter mapping and context awareness

### Memory Integration
- All plugin states are logged to a shared memory system
- Historical snapshots enable context-aware AI assistance
- Cross-session recall of creative decisions

### Multi-Instance Support
- Run multiple plugin instances simultaneously
- Automatic instance synchronization
- Shared state management across instances

### Advanced MIDI Routing
- Route MIDI from one instance to multiple synths
- Virtual port management for complex routing scenarios
- Robust error handling and port monitoring

## 🏗 Architecture

### Core Components

1. **CommandProcessor**
   - Natural language command parsing
   - Action mapping and validation
   - Integration with AI assistant layer

2. **PluginCore**
   - AUv3 audio unit implementation
   - State management and synchronization
   - Command execution and routing

3. **MIDIManager**
   - Virtual port creation and management
   - Multi-destination MIDI routing
   - Error handling and recovery

4. **InstanceSync**
   - Multi-instance state synchronization
   - Instance health monitoring
   - Cross-instance communication

5. **MemoryBridge**
   - State snapshot logging
   - Historical context retrieval
   - Shared container management

### UI Components

Built with SwiftUI for a modern, responsive interface:
- Voice command input
- Real-time status display
- Modulation controls
- Instance monitoring
- Memory log viewer

## 🔧 Development

### Requirements
- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+

### Host Compatibility
- ✅ AUM (Audio Unit Mixer)
- ✅ Logic Pro for iPad
- ✅ Drambo
- ✅ Loopy Pro

### Building
1. Open the Xcode project
2. Select your development team
3. Build for iOS device or simulator

## 📝 Usage

### Basic Operation
1. Insert plugin into your host (e.g., AUM)
2. Use voice commands or touch controls
3. Monitor state in the memory log
4. Adjust parameters via natural language

### Voice Commands
Example commands:
- "Soften the modulation"
- "Add shimmer effect"
- "Remove LFO"
- "Recall yesterday's settings"

### Memory System
- All changes are logged to MemoryBridge
- Access historical states via the memory log
- AI assistant can reference past sessions

## 🔄 State Management

The plugin maintains state across:
- Multiple instances (via InstanceSync)
- Sessions (via MemoryBridge)
- Host applications (via shared container)

## 🎛 Planned Modules

### ReactiveModulators
- Modular LFO system
- Natural language envelope control
- Dynamic parameter mapping

### GestureMatrix
- Multi-touch control surface
- Parameter routing matrix
- Gesture recording and playback

## 📄 License

© 2025 ThreadSpace. All rights reserved.
Currently under closed-source development.
