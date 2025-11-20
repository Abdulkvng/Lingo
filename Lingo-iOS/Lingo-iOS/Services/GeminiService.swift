//
//  GeminiService.swift
//  Lingo
//
//  Google Gemini API integration for speech evaluation
//

import Foundation

enum GeminiError: Error {
    case invalidURL
    case noData
    case decodingError
    case apiError(String)
}

class GeminiService {
    static let shared = GeminiService()

    private let apiKey: String
    private let modelName = "gemini-2.0-flash-exp"

    private init() {
        // Load API key from environment or configuration
        // In production, use a secure configuration method
        self.apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
    }

    // MARK: - Generate Challenge Words

    func getChallengeWords(prompt: String, targetLanguage: String, proficiency: ProficiencyLevel) async throws -> [String] {
        let systemPrompt = """
        You are a language learning assistant. Generate 4 challenging vocabulary words in \(targetLanguage) that are:
        1. Relevant to this prompt: "\(prompt)"
        2. Appropriate for \(proficiency.rawValue) level
        3. Words the user might struggle with or should practice

        Return ONLY a JSON array of 4 words, nothing else. Example: ["word1", "word2", "word3", "word4"]
        """

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": systemPrompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 100
            ]
        ]

        let response = try await makeAPIRequest(requestBody: requestBody)

        // Parse the response to extract the challenge words
        if let text = extractTextFromResponse(response),
           let data = text.data(using: .utf8),
           let words = try? JSONDecoder().decode([String].self, from: data) {
            return words
        }

        // Fallback if parsing fails
        return ["practice", "improve", "fluency", "pronunciation"]
    }

    // MARK: - Evaluate Speech

    func evaluateSpeech(
        audioData: Data,
        targetLanguage: String,
        proficiency: ProficiencyLevel,
        prompt: String,
        challengeWords: [String],
        userName: String
    ) async throws -> (AIFeedback, String) {
        let base64Audio = audioData.base64EncodedString()

        let systemPrompt = """
        You are an expert language learning coach evaluating a speaking practice session.

        Student: \(userName)
        Target Language: \(targetLanguage)
        Proficiency Level: \(proficiency.rawValue)
        Prompt: "\(prompt)"
        Challenge Words to Use: \(challengeWords.joined(separator: ", "))

        Evaluate the audio response across these 5 metrics (score 1-100 each):
        1. GRAMMAR: Syntax, verb conjugation, sentence logic
        2. PRONUNCIATION: Accent, clarity of sounds
        3. FLUENCY: Speech flow, natural pacing, hesitations
        4. VOCABULARY: Word choice sophistication, variety
        5. CLARITY: Answerability, alignment with prompt

        Also check which challenge words were used and provide feedback.

        Return ONLY valid JSON in this EXACT format:
        {
          "transcription": "word-for-word transcription of the audio",
          "grammar": {"score": 85, "feedback": "detailed feedback"},
          "pronunciation": {"score": 80, "feedback": "detailed feedback"},
          "fluency": {"score": 90, "feedback": "detailed feedback"},
          "vocabulary": {"score": 75, "feedback": "detailed feedback"},
          "clarity": {"score": 88, "feedback": "detailed feedback"},
          "overallScore": 84,
          "challengeWordsUsed": [
            {"word": "word1", "used": true, "feedback": "Great usage!"},
            {"word": "word2", "used": false, "feedback": "Try to incorporate this next time"}
          ]
        }
        """

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": systemPrompt],
                        [
                            "inlineData": [
                                "mimeType": "audio/mp4",
                                "data": base64Audio
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.3,
                "maxOutputTokens": 2000,
                "responseMimeType": "application/json"
            ]
        ]

        let response = try await makeAPIRequest(requestBody: requestBody)

        // Parse the response
        guard let text = extractTextFromResponse(response),
              let data = text.data(using: .utf8) else {
            throw GeminiError.decodingError
        }

        // Decode the feedback
        let decoder = JSONDecoder()
        let feedbackResponse = try decoder.decode(FeedbackResponse.self, from: data)

        let feedback = AIFeedback(
            grammar: feedbackResponse.grammar,
            pronunciation: feedbackResponse.pronunciation,
            fluency: feedbackResponse.fluency,
            vocabulary: feedbackResponse.vocabulary,
            clarity: feedbackResponse.clarity,
            overallScore: feedbackResponse.overallScore,
            challengeWordsUsed: feedbackResponse.challengeWordsUsed
        )

        return (feedback, feedbackResponse.transcription)
    }

    // MARK: - Private Helper Methods

    private func makeAPIRequest(requestBody: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(modelName):generateContent?key=\(apiKey)") else {
            throw GeminiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let errorText = String(data: data, encoding: .utf8) {
                throw GeminiError.apiError(errorText)
            }
            throw GeminiError.apiError("Unknown API error")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GeminiError.decodingError
        }

        return json
    }

    private func extractTextFromResponse(_ response: [String: Any]) -> String? {
        guard let candidates = response["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            return nil
        }
        return text
    }
}

// MARK: - Response Models

private struct FeedbackResponse: Codable {
    let transcription: String
    let grammar: MetricScore
    let pronunciation: MetricScore
    let fluency: MetricScore
    let vocabulary: MetricScore
    let clarity: MetricScore
    let overallScore: Int
    let challengeWordsUsed: [ChallengeWordUsage]
}
