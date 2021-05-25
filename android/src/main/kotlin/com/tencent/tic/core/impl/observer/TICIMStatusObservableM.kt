package com.tencent.tic.core.impl.observer

import com.tencent.imsdk.TIMUserStatusListener
import com.tencent.tic.core.TICManager.TICIMStatusListener
import com.tencent.tic.core.impl.TICReporter
import java.lang.ref.WeakReference
import java.util.*

class TICIMStatusObservableM : TICObservableM<TICIMStatusListener>(), TIMUserStatusListener {
    override fun onForceOffline() {
        TICReporter.report(TICReporter.EventId.ON_FORCE_OFFLINE)
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICIMStatusListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICForceOffline()
        }
    }

    override fun onUserSigExpired() {
        TICReporter.report(TICReporter.EventId.ON_USER_SIG_EXPIRED)
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICIMStatusListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICUserSigExpired()
        }
    }
}