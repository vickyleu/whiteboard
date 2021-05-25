package com.tencent.tic.core.impl

/**
 * Created by eric on 2018/4/3.
 */
interface TICProgressCallback<T> {
    /**
     * 进度
     *
     * @param percent 百分比
     */
    fun onPrgress(percent: Int)

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
    fun onError(module: String?, errCode: Int, errMsg: String?)
}