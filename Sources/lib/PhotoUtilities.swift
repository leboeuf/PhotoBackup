import Photos

func getAlbumId(for sharedAlbum: PHAssetCollection) -> String {
    return sharedAlbum.localizedTitle ?? sharedAlbum.localIdentifier
}

func fetchSharedAlbums() -> [PHAssetCollection] {
    let fetchOptions = PHFetchOptions()
    let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: fetchOptions)
    
    var result: [PHAssetCollection] = []
    albums.enumerateObjects { (collection, _, _) in
        result.append(collection)
    }
    
    return result
}

func fetchPhotosInAlbum(for album: PHAssetCollection) -> PHFetchResult<PHAsset> {
    let fetchOptions = PHFetchOptions()
    return PHAsset.fetchAssets(in: album, options: fetchOptions)
}

func extractGuidFromFilename(for asset: PHAsset) -> String? {
    if let filename = asset.value(forKey: "filename") as? String {
        if let guid = filename.split(separator: ".").first {
            return String(guid)
        }
    }
    return nil
}

func getCreationDate(of asset: PHAsset, using dateFormatter: DateFormatter) -> String {
    guard let creationDate = asset.creationDate else {
        return ""
    }

    return dateFormatter.string(from: creationDate)
}