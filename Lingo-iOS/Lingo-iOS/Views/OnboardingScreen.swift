//
//  OnboardingScreen.swift
//  Lingo
//
//  Initial onboarding flow for new users
//

import SwiftUI

struct OnboardingScreen: View {
    @Binding var userData: UserData
    @Binding var currentScreen: AppScreen

    @State private var name: String = ""
    @State private var selectedLanguage: Language = Language.all[0]
    @State private var selectedProficiency: ProficiencyLevel = .beginner

    var body: some View {
        ZStack {
            Color(hex: "F7F7F7")
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Logo and Title
                VStack(spacing: 16) {
                    Text("👋")
                        .font(.system(size: 80))

                    Text("Welcome to Lingo")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A1A"))

                    Text("Your AI-powered language coach")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "666666"))
                }

                Spacer()

                // Input Form
                VStack(spacing: 20) {
                    // Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's your name?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "1A1A1A"))

                        TextField("Enter your name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }

                    // Language Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Which language are you learning?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "1A1A1A"))

                        Menu {
                            ForEach(Language.all) { language in
                                Button(action: {
                                    selectedLanguage = language
                                }) {
                                    Text("\(language.flag) \(language.name)")
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(selectedLanguage.flag) \(selectedLanguage.name)")
                                    .foregroundColor(Color(hex: "1A1A1A"))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Color(hex: "007AFF"))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }

                    // Proficiency Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's your proficiency level?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "1A1A1A"))

                        HStack(spacing: 12) {
                            ForEach(ProficiencyLevel.allCases, id: \.self) { level in
                                Button(action: {
                                    selectedProficiency = level
                                }) {
                                    Text(level.rawValue)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedProficiency == level ? .white : Color(hex: "007AFF"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedProficiency == level ? Color(hex: "007AFF") : Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(hex: "007AFF"), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Start Button
                Button(action: {
                    startJourney()
                }) {
                    Text("Start My Journey")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(name.isEmpty ? Color.gray : Color(hex: "007AFF"))
                        .cornerRadius(12)
                }
                .disabled(name.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func startJourney() {
        userData.name = name
        userData.targetLanguage = selectedLanguage
        userData.proficiencyLevel = selectedProficiency

        PersistenceService.shared.saveUserData(userData)

        withAnimation {
            currentScreen = .prompt
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
