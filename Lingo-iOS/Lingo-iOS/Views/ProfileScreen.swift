//
//  ProfileScreen.swift
//  Lingo
//
//  User profile screen with stats and settings
//

import SwiftUI

struct ProfileScreen: View {
    @Binding var userData: UserData
    @Binding var currentScreen: AppScreen

    var body: some View {
        ZStack {
            Color(hex: "F7F7F7")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HeaderView(
                    userData: userData,
                    onProfileTap: {},
                    onBackTap: {
                        withAnimation {
                            currentScreen = .prompt
                        }
                    }
                )

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "007AFF"))
                                    .frame(width: 80, height: 80)

                                Text(String(userData.name.prefix(1)).uppercased())
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text(userData.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))

                            HStack(spacing: 8) {
                                Text(userData.targetLanguage.flag)
                                    .font(.system(size: 20))
                                Text(userData.targetLanguage.name)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "666666"))
                                Text("•")
                                    .foregroundColor(Color(hex: "666666"))
                                Text(userData.proficiencyLevel.rawValue)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "666666"))
                            }
                        }
                        .padding(.top, 24)

                        // Stats Grid
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                StatCard(
                                    icon: "🔥",
                                    value: "\(userData.streak)",
                                    label: "Day Streak"
                                )

                                StatCard(
                                    icon: "⭐",
                                    value: "\(userData.totalXP)",
                                    label: "Total XP"
                                )
                            }

                            HStack(spacing: 16) {
                                StatCard(
                                    icon: "🎯",
                                    value: "\(userData.totalSessions)",
                                    label: "Sessions"
                                )

                                StatCard(
                                    icon: "📈",
                                    value: userData.totalSessions > 0 ? "\(userData.totalXP / userData.totalSessions)" : "0",
                                    label: "Avg Score"
                                )
                            }
                        }
                        .padding(.horizontal, 24)

                        // Settings Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Settings")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .padding(.horizontal, 20)

                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "globe",
                                    title: "Target Language",
                                    value: "\(userData.targetLanguage.flag) \(userData.targetLanguage.name)"
                                )

                                Divider()
                                    .padding(.leading, 56)

                                SettingsRow(
                                    icon: "chart.bar",
                                    title: "Proficiency Level",
                                    value: userData.proficiencyLevel.rawValue
                                )

                                Divider()
                                    .padding(.leading, 56)

                                Button(action: {
                                    resetProgress()
                                }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 20))
                                            .foregroundColor(Color(hex: "FF3B30"))
                                            .frame(width: 24)

                                        Text("Clear All Data")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "FF3B30"))

                                        Spacer()
                                    }
                                    .padding(16)
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)

                        // App Info
                        VStack(spacing: 8) {
                            Text("Lingo - AI Language Coach")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "666666"))

                            Text("Version 1.0.0")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "999999"))
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }

    private func resetProgress() {
        PersistenceService.shared.clearAllRecordings()
        userData.streak = 0
        userData.totalSessions = 0
        userData.totalXP = 0
        userData.lastPracticeDate = nil
        PersistenceService.shared.saveUserData(userData)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 32))

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "1A1A1A"))

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "666666"))
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "007AFF"))
                .frame(width: 24)

            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "1A1A1A"))

            Spacer()

            Text(value)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "666666"))
        }
        .padding(16)
    }
}
