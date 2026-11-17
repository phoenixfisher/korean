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
            ZStack {
                Group {
                    if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
    //                    VStack(spacing: 20) {
                            ZStack {
                                Text("Beta")
                                    .font(.system(size: 90, weight: .bold))
                                    .opacity(0.05)
                                    .italic()
                                
                                VStack(spacing: -6) {
                                    Text("The")
                                        .font(.caption2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Korean")
                                        .font(.title)
                                    
                                    Text("App")
                                        .font(.caption2)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .fontWeight(.bold)
                                .foregroundStyle(Color.accent)
                                .fixedSize(horizontal: true, vertical: false)
                            }
                             
                            // Old version indicator
    //                        Text("Beta 1.0")
    //                            .font(.caption)
    //                            .italic()
    //                    }
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
                            NavigationLink {
                                DictionaryEntryView(word: entry)
                            } label: {
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
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .safeAreaInset(edge: .top, spacing: 0) {
                GlassSearchBar(text: $searchText)
                    .padding(.horizontal)
            }
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
            try await Task.sleep(for: .milliseconds(500))
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

struct GlassSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search Korean or English", text: $text)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .fixedSize(horizontal: !isFocused, vertical: false)

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 14)
            .glassEffect(.regular, in: .capsule)

            if isFocused {
                Button {
                    text = ""
                    isFocused = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .frame(width: 44, height: 44)
                .glassEffect(.regular, in: .circle)
                .accessibilityLabel("Cancel search")
                .transition(.opacity.combined(with: .scale))
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.smooth(duration: 0.2), value: isFocused)
    }
}

#Preview {
    SearchView()
}
