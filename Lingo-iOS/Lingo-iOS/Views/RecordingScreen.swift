//
//  RecordingScreen.swift
//  Lingo
//
//  Audio recording screen with real-time volume visualization
//

import SwiftUI

struct RecordingScreen: View {
    @Binding var userData: UserData
    @Binding var currentScreen: AppScreen
    @Binding var currentPrompt: String
    @Binding var challengeWords: [String]
    @Binding var currentRecordingData: (feedback: AIFeedback, transcription: String)?

    @StateObject private var audioRecorder = AudioRecorder()
    @State private var recordingStartTime: Date?

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
                    onBackTap: {
                        withAnimation {
                            currentScreen = .prompt
                        }
                    }
                )

                Spacer()

                // Recording Visualization
                VStack(spacing: 40) {
                    // Prompt reminder
                    Text(currentPrompt)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: "1A1A1A"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // Volume Visualization
                    ZStack {
                        // Outer circle
                        Circle()
                            .stroke(Color(hex: "007AFF").opacity(0.2), lineWidth: 4)
                            .frame(width: 200, height: 200)

                        // Animated circle based on volume
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: audioRecorder.isRecording ? "FF3B30" : "007AFF"),
                                        Color(hex: audioRecorder.isRecording ? "FF3B30" : "007AFF").opacity(0.6)
                                    ]),
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 100
                                )
                            )
                            .frame(
                                width: audioRecorder.isRecording ? 150 + CGFloat(audioRecorder.volume * 50) : 150,
                                height: audioRecorder.isRecording ? 150 + CGFloat(audioRecorder.volume * 50) : 150
                            )
                            .animation(.easeInOut(duration: 0.1), value: audioRecorder.volume)

                        // Microphone icon
                        Image(systemName: audioRecorder.isRecording ? "waveform" : "mic.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                    }

                    // Recording status
                    VStack(spacing: 8) {
                        Text(audioRecorder.isRecording ? "Recording..." : "Tap to Record")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1A1A"))

                        if audioRecorder.isRecording, let startTime = recordingStartTime {
                            Text(timeString(from: startTime))
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "666666"))
                                .monospacedDigit()
                        } else {
                            Text("Speak clearly and naturally")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "666666"))
                        }
                    }

                    // Error message
                    if let error = audioRecorder.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "FF3B30"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 16) {
                    if audioRecorder.isRecording {
                        Button(action: {
                            stopAndProcess()
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Stop & Get Feedback")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "FF3B30"))
                            .cornerRadius(12)
                        }
                    } else {
                        Button(action: {
                            startRecording()
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
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func startRecording() {
        audioRecorder.startRecording()
        recordingStartTime = Date()
    }

    private func stopAndProcess() {
        Task {
            guard let audioData = await audioRecorder.stopRecording() else {
                return
            }

            await MainActor.run {
                currentScreen = .loading
            }

            do {
                let (feedback, transcription) = try await GeminiService.shared.evaluateSpeech(
                    audioData: audioData,
                    targetLanguage: userData.targetLanguage.name,
                    proficiency: userData.proficiencyLevel,
                    prompt: currentPrompt,
                    challengeWords: challengeWords,
                    userName: userData.name
                )

                // Save the recording
                let recording = Recording(
                    id: ISO8601DateFormatter().string(from: Date()),
                    prompt: currentPrompt,
                    transcription: transcription,
                    feedback: feedback,
                    date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short),
                    targetLanguage: userData.targetLanguage.name,
                    challengeWords: challengeWords,
                    proficiencyLevel: userData.proficiencyLevel
                )

                PersistenceService.shared.saveRecording(recording)

                // Update user data
                let streakUpdate = PersistenceService.shared.updateStreak(lastDate: userData.lastPracticeDate)
                if streakUpdate == 1 {
                    userData.streak += 1
                } else if streakUpdate == -1 {
                    userData.streak = 1
                }

                userData.lastPracticeDate = Date()
                userData.totalSessions += 1
                userData.totalXP += recording.xpEarned

                PersistenceService.shared.saveUserData(userData)

                await MainActor.run {
                    currentRecordingData = (feedback, transcription)
                    currentScreen = .feedback
                }
            } catch {
                await MainActor.run {
                    audioRecorder.errorMessage = "Failed to process recording: \(error.localizedDescription)"
                    currentScreen = .recording
                }
            }
        }
    }

    private func timeString(from startTime: Date) -> String {
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
