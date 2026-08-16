import SwiftUI

struct OnboardingCongratsView: View {
    var onContinue: () -> Void
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

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 24)

                    // Progress dots — step 3 active
                    HStack(spacing: 6) {
                        ForEach(0..<3) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i == 2 ? textColor : textColor.opacity(0.15))
                                .frame(width: i == 2 ? 24 : 4, height: 4)
                        }
                    }
                    .padding(.bottom, 36)

                    VStack(alignment: .leading, spacing: 16) {
                        Text(AppConfig.Onboarding.s3Headline)
                            .font(.system(size: AppConfig.Onboarding.headlineSize, weight: .light))
                            .foregroundStyle(textColor)
                            .tracking(-0.5)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(AppConfig.Onboarding.s3Body)
                            .font(.system(size: AppConfig.Onboarding.bodySize, weight: .regular))
                            .foregroundStyle(textColor)
                            .lineSpacing(11)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 24)
                }
                .frame(minHeight: geo.size.height - ctaAreaHeight)
                .fontDesign(.serif)
                .padding(.horizontal, 32)
            }
            .overlay(alignment: .bottom) {
                Button(action: onContinue) {
                    Text(AppConfig.Onboarding.s3CTA)
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
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { ctaAreaHeight = $0 }
            }
        }
        .background(pageBackground.ignoresSafeArea())
    }
}
