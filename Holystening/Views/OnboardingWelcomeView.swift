import SwiftUI

struct OnboardingWelcomeView: View {
    var onContinue: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    private let features: [(icon: String, title: String, body: String)] = [
        (
            "moon.fill",
            "Pray without distractions",
            "Holystening automatically activates your Apple Focus mode to block notifications and interruptions."
        ),
        (
            "book.fill",
            "Bible",
            "Read and meditate on the word of God during your prayer time."
        ),
    ]

    // Measured height of the safeAreaInset (dots + CTA button + padding)
    @State private var ctaAreaHeight: CGFloat = 100

    private var textColor: Color { colorScheme == .dark ? .white : AppColors.navy }
    @ViewBuilder private var pageBackground: some View {
        if colorScheme == .dark {
            AppColors.cloudyBackground
        } else {
            Color.white
        }
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 24)

                    // App icon
                    Image("dove")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                        .padding(.bottom, 24)

                    // Headline + body
                    VStack(spacing: 12) {
                        Text(AppConfig.Onboarding.s1Headline)
                            .font(.system(size: AppConfig.Onboarding.headlineSize, weight: .semibold))
                            .foregroundStyle(textColor)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(AppConfig.Onboarding.s1Body)
                            .font(.system(size: AppConfig.Onboarding.bodySize, weight: .regular))
                            .foregroundStyle(textColor.opacity(0.56))
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, 32)

                    // Feature rows
                    VStack(spacing: 20) {
                        ForEach(features, id: \.title) { feature in
                            HStack(alignment: .top, spacing: 18) {
                                Image(systemName: feature.icon)
                                    .font(.system(size: 26))
                                    .foregroundStyle(AppColors.featureIcon)
                                    .frame(width: 40, height: 40, alignment: .center)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(feature.title)
                                        .font(.system(size: AppConfig.Onboarding.featureRowTitleSize, weight: .semibold))
                                        .foregroundStyle(textColor)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Text(feature.body)
                                        .font(.system(size: AppConfig.Onboarding.featureRowBodySize, weight: .regular))
                                        .foregroundStyle(textColor.opacity(0.56))
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                VStack(spacing: 0) {
                    // Step dots — dot 1 active
                    HStack(spacing: 6) {
                        ForEach(0..<3) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i == 0 ? textColor : textColor.opacity(0.15))
                                .frame(width: i == 0 ? 24 : 4, height: 4)
                        }
                    }
                    .padding(.bottom, 16)

                    // CTA button
                    Button(action: onContinue) {
                        Text(AppConfig.Onboarding.s1CTA)
                            .font(.system(size: AppConfig.Onboarding.ctaSize, weight: .medium))
                            .foregroundStyle(AppColors.navy)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(AppColors.ctaButton, in: Capsule())
                    }
                    .buttonStyle(OnboardingCTAButtonStyle())
                }
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

struct OnboardingCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.78 : 1)
            .scaleEffect(configuration.isPressed ? 0.974 : 1)
            .shadow(
                color: AppColors.ctaButtonShadow.opacity(configuration.isPressed ? 0.2 : 0.5),
                radius: configuration.isPressed ? 5 : 14,
                x: 0, y: configuration.isPressed ? 2 : 8
            )
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
