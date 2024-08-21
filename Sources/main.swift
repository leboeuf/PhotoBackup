import Foundation
import Photos
import GRDB
 
// Request authorization to access the photo library
PHPhotoLibrary.requestAuthorization { status in
    guard status == .authorized else {
        print("Authorization not granted")
        exit(1);
    }
}

// Initialize database
let dbPath = getDatabasePath()
createFileIfNotExists(filePath: dbPath)
guard let db = initDatabase(dbPath: dbPath) else {
    exit(1);
}

private var sharedAlbums: [PHAssetCollection] = fetchSharedAlbums();

for sharedAlbum in sharedAlbums {
    print("Shared Album: \(sharedAlbum.localizedTitle ?? "Untitled")")
}

exit(EXIT_SUCCESS)