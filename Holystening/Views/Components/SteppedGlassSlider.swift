import SwiftUI
import UIKit

/// A discrete, glass-styled slider. Purely mechanical — it knows nothing
/// about what its steps represent, only how many there are — so it can
/// back any stepped setting (session duration today; fade length, volume,
/// etc. later) just by changing `stepCount` and what drives `selection`.
struct SteppedGlassSlider: View {
    @Binding var selection: Int
    let stepCount: Int

    var tint: Color = AppColors.teal
    var trackHeight: CGFloat = 6
    var thumbDiameter: CGFloat = 30

    @State private var isDragging = false
    @State private var dragX: CGFloat?

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let x = dragX ?? width * fraction(width: width)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: trackHeight)

                Capsule()
                    .fill(tint)
                    .frame(width: max(x, trackHeight), height: trackHeight)

                ticks

                Circle()
                    .glassEffect(in: Circle())
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .scaleEffect(isDragging ? 1.12 : 1.0)
                    .offset(x: x - thumbDiameter / 2)
                    .animation(.spring(duration: 0.2), value: isDragging)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture(width: width))
        }
        .frame(height: thumbDiameter)
        .accessibilityElement()
        .accessibilityValue("Step \(selection + 1) of \(stepCount)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: selection = min(selection + 1, stepCount - 1)
            case .decrement: selection = max(selection - 1, 0)
            default: break
            }
        }
    }

    private func fraction(width: CGFloat) -> CGFloat {
        guard stepCount > 1 else { return 0 }
        return CGFloat(selection) / CGFloat(stepCount - 1)
    }

    private var ticks: some View {
        HStack(spacing: 0) {
            ForEach(0..<stepCount, id: \.self) { i in
                Circle()
                    .fill(i <= selection ? Color.white.opacity(0.85) : Color.primary.opacity(0.2))
                    .frame(width: 3, height: 3)
                if i < stepCount - 1 { Spacer(minLength: 0) }
            }
        }
        .padding(.horizontal, thumbDiameter / 2 - 1.5)
    }

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDragging = true
                let clamped = min(max(value.location.x, 0), width)
                dragX = clamped
                guard stepCount > 1 else { return }
                let stepWidth = width / CGFloat(stepCount - 1)
                let nearest = Int((clamped / stepWidth).rounded())
                let clampedStep = min(max(nearest, 0), stepCount - 1)
                if clampedStep != selection {
                    selection = clampedStep
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onEnded { _ in
                isDragging = false
                withAnimation(.spring(duration: 0.25)) { dragX = nil }
            }
    }
}
