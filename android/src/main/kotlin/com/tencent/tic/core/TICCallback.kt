package com.tencent.tic.core

/**
 * ILive通用返回回调
 */
interface TICCallback<T> {
    /**
     * 操作成功
     *
     * @param data 成功返回值
     */
    fun onSuccess(data: T)

    /**
     * 操作失败
     *
     * @param module  出错模块
     * @param errCode 错误码
     * @param errMsg  错误描述
     */
    fun onError(module: String, errCode: Int, errMsg: String)
}