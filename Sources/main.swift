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
    let assetArray = assets.objects(at: IndexSet(0..<assets.count))
    for (index, asset) in assetArray.enumerated() {
        print("[\(index + 1)/\(sharedAlbum.estimatedAssetCount)]")
        await downloadAsset(asset: asset, db: albumDb, albumId: albumId)
    }
}

exit(EXIT_SUCCESS)

func downloadAsset(asset: PHAsset, db: DatabaseQueue, albumId: String) async {
    guard let assetId = extractGuidFromFilename(for: asset) else {
        fatalError("Error getting asset ID.")
    }

    let creationDate = getCreationDate(of: asset, using: dateFormatter)
    let customId = "\(creationDate)_\(assetId)".trimmingCharacters(in: .whitespaces)
    print("+ \(customId)")

    // TODO: skip if already in db

    let outputDirectory = getBackupDirectory()
        .appendingPathComponent(albumId)
    createDirectoryIfNotExists(directory: outputDirectory)

    if (asset.mediaType == .video) {
        // Request video
        print("  + Video")
        await fetchVideo(for: asset, albumId: albumId, fileName: customId)
        exit(EXIT_SUCCESS) // TODO
        return
    }

    if (asset.mediaType == .image) {
        // Request image
        print("  + Image")

        if (asset.mediaSubtypes.contains(.photoLive)) {
            print("  + Live photo")
            //await fetchLivePhoto(for: asset, albumId: albumId, fileNamePrefix: creationDate)
            //exit(EXIT_SUCCESS) // TODO
        } else {
            // TODO: fetch photo
            //await fetchPhoto(for: asset, albumId: albumId, fileNamePrefix: creationDate)
            //exit(EXIT_SUCCESS) // TODO
        }
        return
    }

    print("Error: unknown asset type. Aborting.")
    exit(EXIT_SUCCESS)
}
