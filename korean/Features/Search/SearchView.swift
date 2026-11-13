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
                    ContentUnavailableView(
                        "Search the Dictionary",
                        systemImage: "character.book.closed",
                        description: Text("Enter a Korean word to see its English definitions.")
                    )
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
                    List(results) { entry in
                        DictionaryResultRow(entry: entry)
                    }
                }
            }
            .navigationTitle("Korean Dictionary")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Korean word"
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

private struct DictionaryResultRow: View {
    let entry: DictionaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.lemma)
                .font(.headline)

            if let englishLemma = entry.englishLemma, !englishLemma.isEmpty {
                Text(englishLemma)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Text(entry.englishDefinition)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
