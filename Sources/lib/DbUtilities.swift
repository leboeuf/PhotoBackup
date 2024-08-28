import Foundation
import GRDB

func initDatabase(dbPath: URL) -> DatabaseQueue? {
    do {
        let dbQueue = try DatabaseQueue(path: dbPath.absoluteString)

        if try !schemaExists(in: dbQueue) {
            try createSchema(in: dbQueue)
        }

        return dbQueue
    } catch {
        print("Failed to initialize database: \(error)")
        return nil
    }
}

private func schemaExists(in dbQueue: DatabaseQueue) throws -> Bool {
    return try dbQueue.read { db in
        let count = try Int.fetchOne(db, sql: """
            SELECT COUNT(*)
            FROM sqlite_master
            WHERE type = 'table' AND name = 'assets'
            """)!
        return count > 0
    }
}

private func createSchema(in dbQueue: DatabaseQueue) throws {
    try dbQueue.write { db in
        try db.create(table: Asset.databaseTableName) { t in
            t.primaryKey("id", .text)
        }
    }
}

func recordExists(in dbQueue: DatabaseQueue, id: String) throws -> Bool {
    return try dbQueue.read { db in
        return try Asset.fetchOne(db, key: id) != nil
    }
}

func insertRecord(in dbQueue: DatabaseQueue, id: String) throws {
    let asset = Asset(id: id)
    try dbQueue.write { db in
        try asset.insert(db)
    }
}