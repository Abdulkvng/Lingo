//
//  LingoApp.swift
//  Lingo
//
//  Main app entry point and state management
//

import SwiftUI

@main
struct LingoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var currentScreen: AppScreen = .onboarding
    @State private var userData: UserData = UserData()
    @State private var currentPrompt: String = ""
    @State private var challengeWords: [String] = []
    @State private var currentRecordingData: (feedback: AIFeedback, transcription: String)? = nil

    // Sample prompts for practice
    private let prompts = [
        "Describe your perfect weekend and what makes it special to you.",
        "Tell me about a memorable trip or place you've visited.",
        "What are your goals for learning this language, and why is it important to you?",
        "Describe a typical day in your life, from morning to evening.",
        "What is your favorite hobby, and why do you enjoy it?",
        "Talk about a person who has influenced your life and how.",
        "Describe your dream job and what you would do in that role.",
        "What is your favorite book or movie, and what did you like about it?",
        "Describe a challenge you've faced and how you overcame it.",
        "What advice would you give to your younger self?"
    ]

    var body: some View {
        ZStack {
            switch currentScreen {
            case .onboarding:
                OnboardingScreen(
                    userData: $userData,
                    currentScreen: $currentScreen
                )
                .transition(.opacity)

            case .prompt:
                PromptScreen(
                    userData: $userData,
                    currentScreen: $currentScreen,
                    currentPrompt: $currentPrompt,
                    challengeWords: $challengeWords
                )
                .transition(.opacity)

            case .recording:
                RecordingScreen(
                    userData: $userData,
                    currentScreen: $currentScreen,
                    currentPrompt: $currentPrompt,
                    challengeWords: $challengeWords,
                    currentRecordingData: $currentRecordingData
                )
                .transition(.opacity)

            case .loading:
                LoadingScreen()
                    .transition(.opacity)

            case .feedback:
                if let data = currentRecordingData {
                    FeedbackScreen(
                        userData: $userData,
                        currentScreen: $currentScreen,
                        feedback: data.feedback,
                        transcription: data.transcription
                    )
                    .transition(.opacity)
                }

            case .completion:
                CompletionScreen(
                    userData: $userData,
                    currentScreen: $currentScreen
                )
                .transition(.opacity)

            case .dashboard:
                DashboardScreen(
                    userData: $userData,
                    currentScreen: $currentScreen
                )
                .transition(.opacity)

            case .profile:
                ProfileScreen(
                    userData: $userData,
                    currentScreen: $currentScreen
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            loadUserData()
            generateNewPrompt()
        }
    }

    private func loadUserData() {
        if let savedUserData = PersistenceService.shared.loadUserData() {
            userData = savedUserData
            currentScreen = .prompt
        } else {
            currentScreen = .onboarding
        }
    }

    private func generateNewPrompt() {
        currentPrompt = prompts.randomElement() ?? prompts[0]
    }
}
