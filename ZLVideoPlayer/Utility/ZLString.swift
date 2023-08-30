//
//  ZLString.swift
//

import Foundation
import CommonCrypto

extension String {
    // md5值
    var md5String: String {
        return withCString { (ptr: UnsafePointer<Int8>) -> String in
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
            defer {
                buffer.deallocate()
            }
            CC_MD5(UnsafeRawPointer(ptr), CC_LONG(lengthOfBytes(using: .utf8)), buffer)
            var hash = String()
            for i in 0..<Int(CC_MD5_DIGEST_LENGTH) {
                hash.append(String(format: "%02x", buffer[i]))
            }
            return hash
        }
    }
    
}

extension String {
    // 最后一个路径组件
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    // 删除最后一个路径组件
    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    // 添加路径组件
    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
    
}
