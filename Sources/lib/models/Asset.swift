import Foundation
import GRDB

struct Asset: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var album: String
    var dateProcessed: Date
}