//
//  DictionaryEntryView.swift
//  korean
//
//  Created by Phoenix Fisher on 11/14/26.
//

import SwiftUI

struct DictionaryEntryView: View {
    let word: DictionaryEntry
    
    var body: some View {
        List {
            Section {
                GeneralInfoRow(type: "Romanization", info: "han-guk-eo")
                GeneralInfoRow(type: "Pronuncation", info: "항구거")
            } header: {
                Text(word.lemma)
                    .font(.largeTitle)
                    .foregroundStyle(Color.primary)
                    .fontWeight(.bold)
            }
            
            Section("TRANSLATION") {
                Text("Hello")
            }
            
            Section("HANJA IN THIS WORD") {
                
            }
            
            Section("EXAMPLES") {
                
            }
            
            Section("NOTE") {
                
            }
            
            Section {
                EmptyView()
            } footer: {
                Button("Suggest an Edit") { }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .listStyle(.grouped)
        .navigationTitle(word.lemma)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func GeneralInfoRow(type: String, info: String) -> some View {
        HStack(spacing: 18) {
            Text(type)
                .foregroundStyle(Color.secondary)
                .frame(width: 120, alignment: .trailing)
            
            Text(info)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    DictionaryEntryView(word: DictionaryEntry(id: 1, lemma: "한국어", englishLemma: "Korean", englishDefinition: "the language of Korea"))
}
