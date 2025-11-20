//
//  DashboardScreen.swift
//  Lingo
//
//  Progress dashboard with charts and practice history
//

import SwiftUI
import Charts

struct DashboardScreen: View {
    @Binding var userData: UserData
    @Binding var currentScreen: AppScreen

    @State private var recordings: [Recording] = []

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

                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        Text("Your Progress")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "1A1A1A"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)

                        if recordings.isEmpty {
                            // Empty State
                            VStack(spacing: 16) {
                                Text("📊")
                                    .font(.system(size: 64))

                                Text("No practice sessions yet")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                Text("Start practicing to see your progress here!")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "666666"))
                                    .multilineTextAlignment(.center)

                                Button(action: {
                                    withAnimation {
                                        currentScreen = .prompt
                                    }
                                }) {
                                    Text("Start Practice")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 32)
                                        .padding(.vertical, 12)
                                        .background(Color(hex: "007AFF"))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(40)
                        } else {
                            // Progress Chart
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Score Trends")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                if #available(iOS 16.0, *) {
                                    Chart {
                                        ForEach(Array(recordings.enumerated()), id: \.offset) { index, recording in
                                            LineMark(
                                                x: .value("Session", index + 1),
                                                y: .value("Score", recording.feedback.overallScore)
                                            )
                                            .foregroundStyle(Color(hex: "007AFF"))
                                            .symbol(Circle())

                                            AreaMark(
                                                x: .value("Session", index + 1),
                                                y: .value("Score", recording.feedback.overallScore)
                                            )
                                            .foregroundStyle(Color(hex: "007AFF").opacity(0.1))
                                        }
                                    }
                                    .frame(height: 200)
                                    .chartYScale(domain: 0...100)
                                    .chartXAxis {
                                        AxisMarks(values: .automatic) { _ in
                                            AxisGridLine()
                                            AxisTick()
                                            AxisValueLabel()
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks(position: .leading)
                                    }
                                } else {
                                    // Fallback for iOS 15 and earlier
                                    SimpleLineChart(scores: recordings.map { $0.feedback.overallScore })
                                        .frame(height: 200)
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            .padding(.horizontal, 24)

                            // Practice History
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Practice History")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "1A1A1A"))

                                VStack(spacing: 12) {
                                    ForEach(recordings.reversed()) { recording in
                                        HistoryCard(recording: recording)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
        }
        .onAppear {
            loadRecordings()
        }
    }

    private func loadRecordings() {
        recordings = PersistenceService.shared.loadRecordings()
    }
}

// MARK: - History Card
struct HistoryCard: View {
    let recording: Recording

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(recording.date)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "1A1A1A"))

                Spacer()

                Text("\(recording.feedback.overallScore)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "007AFF"))
            }

            Text(recording.prompt)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "666666"))
                .lineLimit(2)

            HStack(spacing: 16) {
                MetricBadge(
                    label: "Grammar",
                    score: recording.feedback.grammar.score,
                    color: Color(hex: "007AFF")
                )
                MetricBadge(
                    label: "Fluency",
                    score: recording.feedback.fluency.score,
                    color: Color(hex: "FF9500")
                )
                MetricBadge(
                    label: "Clarity",
                    score: recording.feedback.clarity.score,
                    color: Color(hex: "FF2D55")
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Metric Badge
struct MetricBadge: View {
    let label: String
    let score: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(score)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Color(hex: "666666"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Simple Line Chart (Fallback for iOS < 16)
struct SimpleLineChart: View {
    let scores: [Int]

    var body: some View {
        GeometryReader { geometry in
            let maxScore = 100
            let points = scores.enumerated().map { index, score in
                CGPoint(
                    x: geometry.size.width * CGFloat(index) / CGFloat(max(scores.count - 1, 1)),
                    y: geometry.size.height * CGFloat(maxScore - score) / CGFloat(maxScore)
                )
            }

            ZStack {
                // Grid lines
                ForEach(0..<5) { i in
                    Path { path in
                        let y = geometry.size.height * CGFloat(i) / 4
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                }

                // Line path
                Path { path in
                    guard let firstPoint = points.first else { return }
                    path.move(to: firstPoint)
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(Color(hex: "007AFF"), lineWidth: 2)

                // Points
                ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                    Circle()
                        .fill(Color(hex: "007AFF"))
                        .frame(width: 8, height: 8)
                        .position(point)
                }
            }
        }
    }
}
