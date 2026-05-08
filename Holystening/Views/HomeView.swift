import SwiftUI

struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var vm = PrayerViewModel()
    @State private var showSettings = false
    @State private var pulseAnimation = false
    @State private var isIdle = false
    @State private var wokenFromIdle = false
    @State private var idleTimer: Timer?

    private let idleDelay: TimeInterval = AppConfig.idleTimeout

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: vm.isSessionActive
                        ? [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")]
                        : [Color(hex: "0d0d0d"), Color(hex: "1a1a1a"), Color(hex: "2d2d2d")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: AppConfig.backgroundTransitionDuration), value: vm.isSessionActive)

                // Re-dim on background tap after waking (sits below buttons so they still work)
                if AppConfig.tapBackgroundToDimAfterWake && wokenFromIdle && !isIdle && vm.isSessionActive {
                    Color.clear
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture { dimImmediately() }
                }

                // UI content
                VStack(spacing: 48) {
                    Spacer()

                    // Title + Focus badge
                    VStack(spacing: 12) {
                        Text("Prayer")
                            .font(.system(size: 42, weight: .thin, design: .serif))
                            .foregroundStyle(.white)

                        if vm.isSessionActive {
                            HStack(spacing: 6) {
                                Image(systemName: "moon.fill")
                                    .font(.caption)
                                Text(vm.settings.selectedFocusName + " Active")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundStyle(Color(hex: "a8edea"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "a8edea").opacity(0.15))
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(duration: 0.4), value: vm.isSessionActive)

                    // Play button
                    Button(action: vm.toggleSession) {
                        ZStack {
                            if vm.isSessionActive {
                                Circle()
                                    .stroke(Color(hex: "a8edea").opacity(0.3), lineWidth: 2)
                                    .frame(width: 160, height: 160)
                                    .scaleEffect(pulseAnimation ? 1.25 : 1.0)
                                    .opacity(pulseAnimation ? 0 : 1)
                                    .animation(
                                        .easeOut(duration: AppConfig.pulseRingDuration).repeatForever(autoreverses: false),
                                        value: pulseAnimation
                                    )
                            }

                            Circle()
                                .fill(
                                    vm.isSessionActive
                                        ? LinearGradient(
                                            colors: [Color(hex: "a8edea"), Color(hex: "fed6e3")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        : LinearGradient(
                                            colors: [Color(hex: "3a3a3a"), Color(hex: "555555")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                )
                                .frame(width: 130, height: 130)
                                .shadow(
                                    color: vm.isSessionActive
                                        ? Color(hex: "a8edea").opacity(0.5)
                                        : .black.opacity(0.4),
                                    radius: vm.isSessionActive ? 30 : 10
                                )

                            Image(systemName: vm.isSessionActive ? "stop.fill" : "play.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundStyle(
                                    vm.isSessionActive ? Color(hex: "1a1a2e") : .white
                                )
                                .offset(x: vm.isSessionActive ? 0 : 4)
                        }
                    }
                    .animation(.spring(duration: 0.5, bounce: 0.3), value: vm.isSessionActive)
                    .onChange(of: vm.isSessionActive) { _, active in
                        pulseAnimation = false
                        if active {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                pulseAnimation = true
                            }
                            resetIdleTimer()
                        } else {
                            cancelIdleTimer()
                        }
                    }

                    // Track name + progress
                    VStack(spacing: 16) {
                        Text(vm.currentTrack.name)
                            .font(.system(size: 17, weight: .regular, design: .serif))
                            .foregroundStyle(.white.opacity(0.8))

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 3)

                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "a8edea"), Color(hex: "fed6e3")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * vm.audio.progress, height: 3)
                                    .animation(.linear(duration: 0.5), value: vm.audio.progress)
                            }
                        }
                        .frame(height: 3)
                        .padding(.horizontal, 48)
                        .opacity(vm.isSessionActive ? 1 : 0.3)

                        // Loop toggle
                        Button(action: vm.toggleLoop) {
                            Image(systemName: "repeat")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(
                                    vm.isLooping
                                        ? Color(hex: "a8edea")
                                        : .white.opacity(0.35)
                                )
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(
                                            vm.isLooping
                                                ? Color(hex: "a8edea").opacity(0.15)
                                                : Color.clear
                                        )
                                )
                        }
                        .animation(.easeInOut(duration: 0.2), value: vm.isLooping)
                    }

                    Spacer()

                    Text("Focus: \(vm.settings.selectedFocusName)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, 8)
                }
                .padding()
                .opacity(isIdle ? 0 : 1)
                .animation(.easeInOut(duration: AppConfig.idleFadeDuration), value: isIdle)

                // Dim overlay when idle
                Color.black.opacity(isIdle ? AppConfig.idleDimOpacity : 0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: AppConfig.idleFadeDuration), value: isIdle)
                    .allowsHitTesting(false)

                // Full-screen tap target to wake from idle
                if isIdle {
                    Color.clear
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            wakeFromIdle()
                        }
                }
            }
            .toolbar(isIdle ? .hidden : .visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(settings: $vm.settings)
            }
            .onOpenURL { url in
                if url.scheme == "prayerapp", url.host == "start", !vm.isSessionActive {
                    vm.startSession()
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    resetIdleTimer()
                }
            }
        }
    }

    // MARK: - Idle timer

    /// Normal interaction — restart the countdown, clear woken state.
    private func resetIdleTimer() {
        idleTimer?.invalidate()
        wokenFromIdle = false
        withAnimation { isIdle = false }
        guard vm.isSessionActive else { return }
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleDelay, repeats: false) { _ in
            withAnimation(.easeInOut(duration: AppConfig.idleFadeDuration)) { isIdle = true }
        }
    }

    /// Called when tapping the screen to wake from idle — restarts the countdown.
    private func wakeFromIdle() {
        idleTimer?.invalidate()
        wokenFromIdle = AppConfig.tapBackgroundToDimAfterWake
        withAnimation(.easeInOut(duration: AppConfig.idleFadeDuration)) { isIdle = false }
        guard vm.isSessionActive else { return }
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleDelay, repeats: false) { _ in
            withAnimation(.easeInOut(duration: AppConfig.idleFadeDuration)) { isIdle = true }
        }
    }

    /// Immediately dims — used when tapping background after waking.
    private func dimImmediately() {
        idleTimer?.invalidate()
        wokenFromIdle = false
        withAnimation(.easeInOut(duration: AppConfig.idleFadeDuration)) { isIdle = true }
    }

    private func cancelIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = nil
        wokenFromIdle = false
        withAnimation { isIdle = false }
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
