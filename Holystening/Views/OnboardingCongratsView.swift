import SwiftUI

struct OnboardingCongratsView: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text(AppConfig.Onboarding.s3Headline)
                        .font(.system(size: AppConfig.Onboarding.headlineSize, weight: .light))
                        .foregroundStyle(Color(hex: "1a1a2e"))
                        .tracking(-0.5)

                    Text(AppConfig.Onboarding.s3Body)
                        .font(.system(size: AppConfig.Onboarding.bodySize, weight: .regular))
                        .foregroundStyle(Color(hex: "1a1a2e").opacity(0.56))
                        .lineSpacing(11)
                }

                Spacer()

                Button(action: onContinue) {
                    HStack(spacing: 6) {
                        Text(AppConfig.Onboarding.s3CTA)
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
