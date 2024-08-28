import Foundation
import GRDB

struct Asset: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "assets"

    var id: String
}