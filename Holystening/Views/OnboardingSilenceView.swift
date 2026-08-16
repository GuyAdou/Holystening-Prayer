import SwiftUI

struct OnboardingSilenceView: View {
    var onContinue: () -> Void
    @State private var hasOpenedSettings = false
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme

    @State private var ctaAreaHeight: CGFloat = 80

    private var textColor: Color { colorScheme == .dark ? .white : AppColors.navy }
    @ViewBuilder private var pageBackground: some View {
        if colorScheme == .dark {
            AppColors.cloudyBackground
        } else {
            Color.white
        }
    }

    private let steps: [(title: String, desc: String)] = [
        ("Open Settings",  AppConfig.Onboarding.s2Step1Desc),
        ("Choose a Focus", AppConfig.Onboarding.s2Step2Desc),
        ("Set a schedule", AppConfig.Onboarding.s2Step3Desc),
        ("Add Holystening", AppConfig.Onboarding.s2Step4Desc),
    ]

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 24)

                    // Progress dots — step 2 active
                    HStack(spacing: 6) {
                        ForEach(0..<3) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i == 1 ? textColor : textColor.opacity(0.15))
                                .frame(width: i == 1 ? 24 : 4, height: 4)
                        }
                    }
                    .padding(.bottom, 36)

                    // Headline
                    Text(AppConfig.Onboarding.s2Headline)
                        .font(.system(size: AppConfig.Onboarding.headlineSize, weight: .light))
                        .foregroundStyle(textColor)
                        .tracking(-0.4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 12)

                    // Body
                    Text(AppConfig.Onboarding.s2Body)
                        .font(.system(size: AppConfig.Onboarding.bodySize, weight: .regular))
                        .foregroundStyle(textColor.opacity(0.56))
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 32)

                    // Steps
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 16) {
                                Text("\(index + 1)")
                                    .font(.system(size: AppConfig.Onboarding.stepNoteSize, weight: .medium))
                                    .foregroundStyle(textColor.opacity(0.45))
                                    .frame(width: 28, height: 28)
                                    .background(Circle().stroke(textColor.opacity(0.2), lineWidth: 1))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(step.title)
                                        .font(.system(size: AppConfig.Onboarding.stepTitleSize, weight: .medium))
                                        .foregroundStyle(textColor)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Text(step.desc)
                                        .font(.system(size: AppConfig.Onboarding.stepNoteSize, weight: .regular))
                                        .foregroundStyle(textColor.opacity(0.72))
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.top, 4)
                            }

                            if index < steps.count - 1 {
                                Rectangle()
                                    .fill(textColor.opacity(0.1))
                                    .frame(width: 1, height: 20)
                                    .padding(.leading, 13.5)
                                    .padding(.vertical, 7)
                            }
                        }
                    }

                    Spacer(minLength: 24)
                }
                .frame(minHeight: geo.size.height - ctaAreaHeight)
                .fontDesign(.serif)
                .padding(.horizontal, 32)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button {
                    if hasOpenedSettings {
                        onContinue()
                    } else {
                        hasOpenedSettings = true
                        if !CommandLine.arguments.contains("-UITesting") {
                            openURL(URL(string: "App-prefs:")!)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(hasOpenedSettings ? AppConfig.Onboarding.s2CTA : AppConfig.Onboarding.s2CTAOpen)
                        Text("→").font(.system(size: 18))
                    }
                    .font(.system(size: AppConfig.Onboarding.ctaSize, weight: .medium))
                    .foregroundStyle(AppColors.navy)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.ctaButton, in: Capsule())
                }
                .buttonStyle(OnboardingCTAButtonStyle())
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(pageBackground)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { ctaAreaHeight = $0 }
            }
        }
        .background(pageBackground.ignoresSafeArea())
    }
}
