package com.tencent.tic.core.impl.observer

import com.tencent.tic.core.TICManager.TICEventListener
import java.lang.ref.WeakReference
import java.util.*

class TICEventObservable : TICObservableM<TICEventListener>(), TICEventListener {
    override fun onTICVideoDisconnect(i: Int, s: String) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICEventListener>?> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next()!!.get()
            t?.onTICVideoDisconnect(i, s)
        }
    }

    override fun onTICUserVideoAvailable(userId: String, available: Boolean) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICEventListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICUserVideoAvailable(userId, available)
        }
    }

    override fun onTICUserSubStreamAvailable(userId: String, available: Boolean) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICEventListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICUserSubStreamAvailable(userId, available)
        }
    }

    override fun onTICUserAudioAvailable(userId: String, available: Boolean) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICEventListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICUserAudioAvailable(userId, available)
        }
    }

    override fun onTICClassroomDestroy() {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICEventListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICClassroomDestroy()
        }
    }

    override fun onTICMemberJoin(list: List<String>) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICEventListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICMemberJoin(list)
        }
    }

    override fun onTICMemberQuit(list: List<String>) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICEventListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICMemberQuit(list)
        }
    }

    override fun onTICSendOfflineRecordInfo(code: Int, desc: String) {
        val tmpList = LinkedList(listObservers)
        val it: Iterator<WeakReference<TICEventListener>> = tmpList.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            t?.onTICSendOfflineRecordInfo(code, desc)
        }
    }
}