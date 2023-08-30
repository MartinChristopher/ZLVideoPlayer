//
//  ZLFileManager.swift
//

import Foundation

extension FileManager {
    // Documents路径
    static var documentsPath: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    // UsersDocuments目录
    static var usersDocumentsPath: String? {
        let usersDocumentsPath = FileManager.documentsPath.appendingPathComponent("Users")
        guard createPath(path: usersDocumentsPath) else {
            return nil
        }
        return usersDocumentsPath
    }
    // Caches路径
    static var cachesPath: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }
    // UsersCache目录
    static var usersCachePath: String? {
        let usersCachePath = FileManager.cachesPath.appendingPathComponent("Users")
        guard createPath(path: usersCachePath) else {
            return nil
        }
        return usersCachePath
    }
    // 创建目录
    static func createPath(path: String) -> Bool {
        var success = true
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                success = false
                print("FileManager", "create path=\(path) error:\(error)")
            }
        }
        return success
    }
    // 创建文件
    static func createFile(file: String) -> Bool {
        if !FileManager.default.fileExists(atPath: file) {
            return FileManager.default.createFile(atPath: file, contents: nil, attributes: nil)
        }
        return true
    }
    
}
