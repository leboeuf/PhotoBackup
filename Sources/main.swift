import Foundation
import GRDB
import Photos

// Request authorization to access the photo library
PHPhotoLibrary.requestAuthorization { status in
    guard status == .authorized else {
        print("Authorization not granted")
        exit(1);
    }
}

private var sharedAlbums: [PHAssetCollection] = fetchSharedAlbums();

for sharedAlbum in sharedAlbums {
    print("Shared Album: \(sharedAlbum.localizedTitle ?? "Untitled")")
}

exit(EXIT_SUCCESS)