import SwiftUI

struct OnboardingContainerView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("autoStartSession") private var autoStartSession = false
    @State private var step = 1

    var body: some View {
        Group {
            switch step {
            case 1:
                OnboardingWelcomeView { step = 2 }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            case 2:
                OnboardingSilenceView { step = 3 }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            default:
                OnboardingCongratsView {
                    autoStartSession = true
                    hasCompletedOnboarding = true
                }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: step)
    }
}
