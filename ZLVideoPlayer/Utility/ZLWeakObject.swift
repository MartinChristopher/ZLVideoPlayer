//
//  ZLWeakObject.swift
//

import Foundation

// 弱引用对象容器
class ZLWeakObject<T: AnyObject> where T: Equatable {
    
    weak var target: T?
    
    init(target: T) {
        self.target = target
    }
    
}
