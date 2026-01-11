import SwiftUI

struct NamePromptView: View {
    @Binding var userName: String
    var onContinue: () -> Void
    
    @State private var inputName: String = ""
    @State private var isAnimating = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color(hex: "667eea"),
                    Color(hex: "764ba2"),
                    Color(hex: "f093fb")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .hueRotation(.degrees(isAnimating ? 30 : 0))
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
            
            // Floating particles
            GeometryReader { geo in
                ForEach(0..<15) { i in
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 20...60))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .blur(radius: 2)
                }
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo/Title
                VStack(spacing: 16) {
                    Text("✨")
                        .font(.system(size: 80))
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("VIBES")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                    
                    Text("get your vibe checked")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(2)
                }
                
                Spacer()
                
                // Name input section
                VStack(spacing: 24) {
                    Text("what's your name?")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    TextField("", text: $inputName)
                        .placeholder(when: inputName.isEmpty) {
                            Text("enter your name...")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.white.opacity(0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            continueIfValid()
                        }
                    
                    Button(action: continueIfValid) {
                        HStack(spacing: 12) {
                            Text("let's go")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 24))
                        }
                        .foregroundColor(Color(hex: "667eea"))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 18)
                        .background(
                            Capsule()
                                .fill(.white)
                                .shadow(color: .black.opacity(0.2), radius: 15, y: 8)
                        )
                    }
                    .opacity(inputName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                    .disabled(inputName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .scaleEffect(inputName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3), value: inputName)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
    
    private func continueIfValid() {
        let trimmedName = inputName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        userName = trimmedName
        UserDefaults.standard.set(trimmedName, forKey: UserDefaultsKeys.userName)
        onContinue()
    }
}

// Custom placeholder extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .center,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Hex color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    NamePromptView(userName: .constant("")) {
        print("Continue tapped")
    }
}
