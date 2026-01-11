import SwiftUI

struct ResultView: View {
    let result: VibeResult
    let capturedImage: UIImage?
    var onTryAgain: () -> Void
    
    @State private var showScore = false
    @State private var showExplanation = false
    @State private var showButton = false
    @State private var confettiTrigger = false
    @State private var scoreScale: CGFloat = 0.5
    
    var scoreColor: Color {
        switch result.vibeScore {
        case 9...10:
            return Color(hex: "00d4aa") // Teal/green - excellent
        case 7...8:
            return Color(hex: "667eea") // Purple - great
        case 5...6:
            return Color(hex: "f9a825") // Yellow/orange - decent
        case 3...4:
            return Color(hex: "ff6b6b") // Red/pink - meh
        default:
            return Color(hex: "9e9e9e") // Gray - rough
        }
    }
    
    var vibeEmoji: String {
        switch result.vibeScore {
        case 9...10:
            return "🔥"
        case 7...8:
            return "✨"
        case 5...6:
            return "😎"
        case 3...4:
            return "😬"
        default:
            return "💀"
        }
    }
    
    var vibeText: String {
        switch result.vibeScore {
        case 9...10:
            return "immaculate vibes"
        case 7...8:
            return "solid vibes"
        case 5...6:
            return "decent vibes"
        case 3...4:
            return "questionable vibes"
        default:
            return "vibes need work"
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient based on score
            LinearGradient(
                colors: [
                    Color(hex: "0f0c29"),
                    scoreColor.opacity(0.3),
                    Color(hex: "24243e")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated background particles
            GeometryReader { geo in
                ForEach(0..<20) { i in
                    Circle()
                        .fill(scoreColor.opacity(0.2))
                        .frame(width: CGFloat.random(in: 4...12))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height)
                        )
                        .blur(radius: 1)
                }
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 20)
                    
                    // Photo thumbnail + Score side by side
                    HStack(spacing: 20) {
                        // Photo thumbnail
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(scoreColor.opacity(0.6), lineWidth: 3)
                                )
                                .shadow(color: scoreColor.opacity(0.4), radius: 12, y: 6)
                                .scaleEffect(showScore ? 1.0 : 0.3)
                                .opacity(showScore ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: showScore)
                        }
                        
                        // Score display
                        VStack(spacing: 4) {
                            Text("vibe score")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .opacity(showScore ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.4).delay(0.3), value: showScore)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                ZStack {
                                    // Glow effect
                                    Text("\(result.vibeScore)")
                                        .font(.system(size: 72, weight: .black, design: .rounded))
                                        .foregroundColor(scoreColor)
                                        .blur(radius: 20)
                                        .opacity(0.5)
                                    
                                    // Main score
                                    Text("\(result.vibeScore)")
                                        .font(.system(size: 72, weight: .black, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [scoreColor, scoreColor.opacity(0.7)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                }
                                .scaleEffect(scoreScale)
                                .animation(.spring(response: 0.8, dampingFraction: 0.5).delay(0.4), value: scoreScale)
                                
                                Text("/10")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.4))
                                    .offset(y: -8)
                                    .opacity(showScore ? 1.0 : 0.0)
                                    .animation(.easeOut(duration: 0.4).delay(0.6), value: showScore)
                            }
                            
                            HStack(spacing: 6) {
                                Text(vibeEmoji)
                                    .font(.system(size: 18))
                                Text(vibeText)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(scoreColor)
                            }
                            .opacity(showScore ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.4).delay(0.7), value: showScore)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Explanation card
                    VStack(alignment: .leading, spacing: 12) {
                        Text(result.explanation)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Name badge inline
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 12))
                            Text(result.name)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(scoreColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    .opacity(showExplanation ? 1.0 : 0.0)
                    .offset(y: showExplanation ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showExplanation)
                    
                    Spacer().frame(height: 12)
                    
                    // Try again button
                    Button(action: onTryAgain) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                            Text("check another vibe")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 18)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [scoreColor, scoreColor.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: scoreColor.opacity(0.4), radius: 15, y: 8)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .opacity(showButton ? 1.0 : 0.0)
                    .offset(y: showButton ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: showButton)
                    
                    // Leaderboard hint
                    Text("🏆 check the leaderboard!")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                        .opacity(showButton ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.4).delay(1.2), value: showButton)
                    
                    Spacer().frame(height: 24)
                }
            }
            
            // Confetti overlay for high scores
            if result.vibeScore >= 8 && confettiTrigger {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            triggerAnimations()
        }
    }
    
    private func triggerAnimations() {
        withAnimation {
            showScore = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            scoreScale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showExplanation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            showButton = true
        }
        
        if result.vibeScore >= 8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                confettiTrigger = true
            }
        }
    }
}

// Simple confetti view
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                Text(particle.emoji)
                    .font(.system(size: particle.size))
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        let emojis = ["🎉", "✨", "🌟", "💫", "🎊", "⭐️", "🔥", "💯"]
        
        for i in 0..<30 {
            let particle = ConfettiParticle(
                id: i,
                emoji: emojis.randomElement()!,
                size: CGFloat.random(in: 20...40),
                position: CGPoint(
                    x: CGFloat.random(in: 50...350),
                    y: -50
                ),
                opacity: 1.0
            )
            particles.append(particle)
        }
        
        // Animate particles falling
        for i in 0..<particles.count {
            let delay = Double(i) * 0.05
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: 2)) {
                    if i < particles.count {
                        particles[i].position.y = 900
                        particles[i].position.x += CGFloat.random(in: -100...100)
                        particles[i].opacity = 0
                    }
                }
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: Int
    let emoji: String
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
}

#Preview {
    ResultView(
        result: VibeResult(
            id: "123",
            name: "Justin",
            vibeScore: 8,
            explanation: "Birthday cake and peace sign? This dev definitely celebrates every successful build like they just shipped the next iOS killer app. The glasses say 'senior engineer' but the pose says 'just discovered SwiftUI animations.'",
            photoUrl: "/uploads/test.jpg"
        ),
        capturedImage: nil,
        onTryAgain: {}
    )
}
