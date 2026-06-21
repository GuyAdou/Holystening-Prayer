import SwiftUI

struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var vm = PrayerViewModel()
    @AppStorage("autoStartSession") private var autoStartSession = false
    @State private var showSettings = false
    @State private var showBible = false
    @State private var showNotes = false
    @State private var showTransition = false
    @State private var pulseAnimation = false
    @State private var isIdle = false
    @State private var idleTimer: Timer?

    private let idleDelay: TimeInterval = AppConfig.idleTimeout

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Group {
                    if vm.isSessionActive {
                        LinearGradient(
                            colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white
                    }
                }
                .ignoresSafeArea()
                .animation(.easeInOut(duration: AppConfig.backgroundTransitionDuration), value: vm.isSessionActive)

                // Tap anywhere to dim immediately during an active session
                if !isIdle && vm.isSessionActive {
                    Color.clear
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture { dimImmediately() }
                }

                // UI content
                VStack(spacing: 48) {
                    Spacer()

                    // Title
                    Text("Prayer")
                        .font(.system(size: 42, weight: .thin, design: .serif))
                        .foregroundStyle(vm.isSessionActive ? .white : Color(hex: "1a1a2e"))

                    // Play / Pause button + Stop button
                    Button(action: vm.togglePlayPause) {
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
                                                colors: [Color(hex: "e8e8e8"), Color(hex: "d0d0d0")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                    )
                                    .frame(width: 130, height: 130)
                                    .shadow(
                                        color: vm.isSessionActive
                                            ? Color(hex: "a8edea").opacity(0.5)
                                            : .black.opacity(0.15),
                                        radius: vm.isSessionActive ? 30 : 10
                                    )

                                let icon = !vm.isSessionActive ? "play.fill"
                                    : vm.isPaused ? "play.fill"
                                    : "pause.fill"

                                Image(systemName: icon)
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundStyle(Color(hex: "1a1a2e"))
                                    .offset(x: (!vm.isSessionActive || vm.isPaused) ? 4 : 0)
                            }
                        }
                        .accessibilityIdentifier("prayer-play-button")
                        .animation(.spring(duration: 0.5, bounce: 0.3), value: vm.isSessionActive)
                        .onChange(of: vm.isSessionActive) { _, active in
                            pulseAnimation = false
                            if active {
                                if !showTransition {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        pulseAnimation = true
                                    }
                                }
                                resetIdleTimer()
                            } else {
                                cancelIdleTimer()
                            }
                        }
                        .overlay(alignment: .bottom) {
                            if vm.isSessionActive {
                                Button(action: vm.stopSession) {
                                    Image(systemName: "stop.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.9))
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(.white.opacity(0.2)))
                                }
                                .offset(y: 64)
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .animation(.spring(duration: 0.4), value: vm.isSessionActive)

                    // Progress
                    VStack(spacing: 16) {
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
                                        : (vm.isSessionActive ? .white.opacity(0.35) : Color(hex: "1a1a2e").opacity(0.35))
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
                    .padding(.top, 40)

                    Text("Focus On")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "a8edea"))
                        .opacity(vm.isSessionActive ? 1 : 0)

                    Spacer()

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

                // Gradient transition overlay (first launch auto-start)
                if showTransition {
                    LinearGradient(
                        colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                }

                // Bottom buttons
                VStack {
                    Spacer()
                    HStack {
                        Button { showNotes = true } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 15, weight: .medium))
                                Text("Notes")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundStyle(vm.isSessionActive ? .white : Color(hex: "1a1a2e"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        }
                        .accessibilityIdentifier("notes-pill-button")
                        .padding(.leading, 20)
                        .padding(.bottom, 32)

                        Spacer()

                        Button { showBible = true } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 15, weight: .medium))
                                Text("Bible")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundStyle(vm.isSessionActive ? .white : Color(hex: "1a1a2e"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        }
                        .accessibilityIdentifier("bible-pill-button")
                        .padding(.trailing, 20)
                        .padding(.bottom, 32)
                    }
                }
                .opacity(isIdle ? 0 : 1)
                .animation(.easeInOut(duration: AppConfig.idleFadeDuration), value: isIdle)
            }
            .toolbar(isIdle ? .hidden : .visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(vm.isSessionActive ? .white.opacity(0.7) : Color(hex: "1a1a2e").opacity(0.7))
                    }
                    .accessibilityIdentifier("settings-gear-button")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(settings: $vm.settings)
            }
            .sheet(isPresented: $showBible) {
                BibleView()
            }
            .sheet(isPresented: $showNotes) {
                NotesView()
            }
            .onChange(of: showNotes) { _, isShowing in
                if !isShowing { resetIdleTimer() }
            }
            .onOpenURL { url in
                if url.scheme == "prayerapp", url.host == "start", !vm.isSessionActive {
                    vm.startSession()
                }
            }
            .onAppear {
                if autoStartSession {
                    autoStartSession = false
                    showTransition = true
                    vm.startSession()
                    withAnimation(.easeOut(duration: 0.8)) { showTransition = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        pulseAnimation = true
                    }
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

    private func resetIdleTimer() {
        idleTimer?.invalidate()
        withAnimation { isIdle = false }
        guard vm.isSessionActive else { return }
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleDelay, repeats: false) { _ in
            withAnimation(.easeInOut(duration: AppConfig.idleFadeDuration)) { isIdle = true }
        }
    }

    private func wakeFromIdle() {
        idleTimer?.invalidate()
        withAnimation(.easeInOut(duration: AppConfig.idleFadeDuration)) { isIdle = false }
        guard vm.isSessionActive else { return }
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleDelay, repeats: false) { _ in
            withAnimation(.easeInOut(duration: AppConfig.idleFadeDuration)) { isIdle = true }
        }
    }

    private func dimImmediately() {
        idleTimer?.invalidate()
        withAnimation(.easeInOut(duration: AppConfig.idleFadeDuration)) { isIdle = true }
    }

    private func cancelIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = nil
        withAnimation { isIdle = false }
    }
}
