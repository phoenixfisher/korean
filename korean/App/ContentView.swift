import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            StudyView()
                .tabItem {
                    Label("Study", systemImage: "chart.xyaxis.line")
                }

            ListsView()
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }

            ReferenceView()
                .tabItem {
                    Label("Reference", systemImage: "books.vertical")
                }
        }
    }
}

#Preview {
    ContentView()
}
