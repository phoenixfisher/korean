//
//  SearchView.swift
//  korean
//
//  Created by Phoenix Fisher on 11/14/26.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var results: [DictionaryEntry] = []
    @State private var errorMessage: String?
    @State private var isSearching = false

    private let dictionary = DictionaryStore()

    var body: some View {
        NavigationStack {
            Group {
                if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(spacing: 26) {
                        VStack(spacing: 0) {
                            Text("The")
                                .font(.caption2)
                                .frame(alignment: .leading)
                                .offset(x: -36, y: 6)
                            
                            Text("Korean")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.accent)
                            
                            Text("App")
                                .font(.caption2)
                                .frame(alignment: .trailing)
                                .offset(x: 36, y: -6)
                        }
                        
                        Text("Beta 1.0").italic()
                    }
                } else if isSearching {
                    ProgressView("Searching…")
                } else if let errorMessage {
                    ContentUnavailableView(
                        "Dictionary Unavailable",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if results.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    // Dictionary result list
                    List(results) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.lemma)
                                .font(.headline)

                            if let englishLemma = entry.englishLemma, !englishLemma.isEmpty {
                                Text(englishLemma)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            } else {
                                Text(entry.englishDefinition)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(
                text: $searchText,
                placement: .toolbarPrincipal,
                prompt: "Search any word in Korean or English"
            )
            .task(id: searchText) {
                await search()
            }
        }
    }

    private func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            results = []
            errorMessage = nil
            isSearching = false
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            try await Task.sleep(for: .milliseconds(250))
            let newResults = try await dictionary.search(for: query)
            try Task.checkCancellation()
            results = newResults
            isSearching = false
        } catch is CancellationError {
            return
        } catch {
            results = []
            errorMessage = error.localizedDescription
            isSearching = false
        }
    }
}
