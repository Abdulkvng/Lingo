//
//  CompletionScreen.swift
//  Lingo
//
//  Completion screen with encouragement after feedback
//

import SwiftUI

struct CompletionScreen: View {
    @Binding var userData: UserData
    @Binding var currentScreen: AppScreen

    var body: some View {
        ZStack {
            Color(hex: "F7F7F7")
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Celebration Icon
                Text("🎉")
                    .font(.system(size: 100))

                // Congratulations Message
                VStack(spacing: 16) {
                    Text("Excellent Work!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "1A1A1A"))

                    Text("You've completed today's practice. Keep up the great work!")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "666666"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Stats Summary
                VStack(spacing: 16) {
                    HStack(spacing: 40) {
                        VStack(spacing: 8) {
                            Text("🔥")
                                .font(.system(size: 32))
                            Text("\(userData.streak)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                            Text("Day Streak")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "666666"))
                        }

                        VStack(spacing: 8) {
                            Text("⭐")
                                .font(.system(size: 32))
                            Text("\(userData.totalXP)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "1A1A1A"))
                            Text("Total XP")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "666666"))
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            currentScreen = .prompt
                        }
                    }) {
                        Text("Practice Again")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "007AFF"))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        withAnimation {
                            currentScreen = .dashboard
                        }
                    }) {
                        Text("View Progress")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "007AFF"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "007AFF"), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}
