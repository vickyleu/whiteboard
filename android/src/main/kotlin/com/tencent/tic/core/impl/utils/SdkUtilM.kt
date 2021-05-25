package com.tencent.tic.core.impl.utils

import android.app.ActivityManager
import android.content.Context
import android.os.Process

object SdkUtilM {
    fun isMainProcess(context: Context): Boolean {
        return context.packageName == getProcessName(context)
    }

    // you can use this method to get current process name, you will get
    // name like "com.package.name"(main process name) or "com.package.name:remote"
    private fun getProcessName(context: Context): String? {
        val mypid = Process.myPid()
        val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val infos = manager.runningAppProcesses
        for (info in infos) {
            if (info.pid == mypid) {
                return info.processName
            }
        }
        // may never return null
        return null
    }
}