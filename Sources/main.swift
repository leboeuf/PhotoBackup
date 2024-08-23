import Foundation
import Photos
import GRDB

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyyMMdd HHmmss"
 
// Request authorization to access the photo library
PHPhotoLibrary.requestAuthorization { status in
    guard status == .authorized else {
        print("Authorization not granted")
        exit(1);
    }
}

// Fetch albums
let sharedAlbums = fetchSharedAlbums();
for sharedAlbum: PHAssetCollection in sharedAlbums {
    let albumId = getAlbumId(for: sharedAlbum)
    print("Backing up shared album: \(albumId)")

    // Initialize database
    let dbPath = getDatabasePath(albumId: albumId)
    createFileIfNotExists(filePath: dbPath)
    guard let albumDb = initDatabase(dbPath: dbPath) else {
        print("Error initializing database at path: '\(dbPath)'.")
        exit(1);
    }

    // Fetch assets
    let assets = fetchPhotosInAlbum(for: sharedAlbum)
    assets.enumerateObjects { (asset, index, stop) in
        guard let assetId = extractGuidFromFilename(for: asset) else {
            print("Error getting asset ID.")
            exit(1)
        }

        print(assetId)
        let creationDate = getCreationDate(of: asset, using: dateFormatter)

        let customId = "\(creationDate) \(assetId)".trimmingCharacters(in: .whitespaces)
        print("+ \(customId)")
        exit(EXIT_SUCCESS)
    }
}

exit(EXIT_SUCCESS)
