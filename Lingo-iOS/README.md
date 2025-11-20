# Lingo - iOS App

AI-powered language learning coach for iOS. Practice speaking and get instant feedback powered by Google's Gemini AI.

## Features

- **Daily Speaking Practice**: Record yourself responding to prompts
- **AI-Powered Feedback**: Instant evaluation across 5 dimensions:
  - Grammar
  - Pronunciation
  - Fluency
  - Vocabulary
  - Clarity
- **12 Languages Supported**: English, Spanish, French, German, Italian, Japanese, Chinese, Portuguese, Russian, Hindi, Arabic, Yoruba
- **Progress Tracking**: View your improvement over time with charts
- **Challenge Words**: Vocabulary challenges with bonus XP
- **Gamification**: Streaks, XP points, and session tracking
- **Offline Storage**: All your progress saved locally

## Requirements

- iOS 15.0 or later
- Xcode 14.0 or later
- Swift 5.0 or later
- Google Gemini API key

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Lingo/Lingo-iOS
```

### 2. Set Up Gemini API Key

You need a Google Gemini API key to use the AI features.

1. Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Set it as an environment variable in Xcode:
   - Open the project in Xcode
   - Go to Product > Scheme > Edit Scheme
   - Select "Run" on the left
   - Go to the "Arguments" tab
   - Under "Environment Variables", add:
     - Name: `GEMINI_API_KEY`
     - Value: `your-api-key-here`

Alternatively, you can hardcode it in `GeminiService.swift` (not recommended for production):

```swift
private let apiKey = "your-api-key-here"
```

### 3. Open in Xcode

```bash
open Lingo-iOS.xcodeproj
```

### 4. Build and Run

1. Select a simulator or connect your iOS device
2. Press `Cmd + R` or click the Play button
3. The app will build and launch

## Project Structure

```
Lingo-iOS/
├── Lingo-iOS/
│   ├── Models/
│   │   └── DataModels.swift        # Data structures and enums
│   ├── Services/
│   │   ├── PersistenceService.swift # Local storage (UserDefaults)
│   │   ├── GeminiService.swift      # Google Gemini API integration
│   │   └── AudioRecorder.swift      # Audio recording with AVFoundation
│   ├── Views/
│   │   ├── OnboardingScreen.swift   # Initial setup
│   │   ├── PromptScreen.swift       # Daily prompt display
│   │   ├── RecordingScreen.swift    # Audio recording interface
│   │   ├── FeedbackScreen.swift     # AI feedback display
│   │   ├── CompletionScreen.swift   # Post-practice celebration
│   │   ├── ProfileScreen.swift      # User stats and settings
│   │   ├── DashboardScreen.swift    # Progress charts
│   │   └── LoadingScreen.swift      # Loading indicator
│   ├── LingoApp.swift               # Main app entry point
│   └── Info.plist                   # App configuration
└── README.md
```

## Architecture

### SwiftUI + MVVM Pattern

- **Models**: Data structures (`Recording`, `AIFeedback`, `UserData`)
- **Views**: SwiftUI screens with `@State` and `@Binding`
- **Services**: Business logic and API integrations

### Data Flow

1. **Onboarding**: User enters name, selects language and proficiency
2. **Prompt Screen**: Displays daily prompt and challenge words
3. **Recording**: User records audio response
4. **Processing**: Audio sent to Gemini API for evaluation
5. **Feedback**: Detailed scores and feedback displayed
6. **Persistence**: Results saved to UserDefaults

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **AVFoundation**: Audio recording and playback
- **URLSession**: Network requests to Gemini API
- **UserDefaults**: Local data persistence
- **Charts** (iOS 16+): Progress visualization

## API Integration

### Gemini 2.0 Flash

The app uses Google's Gemini 2.0 Flash model for:

1. **Challenge Word Generation**: Creates relevant vocabulary for each prompt
2. **Speech Evaluation**: Analyzes audio and provides structured feedback

### API Endpoints

- Base URL: `https://generativelanguage.googleapis.com/v1beta/models/`
- Model: `gemini-2.0-flash-exp`
- Authentication: API key in URL parameter

## Customization

### Change Supported Languages

Edit the `Language.all` array in `DataModels.swift`:

```swift
static let all: [Language] = [
    Language(id: "en", name: "English", flag: "🇺🇸"),
    // Add more languages...
]
```

### Add More Prompts

Edit the `prompts` array in `LingoApp.swift`:

```swift
private let prompts = [
    "Your custom prompt here...",
    // Add more prompts...
]
```

### Customize Colors

The app uses these primary colors (defined in `OnboardingScreen.swift`):

- Primary Blue: `#007AFF`
- Recording Red: `#FF3B30`
- Background: `#F7F7F7`
- Text: `#1A1A1A`

## Permissions

The app requires microphone access to record audio. The permission prompt is configured in `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Lingo needs access to your microphone to record and evaluate your speaking practice.</string>
```

## Troubleshooting

### Microphone Not Working

1. Check Settings > Privacy > Microphone > Lingo is enabled
2. Restart the app after granting permission

### API Errors

1. Verify your Gemini API key is correct
2. Check your internet connection
3. Ensure the API key has sufficient quota

### Build Errors

1. Clean build folder: `Cmd + Shift + K`
2. Update Xcode to the latest version
3. Ensure iOS deployment target is set to 15.0+

## Testing

### Simulator

The app works fully in the iOS Simulator, including audio recording.

### Physical Device

For best audio quality and realistic testing, use a physical iOS device.

## Future Enhancements

- [ ] iCloud sync for cross-device progress
- [ ] Widget for daily streak tracking
- [ ] Siri Shortcuts integration
- [ ] Apple Watch companion app
- [ ] Social features (leaderboards, challenges)
- [ ] Offline mode with cached prompts
- [ ] Voice feedback (text-to-speech)
- [ ] Custom prompt creation

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Credits

- **AI Model**: Google Gemini 2.0 Flash
- **Framework**: SwiftUI (Apple)
- **Audio**: AVFoundation (Apple)

## Support

For issues or questions:
- Open an issue on GitHub
- Contact: [your-email@example.com]

---

Made with ❤️ for language learners worldwide
