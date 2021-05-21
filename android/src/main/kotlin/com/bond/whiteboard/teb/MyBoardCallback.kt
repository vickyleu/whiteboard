package com.bond.whiteboard.teb

import android.util.Log
import com.tencent.rtmp.TXLog
import com.tencent.teduboard.TEduBoardController.TEduBoardCallback
import com.tencent.teduboard.TEduBoardController.TEduBoardTranscodeFileResult

class MyBoardCallback(var boardAwareCallback: BoardAwareInterface) : TEduBoardCallback {
    override fun onTEBError(code: Int, msg: String) {
        TXLog.i(TAG, "onTEBError:$code|$msg")
    }

    override fun onTEBWarning(code: Int, msg: String) {
        TXLog.i(TAG, "onTEBWarning:$code|$msg")
    }

    override fun onTEBInit() {
        boardAwareCallback.addBoardView()
    }

    override fun onTEBHistroyDataSyncCompleted() {
        boardAwareCallback.onTEBHistroyDataSyncCompleted()
    }

    override fun onTEBSyncData(data: String) {}
    override fun onTEBAddBoard(boardId: List<String>, fileId: String) {
        TXLog.i(TAG, "onTEBAddBoard:$fileId")
    }

    override fun onTEBDeleteBoard(boardId: List<String>, fileId: String) {
        TXLog.i(TAG, "onTEBDeleteBoard:$fileId|$boardId")
    }

    override fun onTEBGotoBoard(boardId: String, fileId: String) {
        TXLog.i(TAG, "onTEBGotoBoard:$fileId|$boardId")
    }

    override fun onTEBGotoStep(currentStep: Int, total: Int) {
        TXLog.i(TAG, "onTEBGotoStep:$currentStep|$total")
    }

    override fun onTEBRectSelected() {
        TXLog.i(TAG, "onTEBRectSelected:")
    }

    override fun onTEBRefresh() {
        TXLog.i(TAG, "onTEBRefresh:")
    }

    override fun onTEBDeleteFile(fileId: String) {}
    override fun onTEBSwitchFile(fileId: String) {}
    override fun onTEBAddTranscodeFile(s: String) {
        TXLog.i(TAG, "onTEBAddTranscodeFile:$s")
    }

    override fun onTEBUndoStatusChanged(canUndo: Boolean) {
        boardAwareCallback.setCanUndo(canUndo)
    }

    override fun onTEBRedoStatusChanged(canredo: Boolean) {
        boardAwareCallback.setCanRedo(canredo)
    }

    override fun onTEBFileUploadProgress(path: String, currentBytes: Int, totalBytes: Int, uploadSpeed: Int, percent: Float) {
        TXLog.i(TAG, "onTEBFileUploadProgress:$path percent:$percent")
    }

    override fun onTEBFileUploadStatus(path: String, status: Int, code: Int, statusMsg: String) {
        TXLog.i(TAG, "onTEBFileUploadStatus:$path status:$status")
    }

    override fun onTEBFileTranscodeProgress(s: String, s1: String, s2: String, tEduBoardTranscodeFileResult: TEduBoardTranscodeFileResult) {}
    override fun onTEBH5FileStatusChanged(fileId: String, status: Int) {}
    override fun onTEBAddImagesFile(fileId: String) {
        Log.i(TAG, "onTEBAddImagesFile:$fileId")
        val fileInfo = boardAwareCallback.addFile(fileId)
    }

    override fun onTEBVideoStatusChanged(fileId: String, status: Int, progress: Float, duration: Float) {
        Log.i(TAG, "onTEBVideoStatusChanged:$fileId | $status|$progress")
    }

    override fun onTEBAudioStatusChanged(elementId: String, status: Int, progress: Float, duration: Float) {
        Log.i(TAG, "onTEBAudioStatusChanged:$elementId | $status|$progress")
    }

    override fun onTEBSnapshot(path: String, code: Int, msg: String) {
        Log.i(TAG, "onTEBSnapshot:$path | $code|$msg")
    }

    override fun onTEBH5PPTStatusChanged(statusCode: Int, fid: String, describeMsg: String) {}
    override fun onTEBTextComponentStatusChange(status: String, id: String, value: String, left: Int, top: Int) {
        Log.e(TAG, "onTEBTextComponentStatusChange textH5Status:$status textH5Id:$id")
        boardAwareCallback.onTextComponentStatusChange(id, status)
    }

    override fun onTEBImageStatusChanged(boardId: String, url: String, status: Int) {
        TXLog.i(TAG, "onTEBImageStatusChanged:$boardId|$url|$status")
    }

    override fun onTEBSetBackgroundImage(url: String) {
        Log.i(TAG, "onTEBSetBackgroundImage:$url")
    }

    override fun onTEBAddImageElement(url: String) {
        Log.i(TAG, "onTEBAddImageElement:$url")
    }

    override fun onTEBAddElement(id: String, url: String) {}
    override fun onTEBDeleteElement(id: List<String>) {}
    override fun onTEBBackgroundH5StatusChanged(boardId: String, url: String, status: Int) {
        Log.i(TAG, "onTEBBackgroundH5StatusChanged:$boardId url:$boardId status:$status")
    }

    companion object {
        private const val TAG = "MyBoardCallback"
    }
}