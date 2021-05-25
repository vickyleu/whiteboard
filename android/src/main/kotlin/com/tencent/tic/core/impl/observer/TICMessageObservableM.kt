package com.tencent.tic.core.impl.observer

import com.tencent.imsdk.TIMMessage
import com.tencent.tic.core.TICManager.TICMessageListener
import java.lang.ref.WeakReference
import java.util.*

class TICMessageObservableM : TICObservableM<TICMessageListener>(), TICMessageListener {
    override fun onTICRecvTextMessage(s: String, s1: String) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICMessageListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICRecvTextMessage(s, s1)
        }
    }

    override fun onTICRecvCustomMessage(s: String, bytes: ByteArray) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICMessageListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICRecvCustomMessage(s, bytes)
        }
    }

    override fun onTICRecvGroupTextMessage(fromUserId: String, text: String) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICMessageListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICRecvGroupTextMessage(fromUserId, text)
        }
    }

    override fun onTICRecvGroupCustomMessage(fromUserId: String, data: ByteArray) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICMessageListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICRecvGroupCustomMessage(fromUserId, data)
        }
    }

    override fun onTICRecvMessage(message: TIMMessage) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICMessageListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICRecvMessage(message)
        }
    }
}