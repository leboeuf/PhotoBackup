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

func fetchLivePhoto(for asset: PHAsset, albumId: String) {
    let livePhotoOptions = PHLivePhotoRequestOptions()
    livePhotoOptions.isNetworkAccessAllowed = true
    
    PHImageManager.default().requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: livePhotoOptions) { livePhoto, info in
        guard let livePhoto = livePhoto else {
            fatalError("Failed to retrieve Live Photo.")
        }

        if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, isDegraded {
            // This is a low-quality, degraded version of the Live Photo. The handler
            // will be called again once the high-quality photo is available.
            return
        }

        let assetResources = PHAssetResource.assetResources(for: livePhoto)
        var videoResource : PHAssetResource?
        for resources in assetResources {
            if(resources.type == .pairedVideo) {
                videoResource = resources
                break
            }
        }

        guard let videoResource = videoResource else {
            fatalError("Failed to retrieve video resource from Live Photo")
        }

        // Save video resource of Live Photo
        let outputDirectory = getBackupDirectory()
        .appendingPathComponent(albumId)
        let fileURL = outputDirectory.appendingPathComponent("test.mov")
        PHAssetResourceManager.default().writeData(for: videoResource, toFile: fileURL, options: nil) { error in
            if (error != nil) {
                fatalError(error!.localizedDescription)
            }
            print("Video saved")
        }

        // TODO: save photo

        // TODO: save to db
    }
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