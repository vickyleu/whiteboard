//
// Created by vicky Leu on 2021/5/19.
//

import Foundation
public class RtcAware{
    
    let mTrtcCloud: TRTCCloud?
    
    var mEnableAudio = false
    var mEnableAudioRouteSpeaker = false
    var mEnableCamera = false
    var mEnableFrontCamera = false
    //    var mTrtcRootView: TICVideoRootView? = null
    var mAudioElementId: String?
    var mImgsFid: String?
    var mUserID: String?
    
    
    init(_ cloud: TRTCCloud?) {
        self.mTrtcCloud=cloud
    }
    
    
    
    func initRTC() {
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
    
    func startLocalVideo(_ enable: Bool) {
//        if (mTrtcCloud != nil) {
//            let usrid = mUserID
//            let localVideoView = mTrtcRootView?.getCloudVideoViewByUseId(usrid)
//            localVideoView?.userId = usrid
//            localVideoView?.isHidden = true
//            if (enable) {
//                mTrtcCloud?.startLocalPreview(mEnableFrontCamera, localVideoView)
//            } else {
//                mTrtcCloud?.stopLocalPreview()
//            }
//        }
    }
    
    func enableAudioCapture(_ enableAudio: Bool) {
        if (mTrtcCloud != nil) {
            if (enableAudio) {
                mTrtcCloud?.startLocalAudio()
            } else {
                mTrtcCloud?.stopLocalAudio()
            }
        }
    }
    
    func destroy() {
        //3、停止本地视频图像
        mTrtcCloud?.stopLocalPreview()
        enableAudioCapture(false)
    }
}
