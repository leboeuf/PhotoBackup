import Foundation
import Photos
import GRDB

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
 
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
        print("[\(index + 1)/\(sharedAlbum.estimatedAssetCount)]")
        downloadAsset(asset: asset, db: albumDb, albumId: albumId)
    }
}

exit(EXIT_SUCCESS)

func downloadAsset(asset: PHAsset, db: DatabaseQueue, albumId: String) {
    guard let assetId = extractGuidFromFilename(for: asset) else {
        print("Error getting asset ID.")
        exit(1)
    }

    let creationDate = getCreationDate(of: asset, using: dateFormatter)
    let customId = "\(creationDate)_\(assetId)".trimmingCharacters(in: .whitespaces)
    print("+ \(customId)")

    let outputDirectory = getBackupDirectory()
        .appendingPathComponent(albumId)

    if (asset.mediaType == .video) {
        // Request video
        print("  + Video")
        exit(EXIT_SUCCESS) // TODO
        return
    }

    if (asset.mediaType == .image) {
        // Request image
        print("  + Image")

        if (asset.mediaSubtypes.contains(.photoLive)) {
            print("  + Live photo")
        }
        return
    }

    print("Error: unknown asset type. Aborting.")
    exit(EXIT_SUCCESS)
}
