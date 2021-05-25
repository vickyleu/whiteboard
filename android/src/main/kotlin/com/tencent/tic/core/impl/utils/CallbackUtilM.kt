package com.tencent.tic.core.impl.utils

import com.tencent.liteav.basic.log.TXCLog
import com.tencent.tic.core.TICCallback

object CallbackUtilM {
    @JvmStatic
    fun notifySuccess(callBack: TICCallback<out Any>?, data: Any) {
        callBack?.onSuccess(data as Nothing)
    }

    @JvmStatic
    fun notifyError(callBack: TICCallback<out Any>?, module: String?, errCode: Int, errMsg: String?) {
        callBack?.onError(module, errCode, errMsg)
        TXCLog.e(module, errMsg)
    }
}