import SwiftUI

struct FixInterruptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var hasOpenedSettings = false

    private let steps: [(title: String, desc: String)] = [
        ("Open Settings",   AppConfig.Onboarding.s2Step1Desc),
        ("Choose a Focus",  AppConfig.Onboarding.s2Step2Desc),
        ("Set a schedule",  AppConfig.Onboarding.s2Step3Desc),
        ("Add Holystening", AppConfig.Onboarding.s2Step4Desc),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Block everything out.")
                        .font(.system(size: AppConfig.Onboarding.headlineSize, weight: .light))
                        .foregroundStyle(Color(hex: "1a1a2e"))
                        .tracking(-0.4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 12)

                    Text(AppConfig.Onboarding.s2Body)
                        .font(.system(size: AppConfig.Onboarding.bodySize, weight: .regular))
                        .foregroundStyle(Color(hex: "1a1a2e").opacity(0.56))
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 40)

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                                Text("\(index + 1)")
                                    .font(.system(size: AppConfig.Onboarding.stepNoteSize, weight: .medium))
                                    .foregroundStyle(Color(hex: "1a1a2e").opacity(0.45))
                                    .frame(width: 28, height: 28)
                                    .background(Circle().stroke(Color(hex: "1a1a2e").opacity(0.2), lineWidth: 1))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(step.title)
                                        .font(.system(size: AppConfig.Onboarding.stepTitleSize, weight: .medium))
                                        .foregroundStyle(Color(hex: "1a1a2e"))
                                        .fixedSize(horizontal: false, vertical: true)

                                    Text(step.desc)
                                        .font(.system(size: AppConfig.Onboarding.stepNoteSize, weight: .regular))
                                        .foregroundStyle(Color(hex: "1a1a2e").opacity(0.72))
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.top, 4)
                            }

                            if index < steps.count - 1 {
                                Rectangle()
                                    .fill(Color(hex: "1a1a2e").opacity(0.1))
                                    .frame(width: 1, height: 20)
                                    .padding(.leading, 13.5)
                                    .padding(.vertical, 7)
                            }
                        }
                    }
                }
                .fontDesign(.serif)
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .padding(.bottom, 16)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button {
                    if hasOpenedSettings {
                        dismiss()
                    } else {
                        hasOpenedSettings = true
                        openURL(URL(string: "App-prefs:")!)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(hasOpenedSettings ? "Done" : "Open Settings")
                        Text("→").font(.system(size: 18))
                    }
                    .font(.system(size: AppConfig.Onboarding.ctaSize, weight: .medium))
                    .foregroundStyle(Color(hex: "1a1a2e"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.ctaButton, in: Capsule())
                }
                .buttonStyle(OnboardingCTAButtonStyle())
                .padding(.horizontal, 28)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color.white)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Fix Interruptions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    CloseButton(identifier: "fix-interruptions-close-button") { dismiss() }
                }
            }
        }
    }
}
