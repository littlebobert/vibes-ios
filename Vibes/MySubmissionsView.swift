import SwiftUI

struct MySubmissionsView: View {
    let userName: String
    var onDismiss: () -> Void
    
    @State private var submissions: [Submission] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var submissionToDelete: Submission?
    @State private var isDeleting = false
    
    var mySubmissions: [Submission] {
        submissions.filter { $0.name.lowercased() == userName.lowercased() }
    }
    
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
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onDismiss) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("back")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Title
                VStack(spacing: 8) {
                    Text("📋")
                        .font(.system(size: 50))
                    
                    Text("my submissions")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(mySubmissions.count) of 3 submissions used")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.bottom, 20)
                
                // Content
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    Text("loading...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 12)
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("😕")
                            .font(.system(size: 50))
                        Text(error)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Button(action: loadSubmissions) {
                            Text("try again")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "667eea"))
                                )
                        }
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else if mySubmissions.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("🤷")
                            .font(.system(size: 60))
                        Text("no submissions yet")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        Text("take a photo to get your vibe checked!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(mySubmissions) { submission in
                                SubmissionCard(
                                    submission: submission,
                                    isDeleting: isDeleting && submissionToDelete?.id == submission.id,
                                    onDelete: {
                                        submissionToDelete = submission
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete Submission?",
            isPresented: .init(
                get: { submissionToDelete != nil },
                set: { if !$0 { submissionToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let submission = submissionToDelete {
                    deleteSubmission(submission)
                }
            }
            Button("Cancel", role: .cancel) {
                submissionToDelete = nil
            }
        } message: {
            Text("This will permanently remove this submission from the leaderboard.")
        }
        .onAppear {
            loadSubmissions()
        }
    }
    
    private func loadSubmissions() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedSubmissions = try await APIService.shared.fetchSubmissions()
                await MainActor.run {
                    submissions = fetchedSubmissions
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func deleteSubmission(_ submission: Submission) {
        isDeleting = true
        
        Task {
            do {
                let response = try await APIService.shared.deleteSubmission(id: submission.id)
                await MainActor.run {
                    isDeleting = false
                    submissionToDelete = nil
                    if response.success {
                        withAnimation {
                            submissions.removeAll { $0.id == submission.id }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isDeleting = false
                    submissionToDelete = nil
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct SubmissionCard: View {
    let submission: Submission
    let isDeleting: Bool
    var onDelete: () -> Void
    
    var scoreColor: Color {
        switch submission.vibeScore {
        case 9...10:
            return Color(hex: "00d4aa")
        case 7...8:
            return Color(hex: "667eea")
        case 5...6:
            return Color(hex: "f9a825")
        case 3...4:
            return Color(hex: "ff6b6b")
        default:
            return Color(hex: "9e9e9e")
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Photo thumbnail
            AsyncImage(url: APIService.shared.getPhotoURL(for: submission)) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 70, height: 70)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.5)))
                                .scaleEffect(0.7)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .failure:
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.3))
                        )
                @unknown default:
                    EmptyView()
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    // Score badge
                    Text("\(submission.vibeScore)")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(scoreColor)
                    
                    Text("/10")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Spacer()
                }
                
                Text(submission.explanation)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                Text(formatDate(submission.createdAt))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // Delete button
            Button(action: onDelete) {
                if isDeleting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.5)))
                        .scaleEffect(0.7)
                        .frame(width: 36, height: 36)
                } else {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
            .disabled(isDeleting)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(scoreColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

#Preview {
    MySubmissionsView(userName: "Justin", onDismiss: {})
}
