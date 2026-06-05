import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showCompletionAlert = false
    @ObservedObject private var generator = GenerationManager.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: 0) {
                HomeView(selectedTab: $selectedTab)
            } label: {
                Label("Home", systemImage: "house.fill")
            }

            Tab(value: 1) {
                NavigationStack {
                    LifeMomentsView(selectedTab: $selectedTab)
                }
            } label: {
                Label("Moments", systemImage: "film.fill")
            }

            Tab(value: 2) {
                NavigationStack {
                    RestoreView(selectedTab: $selectedTab)
                }
            } label: {
                Label("Memoir", systemImage: "photo.fill")
            }

            Tab(value: 3) {
                NavigationStack {
                    ProfileView(selectedTab: $selectedTab)
                }
            } label: {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(AppColor.tabActive)
        .onReceive(NotificationCenter.default.publisher(for: .generationDidComplete)) { _ in
            // Only nudge the user with a dialog when they aren't already watching
            // the Generating screen — that screen auto-navigates to Result itself.
            guard !generator.isGeneratingScreenVisible else { return }
            showCompletionAlert = true
        }
        .alert("Your album is ready ✨", isPresented: $showCompletionAlert) {
            Button("View now") {
                generator.acknowledgeResult()
                selectedTab = 1
                NotificationCenter.default.post(name: .openPendingResult, object: nil)
            }
            Button("Later", role: .cancel) {
                generator.acknowledgeResult()
            }
        } message: {
            if let title = generator.lastThemeTitle {
                Text("\"\(title)\" finished generating in the background.")
            } else {
                Text("Your AI album finished generating in the background.")
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
