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

    createDirectoryIfNotExists(directory: filePath.deletingLastPathComponent())
    
    do {
        if !fileManager.fileExists(atPath: filePath.path) {
            fileManager.createFile(atPath: filePath.path, contents: nil, attributes: nil)
        }
    } catch {
        print("Failed to create database path: \(error)")
    }
}

func createDirectoryIfNotExists(directory: URL) {
    let fileManager = FileManager.default
    
    do {
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
    } catch {
        print("Failed to create directory: \(error)")
    }
}