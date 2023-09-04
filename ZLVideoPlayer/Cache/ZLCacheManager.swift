//
//  ZLCacheManager.swift
//

import Foundation

// 临时文件key
fileprivate let kDataKey          = "data"
fileprivate let kContentLengthKey = "contentLength"

// 缓存管理类
class ZLCacheManager {
    
    static let shared = ZLCacheManager()
    // IO队列
    private let ioQueue: DispatchQueue
    
    private init() {
        ioQueue = DispatchQueue(label: "CacheIOQueue")
    }
    // 异步载入缓存
    func asynLoadCache(url: URL, completeHandler: @escaping (Data?, Int?) -> Void) {
        ioQueue.async {
            let file = ZLCacheManager.filePath(url: url)
            if FileManager.default.fileExists(atPath: file) {
                var data: Data?
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    print("Cache", "load file error:\(error)")
                }
                
                if let data = data {
                    // 成功加载完整缓存
                    completeHandler(data, data.count)
                    return
                }
            }
            
            let tmpFile = ZLCacheManager.tmpFilePath(url: url)
            if !FileManager.default.fileExists(atPath: tmpFile) {
                completeHandler(nil, nil)
                return
            }
            
            if let tmpInfo = NSKeyedUnarchiver.unarchiveObject(withFile: tmpFile) as? [String: Any] {
                if let data = tmpInfo[kDataKey] as? Data,
                    let contentLength = tmpInfo[kContentLengthKey] as? Int {
                    completeHandler(data, contentLength)
                    return
                } else {
                    print("Cache", "tmp file data invalid")
                }
            } else {
                print("Cache", "load tmp file data fail")
            }
            
            do {
                try FileManager.default.removeItem(atPath: tmpFile)
            } catch {
                print("Cache", "remove tmp file error:\(error)")
            }
            completeHandler(nil, nil)
        }
    }
    // 保存缓存
    func storeCache(downloadTask: ZLDownloadTask, completion: (() -> Void)?) {
        ioQueue.async {
            if !FileManager.default.fileExists(atPath: ZLCacheManager.directory) {
                do {
                    try FileManager.default.createDirectory(atPath: ZLCacheManager.directory, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Cache", "create Directory error:\(error)")
                }
            }
            
            let url = downloadTask.url
            let tmpFile = ZLCacheManager.tmpFilePath(url: url)
            // 保存完整
            let data = downloadTask.cachedData
            let contentLength = downloadTask.contentLength
            let isFinished = (data.count == contentLength)
            if isFinished {
                let file = ZLCacheManager.filePath(url: url)
                do {
                    try data.write(to: URL(fileURLWithPath: file))
                } catch {
                    print("Cache", "store error:\(error)")
                }
                
                if FileManager.default.fileExists(atPath: tmpFile) {
                    do {
                        try FileManager.default.removeItem(atPath: tmpFile)
                    } catch {
                        print("Cache", "remove tmp file error:\(error)")
                    }
                }
            } else {
                // 保存临时信息
                let tmpInfo = [kDataKey: data, kContentLengthKey: contentLength] as [String : Any]
                let success = NSKeyedArchiver.archiveRootObject(tmpInfo, toFile: tmpFile)
                if !success {
                    print("Cache", "store tmp file error")
                }
            }
            completion?()
        }
    }
    // 删除缓存
    func removeCache(url: URL, completion: (() -> Void)?) {
        ioQueue.async {
            // 临时文件
            let tmpFile = ZLCacheManager.tmpFilePath(url: url)
            if FileManager.default.fileExists(atPath: tmpFile) {
                do {
                    try FileManager.default.removeItem(atPath: tmpFile)
                } catch {
                    print("Cache", "remove tmp file error:\(error)")
                }
            }
            // 完整文件
            let file = ZLCacheManager.filePath(url: url)
            if FileManager.default.fileExists(atPath: file) {
                do {
                    try FileManager.default.removeItem(atPath: file)
                } catch {
                    print("Cache", "remove file error:\(error)")
                }
            }
            completion?()
        }
    }
    
}

extension ZLCacheManager {
    // 文件目录
    static var directory: String = FileManager.cachePath.appendingPathComponent("Videos")
    // 文件名
    static func fileName(url: URL) -> String {
        return url.absoluteString.md5String
    }
    // 文件路径
    static func filePath(url: URL) -> String {
        let fileName = fileName(url: url)
        return directory.appendingPathComponent(fileName) + ".mp4"
    }
    // 文件是否存在
    static func existFilePath(url: URL) -> String? {
        let path = filePath(url: url)
        if FileManager.default.fileExists(atPath:path) {
            return path
        }
        return nil
    }
    // 临时文件路径
    static func tmpFilePath(url: URL) -> String {
        let fileName = fileName(url: url)
        return directory.appendingPathComponent(fileName) + ".tmp"
    }
    // 临时文件是否存在
    static func isTmpFileExist(url: URL) -> Bool {
        let path = tmpFilePath(url: url)
        return FileManager.default.fileExists(atPath:path)
    }
    
}
