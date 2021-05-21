package com.bond.whiteboard.board

import android.content.Context
import com.bond.whiteboard.teb.MyBoardCallback
import com.tencent.teduboard.TEduBoardController

class BoardAware(private val context:Context) {


    var mBoard : TEduBoardController? =null
    var mBoardCallback: MyBoardCallback? = null

    fun destroy() {
        mBoard?.reset()
    }
}