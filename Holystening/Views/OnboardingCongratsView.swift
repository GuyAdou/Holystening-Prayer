import SwiftUI

struct OnboardingCongratsView: View {
    var onContinue: () -> Void

    @State private var ctaAreaHeight: CGFloat = 80

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 24)

                    // Progress dots — step 3 active
                    HStack(spacing: 6) {
                        ForEach(0..<3) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i == 2 ? Color(hex: "1a1a2e") : Color(hex: "1a1a2e").opacity(0.15))
                                .frame(width: i == 2 ? 24 : 4, height: 4)
                        }
                    }
                    .padding(.bottom, 36)

                    VStack(alignment: .leading, spacing: 16) {
                        Text(AppConfig.Onboarding.s3Headline)
                            .font(.system(size: AppConfig.Onboarding.headlineSize, weight: .light))
                            .foregroundStyle(Color(hex: "1a1a2e"))
                            .tracking(-0.5)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(AppConfig.Onboarding.s3Body)
                            .font(.system(size: AppConfig.Onboarding.bodySize, weight: .regular))
                            .foregroundStyle(Color(hex: "1a1a2e").opacity(0.56))
                            .lineSpacing(11)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 24)
                }
                .frame(minHeight: geo.size.height - ctaAreaHeight)
                .fontDesign(.serif)
                .padding(.horizontal, 32)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button(action: onContinue) {
                    Text(AppConfig.Onboarding.s3CTA)
                        .font(.system(size: AppConfig.Onboarding.ctaSize, weight: .medium))
                        .foregroundStyle(Color(hex: "1a1a2e"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.ctaButton, in: Capsule())
                }
                .buttonStyle(OnboardingCTAButtonStyle())
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color.white)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { ctaAreaHeight = $0 }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}
