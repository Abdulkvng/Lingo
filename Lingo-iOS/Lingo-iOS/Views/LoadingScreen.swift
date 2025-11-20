//
//  LoadingScreen.swift
//  Lingo
//
//  Loading indicator screen
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            Color(hex: "F7F7F7")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(hex: "007AFF"))

                Text("Analyzing your speech...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "666666"))
            }
        }
    }
}
