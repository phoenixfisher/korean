# Korean Dictionary

A small SwiftUI iOS app for searching Korean headwords and reading their English definitions.

The app bundles its SQLite dictionary as a read-only resource. Searches use the database's `entries` and `english_senses` tables; the original database is never modified at runtime.

## Requirements

- Xcode 27 or later
- iOS 27 or later
- Git LFS, for downloading `KoreanDictionary.sqlite`

## Getting started

1. Install Git LFS if it is not already available:

   ```sh
   brew install git-lfs
   git lfs install
   ```

2. Clone the repository and open `korean.xcodeproj` in Xcode.
3. Select the `korean` scheme and an iPhone simulator or connected device.
4. Press **Command-R** to build and run.
5. Enter a Korean word, such as `한국`, in the search field.

## Project structure

- `korean/ContentView.swift` provides the search interface and results list.
- `korean/DictionaryStore.swift` performs parameterized, read-only SQLite searches.
- `korean/KoreanDictionary.sqlite` contains the bundled dictionary data and is tracked with Git LFS.

## Data and licensing

The original Swift source code is available under the MIT License; see [LICENSE](LICENSE).

The bundled dictionary contains third-party material that is not covered by the MIT License. Its sources include the National Institute of Korean Language's Korean Basic Dictionary, libhangul Hanja data, and the Unicode Character Database. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for attribution and applicable terms.

