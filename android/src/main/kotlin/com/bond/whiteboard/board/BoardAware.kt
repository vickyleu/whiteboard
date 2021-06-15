package com.bond.whiteboard.board

import android.content.Context
import android.graphics.Color
import androidx.annotation.ColorInt
import com.bond.whiteboard.teb.MyBoardCallback
import com.tencent.teduboard.TEduBoardController

class BoardAware(private val context:Context) {


    var mBoard : TEduBoardController? =null

    var mBoardCallback: MyBoardCallback? = null

    fun destroy() {
        mBoard?.reset()
    }

    fun reset() {
        mBoard?.clear(true)
        mBoard?.reset()
        mBoard?.refresh()
    }

    fun setBackgroundColor(@ColorInt color:Int){
        mBoard?.backgroundColor= TEduBoardController.TEduBoardColor(color)
        mBoard?.refresh()
    }
}