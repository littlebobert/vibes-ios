import SwiftUI

struct PhotoPreviewView: View {
    let image: UIImage
    var onSubmit: () -> Void
    var onRetake: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0f0c29"),
                    Color(hex: "302b63"),
                    Color(hex: "24243e")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                /// to do: instruction text
                
                /// to do: image preview, etc.
                
                /// to do: Continue button

                /// to do: Retake button
            }
            .padding(24)
        }
    }
}

#Preview {
    PhotoPreviewView(
        image: UIImage(systemName: "photo")!,
        onSubmit: {},
        onRetake: {}
    )
}

// MARK: - Vibes Style Modifier

struct VibesImageStyle: ViewModifier {
    var cornerRadius: CGFloat = 20
    var lineWidth: CGFloat = 3
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "f093fb")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: lineWidth
                    )
            )
            .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 20, y: 10)
    }
}

extension View {
    func vibesStyle(cornerRadius: CGFloat = 20, lineWidth: CGFloat = 3) -> some View {
        modifier(VibesImageStyle(cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
}
