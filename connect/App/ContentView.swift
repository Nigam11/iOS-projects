//
//  ContentView.swift
//  App
//
//  Created by Nigam Chaudhary on 23/02/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1  // Default selected tab (WiFi)

    var body: some View {
        TabView(selection: $selectedTab) {
            
            Quiz()
                .tabItem {
                    VStack {
                        Image(systemName: "questionmark.circle.fill") // Quiz icon
                        Text("Quiz")
                    }
                }
                .tag(0)

            Wifi()
                .tabItem {
                    VStack {
                        Image(systemName: "wifi") // WiFi icon
                        Text("WiFi")
                    }
                }
                .tag(1)

            Attendance()
                .tabItem {
                    VStack {
                        Image(systemName: "person.3.fill") // Attendance icon
                        Text("Attendance")
                    }
                }
                .tag(2)

            QA_Page()
                .tabItem {
                    VStack {
                        Image(systemName: "person.wave.2.fill") // Q&A icon
                        Text("Q&A")
                    }
                }
                .tag(3)
        }
        .accentColor(.orange)  // Highlight selected tab with ORANGE color
    }
}

// Dummy Views for Each Tab (Replace with real pages)
struct quiz: View {
    var body: some View {
        VStack {
            Text("Quiz Page")
                .font(.largeTitle)
        }
    }
}

struct wifi: View {
    var body: some View {
        VStack {
            Text("WiFi Page")
                .font(.largeTitle)
        }
    }
}

struct attendance: View {
    var body: some View {
        VStack {
            Text("Attendance Page")
                .font(.largeTitle)
        }
    }
}

struct qA_Page: View {
    var body: some View {
        VStack {
            Text("Q&A Page")
                .font(.largeTitle)
        }
    }
}

#Preview {
    ContentView()
}
