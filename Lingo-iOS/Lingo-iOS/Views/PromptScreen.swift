//
//  PromptScreen.swift
//  Lingo
//
//  Main screen showing daily prompt and challenge words
//

import SwiftUI

struct PromptScreen: View {
    @Binding var userData: UserData
    @Binding var currentScreen: AppScreen
    @Binding var currentPrompt: String
    @Binding var challengeWords: [String]

    @State private var isLoadingWords = true

    var body: some View {
        ZStack {
            Color(hex: "F7F7F7")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HeaderView(
                    userData: userData,
                    onProfileTap: {
                        withAnimation {
                            currentScreen = .profile
                        }
                    },
                    onBackTap: nil
                )

                ScrollView {
                    VStack(spacing: 24) {
                        // Greeting
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hello, \(userData.name)!")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))

                            HStack(spacing: 16) {
                                HStack(spacing: 4) {
                                    Text("🔥")
                                    Text("\(userData.streak) day streak")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "666666"))
                                }

                                HStack(spacing: 4) {
                                    Text("⭐")
                                    Text("\(userData.totalXP) XP")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "666666"))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        // Daily Prompt Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Today's Prompt")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                Spacer()
                                Text(userData.targetLanguage.flag)
                                    .font(.system(size: 24))
                            }

                            Text(currentPrompt)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .lineSpacing(6)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 24)

                        // Challenge Words Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Challenge Words")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                Spacer()
                                Text("+5 XP each")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "007AFF"))
                            }

                            if isLoadingWords {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(challengeWords, id: \.self) { word in
                                        HStack {
                                            Text("•")
                                                .foregroundColor(Color(hex: "007AFF"))
                                            Text(word)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color(hex: "1A1A1A"))
                                            Spacer()
                                        }
                                    }
                                }
                            }

                            Text("Try to use these words in your response for bonus XP!")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "666666"))
                                .italic()
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 24)

                        // Start Recording Button
                        Button(action: {
                            withAnimation {
                                currentScreen = .recording
                            }
                        }) {
                            HStack {
                                Image(systemName: "mic.fill")
                                Text("Start Recording")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "007AFF"))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)

                        // View Progress Button
                        Button(action: {
                            withAnimation {
                                currentScreen = .dashboard
                            }
                        }) {
                            Text("View Progress")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "007AFF"))
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .onAppear {
            loadChallengeWords()
        }
    }

    private func loadChallengeWords() {
        Task {
            do {
                let words = try await GeminiService.shared.getChallengeWords(
                    prompt: currentPrompt,
                    targetLanguage: userData.targetLanguage.name,
                    proficiency: userData.proficiencyLevel
                )
                await MainActor.run {
                    challengeWords = words
                    isLoadingWords = false
                }
            } catch {
                await MainActor.run {
                    // Fallback words if API fails
                    challengeWords = ["practice", "improve", "fluency", "pronunciation"]
                    isLoadingWords = false
                }
            }
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    let userData: UserData
    let onProfileTap: () -> Void
    let onBackTap: (() -> Void)?

    var body: some View {
        HStack {
            if let backAction = onBackTap {
                Button(action: backAction) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "007AFF"))
                        .font(.system(size: 20, weight: .semibold))
                }
            }

            Spacer()

            Text("Lingo")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "007AFF"))

            Spacer()

            Button(action: onProfileTap) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "007AFF"))
                        .frame(width: 36, height: 36)

                    Text(String(userData.name.prefix(1)).uppercased())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
