import SwiftUI

struct OnboardingWelcomeView: View {
    var onContinue: () -> Void

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
        (
            "note.text",
            "Notes",
            "Write down what you receive in the spirit while praying."
        ),
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // App icon
                Image("dove")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                    .padding(.bottom, 28)

                // Headline + body
                VStack(spacing: 12) {
                    Text(AppConfig.Onboarding.s1Headline)
                        .font(.system(size: AppConfig.Onboarding.headlineSize, weight: .semibold))
                        .foregroundStyle(Color(hex: "1a1a2e"))
                        .multilineTextAlignment(.center)

                    Text(AppConfig.Onboarding.s1Body)
                        .font(.system(size: AppConfig.Onboarding.bodySize, weight: .regular))
                        .foregroundStyle(Color(hex: "1a1a2e").opacity(0.56))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 36)

                // Feature rows
                VStack(spacing: 24) {
                    ForEach(features, id: \.title) { feature in
                        HStack(alignment: .top, spacing: 18) {
                            Image(systemName: feature.icon)
                                .font(.system(size: 26))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "B8D4E8"), Color(hex: "E8CC82"), Color(hex: "FAE8A8")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(feature.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color(hex: "1a1a2e"))

                                Text(feature.body)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(Color(hex: "1a1a2e").opacity(0.56))
                                    .lineSpacing(3)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                // Step dots — dot 1 active
                HStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i == 0 ? Color(hex: "1a1a2e") : Color(hex: "1a1a2e").opacity(0.15))
                            .frame(width: i == 0 ? 24 : 4, height: 4)
                    }
                }
                .padding(.bottom, 20)

                // CTA button
                Button(action: onContinue) {
                    HStack(spacing: 6) {
                        Text(AppConfig.Onboarding.s1CTA)
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

struct OnboardingCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.78 : 1)
            .scaleEffect(configuration.isPressed ? 0.974 : 1)
            .shadow(
                color: Color(hex: "a8edea").opacity(configuration.isPressed ? 0.2 : 0.5),
                radius: configuration.isPressed ? 5 : 14,
                x: 0, y: configuration.isPressed ? 2 : 8
            )
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
