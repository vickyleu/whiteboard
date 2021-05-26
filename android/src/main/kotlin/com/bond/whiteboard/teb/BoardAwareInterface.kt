package com.bond.whiteboard.teb

import com.tencent.teduboard.TEduBoardController.TEduBoardFileInfo

interface BoardAwareInterface {
    fun onTEBHistroyDataSyncCompleted()
    fun addBoardView()
    fun removeBoardView()
    fun setCanUndo(canUndo: Boolean)
    fun setCanRedo(canredo: Boolean)
    fun addFile(fileId: String?): TEduBoardFileInfo?
    fun onTextComponentStatusChange(id: String?, status: String?)
    fun onTEBSyncData(data: String)
    fun sendMessage(data: ByteArray, extension: String)
}