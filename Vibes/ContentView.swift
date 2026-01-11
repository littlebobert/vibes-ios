import SwiftUI

struct ContentView: View {
    @State private var userName: String = UserDefaults.standard.string(forKey: UserDefaultsKeys.userName) ?? ""
    @State private var currentScreen: AppScreen = .namePrompt
    @State private var capturedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case .namePrompt:
                NamePromptView(userName: $userName) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentScreen = .camera
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
            case .camera:
                CameraView(
                    capturedImage: $capturedImage,
                    userName: userName,
                    onPhotoTaken: { image in
                        uploadPhoto(image)
                    },
                    onChangeName: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = .namePrompt
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                
            case .uploading:
                UploadingView()
                    .transition(.opacity)
                
            case .result(let result):
                ResultView(result: result, capturedImage: capturedImage) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        capturedImage = nil
                        currentScreen = .camera
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                
            case .error(let message):
                ErrorView(message: message) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        capturedImage = nil
                        currentScreen = .camera
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentScreenIdentifier)
        .onAppear {
            // Check if we already have a name saved
            if !userName.isEmpty {
                currentScreen = .camera
            }
        }
    }
    
    // Helper to track screen changes for animation
    private var currentScreenIdentifier: String {
        switch currentScreen {
        case .namePrompt: return "namePrompt"
        case .camera: return "camera"
        case .uploading: return "uploading"
        case .result: return "result"
        case .error: return "error"
        }
    }
    
    private func uploadPhoto(_ image: UIImage) {
        withAnimation {
            currentScreen = .uploading
        }
        
        Task {
            do {
                let result = try await APIService.shared.uploadPhoto(image: image, name: userName)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentScreen = .result(result)
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentScreen = .error(error.localizedDescription)
                    }
                }
            }
        }
    }
}

// MARK: - Uploading View

struct UploadingView: View {
    @State private var isAnimating = false
    @State private var dotCount = 0
    @State private var currentMessage = 0
    
    let messages = [
        "analyzing your vibes",
        "consulting the algorithm",
        "checking the vibe database",
        "calculating coolness factor",
        "measuring aura intensity"
    ]
    
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
            
            VStack(spacing: 40) {
                // Animated emoji
                ZStack {
                    // Rotating ring
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color(hex: "667eea"),
                                    Color(hex: "f093fb"),
                                    Color(hex: "667eea")
                                ],
                                center: .center
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
                    
                    // Center emoji
                    Text("🔮")
                        .font(.system(size: 60))
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                }
                
                VStack(spacing: 16) {
                    Text(messages[currentMessage])
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.3), value: currentMessage)
                    
                    // Animated dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(Color(hex: "667eea"))
                                .frame(width: 10, height: 10)
                                .opacity(dotCount > i ? 1.0 : 0.3)
                        }
                    }
                }
                
                Text("this might take a moment ✨")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .onAppear {
            isAnimating = true
            startDotAnimation()
            startMessageRotation()
        }
    }
    
    private func startDotAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            withAnimation {
                dotCount = (dotCount + 1) % 4
            }
        }
    }
    
    private func startMessageRotation() {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            withAnimation {
                currentMessage = (currentMessage + 1) % messages.count
            }
        }
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    var onRetry: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0f0c29"),
                    Color(hex: "3d1a1a"),
                    Color(hex: "24243e")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("😵")
                    .font(.system(size: 80))
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(spacing: 12) {
                    Text("oops!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Button(action: onRetry) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .semibold))
                        Text("try again")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color(hex: "ff6b6b"))
                            .shadow(color: Color(hex: "ff6b6b").opacity(0.4), radius: 15, y: 8)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ContentView()
}
