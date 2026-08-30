import SwiftUI

struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var vm: PrayerViewModel
    @AppStorage("autoStartSession") private var autoStartSession = false
    @State private var showBible = false
    @State private var showNotes = false
    @State private var showSettings = false
    @State private var showTransition = false
    @State private var pulseAnimation = false
    @State private var isIdle = false
    @State private var idleTimer: Timer?

    private let idleDelay: TimeInterval = AppConfig.idleTimeout

    /// True when the background is dark (active session, or idle in dark mode)
    /// and foreground content should be light/white instead of navy.
    private var useLightForeground: Bool {
        vm.isSessionActive || colorScheme == .dark
    }

    var body: some View {
        ZStack {
            // Background
            Group {
                if vm.isSessionActive {
                    AppColors.sessionBackground
                } else if colorScheme == .dark {
                    AppColors.cloudyBackground
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

                Text("Prayer")
                    .font(.system(size: 42, weight: .thin, design: .serif))
                    .foregroundStyle(useLightForeground ? .white : AppColors.navy)

                // Play / Pause button + Stop button
                Button(action: vm.togglePlayPause) {
                    ZStack {
                        if vm.isSessionActive {
                            Circle()
                                .stroke(AppColors.teal.opacity(0.3), lineWidth: 2)
                                .frame(width: 160, height: 160)
                                .scaleEffect(pulseAnimation ? 1.25 : 1.0)
                                .opacity(pulseAnimation ? 0 : 1)
                                .animation(
                                    .easeOut(duration: AppConfig.pulseRingDuration).repeatForever(autoreverses: false),
                                    value: pulseAnimation
                                )
                        }

                        Circle()
                            .fill(vm.isSessionActive ? AppColors.accent : AppColors.buttonInactive)
                            .frame(width: 130, height: 130)
                            .shadow(
                                color: vm.isSessionActive ? AppColors.teal.opacity(0.5) : .black.opacity(0.15),
                                radius: vm.isSessionActive ? 30 : 10
                            )

                        let icon = !vm.isSessionActive ? "play.fill"
                            : vm.audio.isPaused ? "play.fill"
                            : "pause.fill"

                        Image(systemName: icon)
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(AppColors.navy)
                            .offset(x: (!vm.isSessionActive || vm.audio.isPaused) ? 4 : 0)
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
                        }
                        .buttonStyle(.glass)
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
                                .fill(AppColors.accentHorizontal)
                                .frame(width: geo.size.width * vm.audio.sessionProgress, height: 3)
                                .animation(.linear(duration: 0.5), value: vm.audio.sessionProgress)
                        }
                    }
                    .frame(height: 3)
                    .padding(.horizontal, 48)
                    .opacity(vm.isSessionActive ? 1 : 0.3)

                    Text(vm.isSessionActive ? vm.audio.formattedSessionRemaining : SessionDurationSteps.label(for: vm.settings.sessionDuration))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle((useLightForeground ? Color.white : AppColors.navy).opacity(0.85))
                        .opacity(vm.isSessionActive ? 1 : 0.3)
                        .contentTransition(.numericText())
                        .animation(.default, value: vm.audio.sessionRemaining)
                }
                .padding(.top, 40)

                Text("Focus On")
                    .font(.caption)
                    .foregroundStyle(AppColors.teal)
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
                    .onTapGesture { wakeFromIdle() }
            }

            // Gradient transition overlay (first launch auto-start)
            if showTransition {
                AppColors.sessionBackground
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            // Settings gear — top-right, hidden during prayer
            if !vm.isSessionActive {
                VStack {
                    HStack {
                        Spacer()
                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle((useLightForeground ? Color.white : AppColors.navy).opacity(0.7))
                        }
                        .accessibilityIdentifier("settings-gear-button")
                        .padding(.trailing, 20)
                        .padding(.top, 12)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }

            // Vertical pill — Bible + Notes, always visible
            Color.clear
                .ignoresSafeArea()
                .overlay(alignment: .bottomTrailing) {
                    VStack(spacing: 4) {
                        Button { showBible = true } label: {
                            Image(systemName: "book.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(useLightForeground ? Color.white : AppColors.navy)
                                .frame(width: 50, height: 50)
                        }
                        .accessibilityIdentifier("bible-pill-button")
                        if AppConfig.notesFeatureEnabled {
                            Button { showNotes = true } label: {
                                Image(systemName: "note.text")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(useLightForeground ? Color.white : AppColors.navy)
                                    .frame(width: 50, height: 50)
                            }
                            .accessibilityIdentifier("notes-pill-button")
                        }
                    }
                    .padding(AppConfig.notesFeatureEnabled ? 6 : 0)
                    .glassEffect(in: AppConfig.notesFeatureEnabled ? AnyShape(Capsule()) : AnyShape(Circle()))
                    .padding(.trailing, 20)
                    .padding(.bottom, 24)
                }
                .opacity(vm.isSessionActive && isIdle ? 0 : 1)
                .animation(.easeInOut(duration: AppConfig.idleFadeDuration), value: isIdle)
        }
        .animation(.spring(duration: 0.4), value: vm.isSessionActive)
        .sheet(isPresented: $showSettings) { SettingsView(settings: $vm.settings) }
        .fullScreenCover(isPresented: $showBible) { BibleView() }
        .onChange(of: showBible) { _, isShowing in
            if !isShowing { resetIdleTimer() }
        }
        .fullScreenCover(isPresented: $showNotes) { NotesView() }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { pulseAnimation = true }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { resetIdleTimer() }
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
