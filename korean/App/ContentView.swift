import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Search", systemImage: "magnifyingglass") {
                SearchView()
            }
            
            Tab("Study", systemImage: "chart.xyaxis.line") {
                StudyView()
            }
            
            Tab("Lists", systemImage: "list.bullet") {
                ListsView()
            }
            
            Tab("Reference", systemImage: "books.vertical") {
                ReferenceView()
            }
        }
    }
}

#Preview {
    ContentView()
}
