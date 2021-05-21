//
// Created by vicky Leu on 2021/5/19.
//

import Foundation

protocol ScopeFunc {}
extension ScopeFunc {
    @inline(__always) func also(block: (_ s:Self) -> ()) -> Self {
        block(self)
        return self
    }
}
extension NSObject: ScopeFunc {}
