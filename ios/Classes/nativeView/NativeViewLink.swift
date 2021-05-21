//
// Created by vicky Leu on 2021/5/19.
//

import Foundation
import Masonry


protocol NativeViewLink {
    func addView(_ view: UIView,layoutParam:(UIView, MASConstraintMaker?) -> ())
    func removeView(_ view: UIView)
}
