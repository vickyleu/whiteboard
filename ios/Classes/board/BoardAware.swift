//
// Created by vicky Leu on 2021/5/19.
//

import Foundation
public class BoardAware{

    var mBoard :TEduBoardController?
    var mBoardCallback:MyBoardCallback?
    func destroy() {
        mBoard?.reset()
    }
    func reset(){
        mBoard?.clearDraws()
        mBoard?.reset()
        mBoard?.refresh()
    }
    
    func setBackgroundColor(_ color:UIColor){
        mBoard?.setBackgroundColor(color)
        mBoard?.refresh()
    }
}
