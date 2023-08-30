//
//  ZLDownloadTask.swift
//

import Foundation
import AVFoundation

// 下载进度回调
typealias DownloadProgressHandler = ((AVAssetResourceLoadingRequest?, ZLDownloadTask) -> Void)
// 下载完成回调
typealias DownloadCompleteHandler = ((Data?, Error?) -> Void)

// 下载回调结构
class ZLDownloadCallback {
    // 播放器加载request
    let loadingRequest: AVAssetResourceLoadingRequest?
    // 进度回调
    let progressHandler: DownloadProgressHandler?
    // 完成回调
    let completeHandler: DownloadCompleteHandler?
    
    init?(loadingRequest: AVAssetResourceLoadingRequest? = nil, progress: DownloadProgressHandler? = nil, complete: DownloadCompleteHandler? = nil) {
        if loadingRequest == nil && progress == nil && complete == nil  {
            return nil
        }
        self.loadingRequest = loadingRequest
        self.progressHandler = progress
        self.completeHandler = complete
    }
    
}

// 下载任务
class ZLDownloadTask {
    // 下载url
    let url: URL
    // 下载任务
    let dataTask: URLSessionDataTask
    
    private var observers = [ZLWeakObject<ZLResourceLoader>]()
    private let observersLock = NSLock()
    // 回调
    lazy var callbacks = [ZLDownloadCallback]()
    private let callbacksLock = NSLock()
    // data
    var cachedData: Data {
        dataLock.lock()
        defer {
            dataLock.unlock()
        }
        
        let dataCopy = data
        return dataCopy
    }
    
    private lazy var data = Data()
    private let dataLock = NSLock()
    // 总长度
    var contentLength = 0
    // 通过URL和DataTask初始化
    init(url: URL, dataTask: URLSessionDataTask) {
        self.url = url
        self.dataTask = dataTask
    }
    // 添加data
    func appendData(_ newData: Data) {
        dataLock.lock()
        if newData.count > 0 {
            data.append(newData)
        }
        dataLock.unlock()
    }
    // 添加回调
    func addCallback(_ callback: ZLDownloadCallback) {
        callbacksLock.lock()
        callbacks.append(callback)
        callbacksLock.unlock()
    }
    // 移除回调
    func removeCallback(by loadingRequest: AVAssetResourceLoadingRequest) {
        callbacksLock.lock()
        
        if callbacks.count > 0{
            callbacks = callbacks.filter{ task -> Bool in
                return task.loadingRequest != loadingRequest
            }
        }
        
        callbacksLock.unlock()
    }
    // 添加观察者
    func addObsever(_ obsever: ZLWeakObject<ZLResourceLoader>) {
        if obsever.target == nil {
            return
        }
        
        observersLock.lock()
        observers = observers.filter { return $0.target != nil}
        if !observers.contains(where: { $0.target == obsever.target}) {
            observers.append(obsever)
        }
        observersLock.unlock()
    }
    // 移除观察者
    func removeObsever(_ obsever: ZLWeakObject<ZLResourceLoader>) {
        observersLock.lock()
        observers = observers.filter { return $0.target != nil && $0.target != obsever.target}
        observersLock.unlock()
    }
    // 过滤空的obsever，返回当前的数量
    func filterNullObsever() -> Int {
        observersLock.lock()
        observers = observers.filter { return $0.target != nil}
        observersLock.unlock()
        return observers.count
    }
    
}

extension ZLDownloadTask: Equatable {
    
    static func == (lhs: ZLDownloadTask, rhs: ZLDownloadTask) -> Bool {
        return lhs.url == rhs.url
    }
    
}
