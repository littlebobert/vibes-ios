# Vibes 📸✨

An iOS app that lets you take a photo and get an AI-generated "vibe score" with a funny explanation. Built with SwiftUI.

## Features

- 📷 **Camera capture** or photo library selection
- 🤖 **AI-powered vibe analysis** via Claude
- 🎯 **Vibe scores 1-10** with witty roasts
- 🎉 **Confetti celebration** for high scores
- 💾 **Name persistence** across sessions
- 🏆 **Leaderboard integration** with the backend

## Screenshots

| Name Entry | Camera | Results |
|------------|--------|---------|
| Enter your name on first launch | Take a photo or choose from library | See your vibe score and explanation |

## Requirements

- Xcode 15+
- iOS 17+
- A running [vibes-backend](../vibes-backend) server

## Quick Start

### 1. Open the Project

```bash
cd ~/dev/vibes
open Vibes.xcodeproj
```

### 2. Configure Signing

1. Select the **Vibes** target
2. Go to **Signing & Capabilities**
3. Select your development team

### 3. Update the Server URL (if needed)

The app points to an ngrok URL by default. If yours is different, update it in `APIService.swift`:

```swift
private let baseURL = "https://your-ngrok-url.ngrok-free.dev"
```

### 4. Run

- **Device**: Build and run on a physical device to use the camera
- **Simulator**: Use the photo library picker (camera not available)

## Project Structure

```
Vibes/
├── VibesApp.swift        # App entry point
├── ContentView.swift     # Main navigation controller + loading/error views
├── NamePromptView.swift  # First-time name entry screen
├── CameraView.swift      # Camera/photo picker interface
├── ResultView.swift      # Score display with photo thumbnail
├── ImagePicker.swift     # UIKit camera & PHPicker wrappers
├── APIService.swift      # Network layer for backend API
├── Models.swift          # Data models (VibeResult, AppScreen, etc.)
├── Info.plist            # Camera & photo library permissions
└── Assets.xcassets/      # Colors and app icon
```

## App Flow

```
┌─────────────────┐
│  Name Prompt    │  ← First launch only (saved to UserDefaults)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Camera       │  ← Take photo or choose from library
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Uploading     │  ← Fun loading messages while AI analyzes
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Results      │  ← Photo thumbnail, score, explanation
└────────┬────────┘
         │
         ▼
      [Retry] ──────► Back to Camera
```

## Backend API

The app communicates with these endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/upload` | Upload photo + name, get vibe score |
| `GET` | `/api/health` | Health check |

### Upload Request

```
POST /api/upload
Content-Type: multipart/form-data

Fields:
- photo: Image file (JPEG)
- name: User's name
```

### Upload Response

```json
{
  "id": "uuid",
  "name": "Justin",
  "vibe_score": 8,
  "explanation": "Witty AI-generated roast...",
  "photo_url": "/uploads/filename.jpg"
}
```

## Customization Ideas

### Change the color scheme
Edit the hex colors in `NamePromptView.swift`, `CameraView.swift`, or `ResultView.swift`:

```swift
Color(hex: "667eea")  // Purple
Color(hex: "f093fb")  // Pink
Color(hex: "00d4aa")  // Teal
```

### Add haptic feedback
```swift
import UIKit

let generator = UIImpactFeedbackGenerator(style: .heavy)
generator.impactOccurred()
```

### Change loading messages
Edit the `messages` array in `ContentView.swift`:

```swift
let messages = [
    "analyzing your vibes",
    "consulting the algorithm",
    // Add your own!
]
```

## Dependencies

None! Built entirely with Apple frameworks:

- **SwiftUI** - UI and animations
- **UIKit** - Camera via `UIImagePickerController`
- **PhotosUI** - Photo library via `PHPickerViewController`
- **Foundation** - Networking and persistence

## Permissions

The app requests these permissions (configured in `Info.plist`):

- 📷 **Camera** - To take photos
- 🖼️ **Photo Library** - To select existing photos

## License

MIT - Have fun! 🎉
