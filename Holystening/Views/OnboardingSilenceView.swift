import SwiftUI

struct OnboardingSilenceView: View {
    var onContinue: () -> Void
    @State private var hasOpenedSettings = false
    @Environment(\.openURL) private var openURL

    private let steps: [(title: String, desc: String)] = [
        ("Open Settings",  AppConfig.Onboarding.s2Step1Desc),
        ("Choose a Focus", AppConfig.Onboarding.s2Step2Desc),
        ("Set a schedule", AppConfig.Onboarding.s2Step3Desc),
        ("Add Holystening", AppConfig.Onboarding.s2Step4Desc),
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Progress dots — step 2 active
                HStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i == 1 ? Color(hex: "1a1a2e") : Color(hex: "1a1a2e").opacity(0.15))
                            .frame(width: i == 1 ? 24 : 4, height: 4)
                    }
                }
                .padding(.bottom, 46)

                // Headline
                Text(AppConfig.Onboarding.s2Headline)
                    .font(.system(size: AppConfig.Onboarding.headlineSize, weight: .light))
                    .foregroundStyle(Color(hex: "1a1a2e"))
                    .tracking(-0.4)
                    .padding(.bottom, 16)

                // Body
                Text(AppConfig.Onboarding.s2Body)
                    .font(.system(size: AppConfig.Onboarding.bodySize, weight: .regular))
                    .foregroundStyle(Color(hex: "1a1a2e").opacity(0.56))
                    .lineSpacing(11)
                    .padding(.bottom, 46)

                // Steps
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

                                Text(step.desc)
                                    .font(.system(size: AppConfig.Onboarding.stepNoteSize, weight: .regular))
                                    .foregroundStyle(Color(hex: "1a1a2e").opacity(0.72))
                                    .lineSpacing(3)
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

                Spacer()

                // Settings / Done button
                Button {
                    if hasOpenedSettings {
                        onContinue()
                    } else {
                        hasOpenedSettings = true
                        openURL(URL(string: "App-prefs:")!)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(hasOpenedSettings ? AppConfig.Onboarding.s2CTA : AppConfig.Onboarding.s2CTAOpen)
                        Text("→").font(.system(size: 18))
                    }
                    .font(.system(size: AppConfig.Onboarding.ctaSize, weight: .medium))
                    .foregroundStyle(Color(hex: "1a1a2e"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "a8edea"), Color(hex: "fed6e3")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Capsule()
                    )
                }
                .buttonStyle(OnboardingCTAButtonStyle())
            }
            .fontDesign(.serif)
            .padding(.horizontal, 32)
            .padding(.top, 24)
            .padding(.bottom, 10)
        }
    }
}
