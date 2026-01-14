import SwiftUI

struct VibesButton: View {
    
    enum Style {
        case standard
        case prominent
    }
    
    let action: () -> Void
    let imageSystemName: String
    let text: String
    let style: Style
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: imageSystemName)
                    .font(.system(size: 18, weight: .semibold))
                Text(text)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white.opacity(0.8))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(background)
            .clipShape(Capsule())
            .shadow(color: style == .prominent ? Color(hex: "667eea").opacity(0.4) : .clear, radius: 15, y: 8)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    @ViewBuilder
    var background: some View {
        switch style {
        case .standard:
            Capsule()
                .fill(.white.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        case .prominent:
            LinearGradient(
                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

// Custom button style for scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
