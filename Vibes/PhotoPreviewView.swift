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
                
                Text("👀")
                    .font(.system(size: 50))
                
                Text("looking good?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("preview your photo before submitting")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                
                // Photo preview
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "f093fb")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: Color(hex: "667eea").opacity(0.3), radius: 20, y: 10)
                    .padding(.horizontal, 24)
                
                Spacer()
                
                VibesButton(action: onSubmit, imageSystemName: "checkmark.circle.fill", text: "check my vibes", style: .prominent)

                VibesButton(action: onRetake, imageSystemName: "arrow.counterclockwise", text: "retake photo", style: .standard)
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
