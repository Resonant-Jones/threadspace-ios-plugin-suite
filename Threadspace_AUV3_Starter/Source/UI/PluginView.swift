import SwiftUI

struct PluginView: View {
    @StateObject private var viewModel = PluginViewModel()
    @State private var showingCommandInput = false
    @State private var commandText = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(white: 0.1),
                    Color(white: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with voice command button
                HStack {
                    Text("ThreadSpace")
                        .font(.custom("Inter-Bold", size: 24))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showingCommandInput.toggle() }) {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                // Status Card
                StatusCard(state: viewModel.currentState)
                    .padding(.horizontal)
                
                // Modulation Controls
                ModulationControls(
                    depth: $viewModel.modulationDepth,
                    activeEffects: viewModel.activeEffects,
                    onEffectToggle: viewModel.toggleEffect
                )
                .padding()
                
                // Instance Status
                InstanceStatusView(activeInstances: viewModel.activeInstances)
                    .padding()
                
                Spacer()
                
                // Memory Log Preview
                MemoryLogView(recentSnapshots: viewModel.recentSnapshots)
                    .frame(height: 120)
                    .padding()
            }
        }
        .sheet(isPresented: $showingCommandInput) {
            CommandInputSheet(
                commandText: $commandText,
                onSubmit: { command in
                    viewModel.processCommand(command)
                    showingCommandInput = false
                    commandText = ""
                }
            )
        }
        .onAppear {
            viewModel.startUpdates()
        }
        .onDisappear {
            viewModel.stopUpdates()
        }
    }
}

// MARK: - Status Card
struct StatusCard: View {
    let state: PluginState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current State")
                .font(.custom("Inter-SemiBold", size: 18))
                .foregroundColor(.white)
            
            HStack {
                StatusItem(
                    title: "Modulation",
                    value: String(format: "%.1f", state.modulationDepth)
                )
                
                Divider()
                    .background(Color.white.opacity(0.3))
                
                StatusItem(
                    title: "Effects",
                    value: "\(state.activeEffects.count) active"
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Modulation Controls
struct ModulationControls: View {
    @Binding var depth: Float
    let activeEffects: Set<EffectType>
    let onEffectToggle: (EffectType) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Modulation")
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.white)
            
            HStack {
                Text("Depth")
                    .foregroundColor(.white)
                Slider(value: $depth)
                    .accentColor(.white)
                Text(String(format: "%.1f", depth))
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 12) {
                ForEach(EffectType.allCases, id: \.self) { effect in
                    EffectToggleButton(
                        type: effect,
                        isActive: activeEffects.contains(effect),
                        onTap: { onEffectToggle(effect) }
                    )
                }
            }
        }
    }
}

// MARK: - Instance Status
struct InstanceStatusView: View {
    let activeInstances: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Active Instances")
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(activeInstances, id: \.self) { instanceId in
                        Text(instanceId)
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}

// MARK: - Memory Log
struct MemoryLogView: View {
    let recentSnapshots: [[String: Any]]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Activity")
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.white)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(recentSnapshots.indices, id: \.self) { index in
                        if let timestamp = recentSnapshots[index]["timestamp"] as? String,
                           let command = recentSnapshots[index]["command"] as? String {
                            HStack {
                                Text(timestamp)
                                    .font(.custom("Inter-Regular", size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                                Text(command)
                                    .font(.custom("Inter-Regular", size: 14))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Command Input Sheet
struct CommandInputSheet: View {
    @Binding var commandText: String
    let onSubmit: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter command...", text: $commandText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Submit") {
                    onSubmit(commandText)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(commandText.isEmpty)
                .padding()
            }
            .navigationTitle("Voice Command")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Supporting Views
struct StatusItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.custom("Inter-Medium", size: 16))
                .foregroundColor(.white)
        }
    }
}

struct EffectToggleButton: View {
    let type: EffectType
    let isActive: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(type.rawValue.capitalized)
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(isActive ? .black : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isActive ? Color.white : Color.white.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

// MARK: - ViewModel
class PluginViewModel: ObservableObject {
    @Published var currentState = PluginState()
    @Published var modulationDepth: Float = 0.5
    @Published var activeEffects: Set<EffectType> = []
    @Published var activeInstances: [String] = []
    @Published var recentSnapshots: [[String: Any]] = []
    
    private var updateTimer: Timer?
    
    func startUpdates() {
        // Start periodic updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateState()
        }
        
        // Setup notification observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateUpdate),
            name: .pluginStateDidUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInstancesUpdate),
            name: .instancesDidUpdate,
            object: nil
        )
    }
    
    func stopUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func processCommand(_ command: String) {
        PluginCore.shared?.processCommand(command)
    }
    
    func toggleEffect(_ effect: EffectType) {
        if activeEffects.contains(effect) {
            activeEffects.remove(effect)
        } else {
            activeEffects.insert(effect)
        }
        // Update plugin state
        currentState.activeEffects = activeEffects
        PluginCore.shared?.updateState(currentState)
    }
    
    @objc private func handleStateUpdate(_ notification: Notification) {
        if let state = notification.userInfo?["state"] as? PluginState {
            DispatchQueue.main.async {
                self.currentState = state
                self.modulationDepth = state.modulationDepth
                self.activeEffects = state.activeEffects
            }
        }
    }
    
    @objc private func handleInstancesUpdate(_ notification: Notification) {
        if let instances = notification.userInfo?["instances"] as? [String] {
            DispatchQueue.main.async {
                self.activeInstances = instances
            }
        }
    }
    
    private func updateState() {
        // Read recent snapshots from MemoryBridge
        if let snapshots = MemoryBridge.shared.readLastSnapshot() {
            DispatchQueue.main.async {
                self.recentSnapshots = [snapshots] + self.recentSnapshots.prefix(4)
            }
        }
    }
}

// MARK: - Extensions
extension EffectType: CaseIterable {
    static var allCases: [EffectType] {
        [.shimmer, .delay, .reverb]
    }
}
