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

func fetchVideo(for asset: PHAsset, albumId: String, fileName: String) async {
    return await withCheckedContinuation { continuation in
        let assetResources = PHAssetResource.assetResources(for: asset)
        guard let videoResource = assetResources.first(where: { $0.type == .video }) else {
            fatalError("Error: asset is not a video")
        }

        // TODO: this approach doesn't keep metadata
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true

        let fileExt = (videoResource.originalFilename as NSString).pathExtension
        let outputDirectory = getBackupDirectory().appendingPathComponent(albumId)
        let videoFileURL = outputDirectory.appendingPathComponent("\(fileName).\(fileExt)")
        
        Task {
            do {
                // Save video resource of Live Photo
                if (!FileManager.default.fileExists(atPath: videoFileURL.path)) {
                    try await PHAssetResourceManager.default().writeData(for: videoResource, toFile: videoFileURL, options: options)
                    print("  + Video")
                } else {
                    print("  ! Video skipped (file already exists)")
                }
            } catch {
                fatalError(error.localizedDescription)
            }

            // TODO: save to db
            continuation.resume()
        }
    }
}

func fetchLivePhoto(for asset: PHAsset, albumId: String, fileNamePrefix: String) async {
    return await withCheckedContinuation { continuation in
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
            var photoResource: PHAssetResource?
            
            for resource in assetResources {
                if resource.type == .pairedVideo {
                    videoResource = resource
                } else if resource.type == .photo {
                    photoResource = resource
                }
            }

            guard let videoResource = videoResource else {
                fatalError("Failed to retrieve video resource from Live Photo")
            }

            guard let photoResource = photoResource else {
                fatalError("Failed to retrieve photo resource from Live Photo")
            }

            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = true
            let outputDirectory = getBackupDirectory().appendingPathComponent(albumId)
            let videoFileURL = outputDirectory.appendingPathComponent("\(fileNamePrefix)_\(videoResource.originalFilename)")
            let photoFileURL = outputDirectory.appendingPathComponent("\(fileNamePrefix)_\(photoResource.originalFilename)")

            Task {
                do {
                    // Save video resource of Live Photo
                    if (!FileManager.default.fileExists(atPath: videoFileURL.path)) {
                        try await PHAssetResourceManager.default().writeData(for: videoResource, toFile: videoFileURL, options: options)
                        print("    + Video")
                    } else {
                        print("    ! Video skipped (file already exists)")
                    }
                    
                    // Save photo resource of Live Photo
                    if (!FileManager.default.fileExists(atPath: photoFileURL.path)) {
                        try await PHAssetResourceManager.default().writeData(for: photoResource, toFile: photoFileURL, options: options)
                        print("    + Image")
                    } else {
                        print("    ! Image skipped (file already exists)")
                    }
                } catch {
                    fatalError(error.localizedDescription)
                }

                // TODO: save to db

                continuation.resume()
            }
        }
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
