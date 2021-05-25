package com.tencent.tic.core.impl.observer

import java.lang.ref.WeakReference
import java.util.*

open class TICObservableM<T> {
    // 成员监听链表
    protected var listObservers = LinkedList<WeakReference<T>>()

    // 添加观察者
    fun addObserver(l: T) {
        for (listener in listObservers) {
            val t = listener.get()
            if (t != null && t == l) {
                return
            }
        }
        val weaklistener = WeakReference(l)
        listObservers.add(weaklistener)
    }

    // 移除观察者
    fun removeObserver(l: T) {
        val it = listObservers.iterator()
        while (it.hasNext()) {
            val t = it.next().get()
            if (t != null && t == l) {
                it.remove()
                break
            }
        }
    }
}