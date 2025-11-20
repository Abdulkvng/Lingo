//
//  PersistenceService.swift
//  Lingo
//
//  Local persistence for user data and recordings
//

import Foundation

class PersistenceService: ObservableObject {
    static let shared = PersistenceService()

    private let userDefaults = UserDefaults.standard
    private let userDataKey = "lingo_user_data"
    private let recordingsKey = "lingo_recordings"

    private init() {}

    // MARK: - User Data

    func saveUserData(_ userData: UserData) {
        if let encoded = try? JSONEncoder().encode(userData) {
            userDefaults.set(encoded, forKey: userDataKey)
        }
    }

    func loadUserData() -> UserData? {
        guard let data = userDefaults.data(forKey: userDataKey),
              let userData = try? JSONDecoder().decode(UserData.self, from: data) else {
            return nil
        }
        return userData
    }

    func clearUserData() {
        userDefaults.removeObject(forKey: userDataKey)
    }

    // MARK: - Recordings

    func saveRecording(_ recording: Recording) {
        var recordings = loadRecordings()
        recordings.append(recording)

        if let encoded = try? JSONEncoder().encode(recordings) {
            userDefaults.set(encoded, forKey: recordingsKey)
        }
    }

    func loadRecordings() -> [Recording] {
        guard let data = userDefaults.data(forKey: recordingsKey),
              let recordings = try? JSONDecoder().decode([Recording].self, from: data) else {
            return []
        }
        return recordings
    }

    func deleteRecording(_ id: String) {
        var recordings = loadRecordings()
        recordings.removeAll { $0.id == id }

        if let encoded = try? JSONEncoder().encode(recordings) {
            userDefaults.set(encoded, forKey: recordingsKey)
        }
    }

    func clearAllRecordings() {
        userDefaults.removeObject(forKey: recordingsKey)
    }

    // MARK: - Streak Management

    func updateStreak(lastDate: Date?) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastPracticeDate = lastDate else {
            return 1 // First practice
        }

        let lastDay = calendar.startOfDay(for: lastPracticeDate)
        let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        if daysDifference == 0 {
            // Same day, maintain streak
            return 0 // No change
        } else if daysDifference == 1 {
            // Next day, increment streak
            return 1
        } else {
            // Streak broken, reset
            return -1
        }
    }
}
