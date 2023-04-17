//
//  Configurable.swift
//  FolioReaderKit
//
//  Created by Luann Luna on 17/04/23.
//

import Foundation

public protocol Configurable { }

public extension Configurable {

    func with(_ configure: (inout Self) -> Void) -> Self {
        var this = self
        configure(&this)
        return this
    }
}

extension NSObject: Configurable { }
