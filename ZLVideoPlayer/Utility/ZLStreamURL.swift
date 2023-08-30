//
//  ZLStreamURL.swift
//

import Foundation

extension URL {
    // 代理的scheme
    var streamSchemeURL: URL {
        var component = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        component.scheme = "Stream"
        return component.url!
    }
    
}
