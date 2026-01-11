import SwiftUI
import AVFoundation

struct CameraView: View {
    @Binding var capturedImage: UIImage?
    var userName: String
    var onPhotoTaken: (UIImage) -> Void
    var onChangeName: () -> Void
    
    @State private var showingImagePicker = false
    @State private var showingPhotoLibrary = false
    @State private var isAnimating = false
    @State private var pulseAnimation = false
    
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
            
            // Decorative elements
            GeometryReader { geo in
                // Top glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "667eea").opacity(0.4), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .position(x: geo.size.width * 0.8, y: -50)
                    .blur(radius: 60)
                
                // Bottom glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "f093fb").opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .position(x: geo.size.width * 0.2, y: geo.size.height + 50)
                    .blur(radius: 60)
            }
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Button(action: onChangeName) {
                            HStack(spacing: 6) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 18))
                                Text(userName)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.1))
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Text("📸")
                        .font(.system(size: 60))
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("strike a pose!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("take a photo to check your vibes")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Camera button area
                VStack(spacing: 30) {
                    // Main camera button
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        ZStack {
                            // Outer pulse ring
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "f093fb")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 4
                                )
                                .frame(width: 140, height: 140)
                                .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                                .opacity(pulseAnimation ? 0 : 0.8)
                                .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
                            
                            // Middle ring
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "f093fb")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 6
                                )
                                .frame(width: 130, height: 130)
                            
                            // Inner button
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 110, height: 110)
                                .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 20, y: 10)
                            
                            // Camera icon
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // Photo library option
                    Button(action: {
                        showingPhotoLibrary = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 18))
                            Text("choose from library")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                }
                
                Spacer()
                
                // Fun tip at bottom
                Text("💡 pro tip: good lighting = better vibes")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            isAnimating = true
            pulseAnimation = true
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $capturedImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            PhotoLibraryPicker(image: $capturedImage)
                .ignoresSafeArea()
        }
        .onChange(of: capturedImage) { oldValue, newValue in
            if let image = newValue {
                onPhotoTaken(image)
            }
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

#Preview {
    CameraView(capturedImage: .constant(nil), userName: "Justin", onPhotoTaken: { _ in }, onChangeName: {})
}
