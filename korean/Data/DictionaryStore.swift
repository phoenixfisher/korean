import Foundation
import SQLite3

struct DictionaryEntry: Identifiable, Sendable {
    let id: Int64
    let lemma: String
    let englishLemma: String?
    let englishDefinition: String
}

actor DictionaryStore {
    enum StoreError: LocalizedError {
        case missingDatabase
        case couldNotOpen(String)
        case couldNotPrepare(String)
        case couldNotRead(String)

        var errorDescription: String? {
            switch self {
            case .missingDatabase:
                "The dictionary database is missing from the app bundle."
            case .couldNotOpen(let message):
                "The dictionary could not be opened: \(message)"
            case .couldNotPrepare(let message):
                "The dictionary search could not be prepared: \(message)"
            case .couldNotRead(let message):
                "The dictionary search failed: \(message)"
            }
        }
    }

    func search(for query: String, limit: Int = 100) throws -> [DictionaryEntry] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        guard let databaseURL = Bundle.main.url(
            forResource: "KoreanDictionary",
            withExtension: "sqlite"
        ) else {
            throw StoreError.missingDatabase
        }

        var database: OpaquePointer?
        let openResult = sqlite3_open_v2(
            databaseURL.path,
            &database,
            SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX,
            nil
        )

        guard openResult == SQLITE_OK, let database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) }
                ?? "Unknown SQLite error"
            if let database {
                sqlite3_close_v2(database)
            }
            throw StoreError.couldNotOpen(message)
        }
        defer {
            sqlite3_close_v2(database)
        }

        sqlite3_exec(database, "PRAGMA query_only = ON", nil, nil, nil)

        let sql = """
            SELECT
                s.id,
                e.lemma,
                s.english_lemma,
                s.english_definition
            FROM entries AS e
            JOIN english_senses AS s ON s.entry_id = e.id
            WHERE s.english_definition IS NOT NULL
              AND trim(s.english_definition) <> ''
              AND e.lemma LIKE ?1 ESCAPE '\\'
            ORDER BY
                CASE WHEN e.lemma = ?2 THEN 0 ELSE 1 END,
                e.lemma,
                s.sense_number
            LIMIT ?3
            """

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            throw StoreError.couldNotPrepare(String(cString: sqlite3_errmsg(database)))
        }
        defer {
            sqlite3_finalize(statement)
        }

        let prefixPattern = escapedLikePattern(trimmedQuery) + "%"
        let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

        guard prefixPattern.withCString({
            sqlite3_bind_text(statement, 1, $0, -1, transient)
        }) == SQLITE_OK,
        trimmedQuery.withCString({
            sqlite3_bind_text(statement, 2, $0, -1, transient)
        }) == SQLITE_OK,
        sqlite3_bind_int(statement, 3, Int32(limit)) == SQLITE_OK else {
            throw StoreError.couldNotPrepare(String(cString: sqlite3_errmsg(database)))
        }

        var entries: [DictionaryEntry] = []

        while true {
            switch sqlite3_step(statement) {
            case SQLITE_ROW:
                entries.append(
                    DictionaryEntry(
                        id: sqlite3_column_int64(statement, 0),
                        lemma: string(from: statement, column: 1) ?? "",
                        englishLemma: string(from: statement, column: 2),
                        englishDefinition: string(from: statement, column: 3) ?? ""
                    )
                )
            case SQLITE_DONE:
                return entries
            default:
                throw StoreError.couldNotRead(String(cString: sqlite3_errmsg(database)))
            }
        }
    }

    private func string(from statement: OpaquePointer, column: Int32) -> String? {
        guard sqlite3_column_type(statement, column) != SQLITE_NULL,
              let text = sqlite3_column_text(statement, column) else {
            return nil
        }

        return String(cString: text)
    }

    private func escapedLikePattern(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
    }
}
