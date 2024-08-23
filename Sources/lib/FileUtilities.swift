import Foundation
import GRDB

func getBackupDirectory() -> URL {
    let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
    let backupDirectory = downloadsDirectory!.appendingPathComponent("PhotoBackupOutput")
    return backupDirectory
}

func getDatabasePath(albumId: String) -> URL {
    return getBackupDirectory()
        .appendingPathComponent("_db")
        .appendingPathComponent("\(albumId).sqlite")
}

func createFileIfNotExists(filePath: URL) {
    let fileManager = FileManager.default
    
    do {
        // Ensure the directory exists
        let directory = filePath.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Ensure the file exists
        if !fileManager.fileExists(atPath: filePath.path) {
            fileManager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
        }
    } catch {
        print("Failed to create database path: \(error)")
    }
}