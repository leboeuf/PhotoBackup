import Photos

func fetchSharedAlbums() -> [PHAssetCollection] {
    let fetchOptions = PHFetchOptions()
    let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumCloudShared, options: fetchOptions)
    
    var result: [PHAssetCollection] = []
    albums.enumerateObjects { (collection, _, _) in
        result.append(collection)
    }
    
    return result
}