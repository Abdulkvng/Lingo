//
//  FeedbackScreen.swift
//  Lingo
//
//  Detailed feedback screen with radar chart visualization
//

import SwiftUI

struct FeedbackScreen: View {
    @Binding var userData: UserData
    @Binding var currentScreen: AppScreen
    let feedback: AIFeedback
    let transcription: String

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
                        // Overall Score
                        VStack(spacing: 12) {
                            Text("\(feedback.overallScore)")
                                .font(.system(size: 64, weight: .bold))
                                .foregroundColor(Color(hex: "007AFF"))

                            Text("Overall Score")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: "1A1A1A"))

                            Text("Great job! Keep practicing to improve.")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "666666"))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)

                        // Radar Chart
                        RadarChartView(
                            scores: [
                                feedback.grammar.score,
                                feedback.pronunciation.score,
                                feedback.fluency.score,
                                feedback.vocabulary.score,
                                feedback.clarity.score
                            ],
                            labels: ["Grammar", "Pronunciation", "Fluency", "Vocabulary", "Clarity"]
                        )
                        .frame(height: 250)
                        .padding(.horizontal, 24)

                        // Detailed Metrics
                        VStack(spacing: 16) {
                            ScoreCardView(
                                title: "Grammar",
                                score: feedback.grammar.score,
                                feedback: feedback.grammar.feedback,
                                color: Color(hex: "007AFF")
                            )

                            ScoreCardView(
                                title: "Pronunciation",
                                score: feedback.pronunciation.score,
                                feedback: feedback.pronunciation.feedback,
                                color: Color(hex: "34C759")
                            )

                            ScoreCardView(
                                title: "Fluency",
                                score: feedback.fluency.score,
                                feedback: feedback.fluency.feedback,
                                color: Color(hex: "FF9500")
                            )

                            ScoreCardView(
                                title: "Vocabulary",
                                score: feedback.vocabulary.score,
                                feedback: feedback.vocabulary.feedback,
                                color: Color(hex: "8E44AD")
                            )

                            ScoreCardView(
                                title: "Clarity",
                                score: feedback.clarity.score,
                                feedback: feedback.clarity.feedback,
                                color: Color(hex: "FF2D55")
                            )
                        }
                        .padding(.horizontal, 24)

                        // Challenge Words Used
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Challenge Words")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "1A1A1A"))

                            VStack(spacing: 12) {
                                ForEach(feedback.challengeWordsUsed) { wordUsage in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: wordUsage.used ? "checkmark.circle.fill" : "xmark.circle")
                                            .foregroundColor(wordUsage.used ? Color(hex: "34C759") : Color(hex: "FF3B30"))
                                            .font(.system(size: 20))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(wordUsage.word)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Color(hex: "1A1A1A"))

                                            Text(wordUsage.feedback)
                                                .font(.system(size: 14))
                                                .foregroundColor(Color(hex: "666666"))
                                        }

                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 24)

                        // Transcription
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Response")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "1A1A1A"))

                            Text(transcription)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "1A1A1A"))
                                .lineSpacing(6)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 24)

                        // Continue Button
                        Button(action: {
                            withAnimation {
                                currentScreen = .completion
                            }
                        }) {
                            Text("Continue")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "007AFF"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }
}

// MARK: - Score Card View
struct ScoreCardView: View {
    let title: String
    let score: Int
    let feedback: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "1A1A1A"))

                Spacer()

                Text("\(score)/100")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "E5E5E5"))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(score) / 100, height: 8)
                }
            }
            .frame(height: 8)

            Text(feedback)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "666666"))
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Radar Chart View
struct RadarChartView: View {
    let scores: [Int]
    let labels: [String]

    private let colors = [
        Color(hex: "007AFF"),
        Color(hex: "34C759"),
        Color(hex: "FF9500"),
        Color(hex: "8E44AD"),
        Color(hex: "FF2D55")
    ]

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 40

            ZStack {
                // Background grid circles
                ForEach(1..<6) { level in
                    RadarPolygon(
                        points: 5,
                        center: center,
                        radius: radius * CGFloat(level) / 5
                    )
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                }

                // Axes
                ForEach(0..<5) { index in
                    let angle = CGFloat(index) * (2 * .pi / 5) - .pi / 2
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: CGPoint(
                            x: center.x + cos(angle) * radius,
                            y: center.y + sin(angle) * radius
                        ))
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }

                // Data polygon
                RadarDataPolygon(
                    scores: scores,
                    center: center,
                    radius: radius
                )
                .fill(Color(hex: "007AFF").opacity(0.3))

                RadarDataPolygon(
                    scores: scores,
                    center: center,
                    radius: radius
                )
                .stroke(Color(hex: "007AFF"), lineWidth: 2)

                // Data points
                ForEach(0..<scores.count, id: \.self) { index in
                    let angle = CGFloat(index) * (2 * .pi / 5) - .pi / 2
                    let distance = radius * CGFloat(scores[index]) / 100
                    Circle()
                        .fill(colors[index])
                        .frame(width: 8, height: 8)
                        .position(
                            x: center.x + cos(angle) * distance,
                            y: center.y + sin(angle) * distance
                        )
                }

                // Labels
                ForEach(0..<labels.count, id: \.self) { index in
                    let angle = CGFloat(index) * (2 * .pi / 5) - .pi / 2
                    let labelRadius = radius + 25
                    Text(labels[index])
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors[index])
                        .position(
                            x: center.x + cos(angle) * labelRadius,
                            y: center.y + sin(angle) * labelRadius
                        )
                }
            }
        }
    }
}

// MARK: - Radar Polygon Shape
struct RadarPolygon: Shape {
    let points: Int
    let center: CGPoint
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for i in 0..<points {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(points)) - .pi / 2
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Radar Data Polygon Shape
struct RadarDataPolygon: Shape {
    let scores: [Int]
    let center: CGPoint
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for i in 0..<scores.count {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(scores.count)) - .pi / 2
            let distance = radius * CGFloat(scores[i]) / 100
            let point = CGPoint(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
