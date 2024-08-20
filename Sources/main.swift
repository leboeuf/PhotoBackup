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

// Fetch shared albums
let fetchOptions = PHFetchOptions()
let sharedAlbumCollection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: fetchOptions)

sharedAlbumCollection.enumerateObjects { (collection, index, stop) in
    print("Shared Album: \(collection.localizedTitle ?? "Untitled")")
}

exit(EXIT_SUCCESS)