package com.bond.whiteboard.rtc

import android.content.Context
import com.tencent.trtc.TRTCCloud

class RtcAware(trtcClound: TRTCCloud?) {

    var mEnableAudio = false
    var mEnableAudioRouteSpeaker = false
    var mEnableCamera = false
    var mEnableFrontCamera = false
    //    var mTrtcRootView: TICVideoRootView? = null
    var mAudioElementId: String? = null
    var mImgsFid: String? = null
    var mTrtcCloud: TRTCCloud? = trtcClound
    var mUserID: String? = null

    fun initRTC(context:Context){
//        mTrtcRootView=TICVideoRootView(context).also {
//            it.orientation= LinearLayout.HORIZONTAL
//            LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,160)
////            LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,dp2px(160))
//        }
//        //2、TRTC View
//        mTrtcRootView!!.setUserId(mUserID)
//        val localVideoView = mTrtcRootView!!.getCloudVideoViewByIndex(0)
//        localVideoView.userId = mUserID
//        //3、开始本地视频图像
//        startLocalVideo(true)
//        //4. 开始音频
//        enableAudioCapture(true)
    }

    fun startLocalVideo(enable: Boolean) {
        if (mTrtcCloud != null) {
//            val usrid = mUserID
//            val localVideoView = mTrtcRootView?.getCloudVideoViewByUseId(usrid)
//            localVideoView?.userId = usrid
//            localVideoView?.visibility = View.VISIBLE
//            if (enable) {
//                mTrtcCloud?.startLocalPreview(mEnableFrontCamera, localVideoView)
//            } else {
//                mTrtcCloud?.stopLocalPreview()
//            }
        }
    }

    fun enableAudioCapture(enableAudio: Boolean) {
        if (mTrtcCloud != null) {
            if (enableAudio) {
                mTrtcCloud?.startLocalAudio()
            } else {
                mTrtcCloud?.stopLocalAudio()
            }
        }
    }

    fun destroy() {
        //3、停止本地视频图像
        mTrtcCloud?.stopLocalPreview()
        enableAudioCapture(false)
    }
}