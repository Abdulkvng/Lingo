//
//  DataModels.swift
//  Lingo
//
//  AI Language Learning Coach - Data Models
//

import Foundation

// MARK: - Proficiency Level
enum ProficiencyLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case expert = "Expert"
}

// MARK: - Language
struct Language: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let flag: String

    static let all: [Language] = [
        Language(id: "en", name: "English", flag: "🇺🇸"),
        Language(id: "es", name: "Spanish", flag: "🇪🇸"),
        Language(id: "fr", name: "French", flag: "🇫🇷"),
        Language(id: "de", name: "German", flag: "🇩🇪"),
        Language(id: "it", name: "Italian", flag: "🇮🇹"),
        Language(id: "ja", name: "Japanese", flag: "🇯🇵"),
        Language(id: "zh", name: "Mandarin Chinese", flag: "🇨🇳"),
        Language(id: "pt", name: "Portuguese", flag: "🇧🇷"),
        Language(id: "ru", name: "Russian", flag: "🇷🇺"),
        Language(id: "hi", name: "Hindi", flag: "🇮🇳"),
        Language(id: "ar", name: "Arabic", flag: "🇸🇦"),
        Language(id: "yo", name: "Yoruba", flag: "🇳🇬")
    ]
}

// MARK: - Metric Score
struct MetricScore: Codable {
    let score: Int
    let feedback: String
}

// MARK: - Challenge Word Usage
struct ChallengeWordUsage: Codable, Identifiable {
    var id: String { word }
    let word: String
    let used: Bool
    let feedback: String
}

// MARK: - AI Feedback
struct AIFeedback: Codable {
    let grammar: MetricScore
    let pronunciation: MetricScore
    let fluency: MetricScore
    let vocabulary: MetricScore
    let clarity: MetricScore
    let overallScore: Int
    let challengeWordsUsed: [ChallengeWordUsage]
}

// MARK: - Recording
struct Recording: Identifiable, Codable {
    let id: String
    let prompt: String
    let transcription: String
    let feedback: AIFeedback
    let date: String
    let targetLanguage: String
    let challengeWords: [String]
    let proficiencyLevel: ProficiencyLevel

    var xpEarned: Int {
        let baseXP = feedback.overallScore
        let bonusXP = feedback.challengeWordsUsed.filter { $0.used }.count * 5
        return baseXP + bonusXP
    }
}

// MARK: - User Data
struct UserData: Codable {
    var name: String
    var targetLanguage: Language
    var proficiencyLevel: ProficiencyLevel
    var streak: Int
    var totalSessions: Int
    var totalXP: Int
    var lastPracticeDate: Date?

    init(name: String = "", targetLanguage: Language = Language.all[0], proficiencyLevel: ProficiencyLevel = .beginner) {
        self.name = name
        self.targetLanguage = targetLanguage
        self.proficiencyLevel = proficiencyLevel
        self.streak = 0
        self.totalSessions = 0
        self.totalXP = 0
        self.lastPracticeDate = nil
    }
}

// MARK: - App Screen
enum AppScreen {
    case onboarding
    case prompt
    case recording
    case loading
    case feedback
    case completion
    case dashboard
    case profile
}
