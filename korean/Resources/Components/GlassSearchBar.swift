//
//  GlassSearchBar.swift
//  korean
//
//  Created by Phoenix Fisher on 11/17/26.
//

import SwiftUI

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
                        .foregroundStyle(Color.primary)
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
    @Previewable @State var searchText = ""
    GlassSearchBar(text: $searchText)
}
