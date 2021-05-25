package com.tencent.instacart.library.truetime

import android.os.SystemClock
import android.util.Log

internal class DiskCacheClient {
    private var cacheInterface: CacheInterface? = null

    /**
     * Provide your own cache interface to cache the true time information.
     * @param cacheInterface the customized cache interface to save the true time data.
     */
    fun enableCacheInterface(cacheInterface: CacheInterface?) {
        this.cacheInterface = cacheInterface
    }

    /**
     * Clear the cache cache when the device is rebooted.
     * @param cacheInterface the customized cache interface to save the true time data.
     */
    @JvmOverloads
    fun clearCachedInfo(cacheInterface: CacheInterface? = this.cacheInterface) {
        cacheInterface?.clear()
    }

    fun cacheTrueTimeInfo(sntpClient: SntpClient) {
        if (cacheUnavailable()) {
            return
        }
        val cachedSntpTime = sntpClient.getCachedSntpTime()
        val cachedDeviceUptime = sntpClient.getCachedDeviceUptime()
        val bootTime = cachedSntpTime - cachedDeviceUptime
        Log.d(
            TAG, String.format(
                "Caching true time info to disk sntp [%s] device [%s] boot [%s]",
                cachedSntpTime,
                cachedDeviceUptime,
                bootTime
            )
        )
        cacheInterface!!.put(CacheInterface.KEY_CACHED_BOOT_TIME, bootTime)
        cacheInterface!!.put(CacheInterface.KEY_CACHED_DEVICE_UPTIME, cachedDeviceUptime)
        cacheInterface!!.put(CacheInterface.KEY_CACHED_SNTP_TIME, cachedSntpTime)
    }

    // has boot time changed (simple check)
    val isTrueTimeCachedFromAPreviousBoot: Boolean
        get() {
            if (cacheUnavailable()) {
                return false
            }
            val cachedBootTime = cacheInterface!![CacheInterface.KEY_CACHED_BOOT_TIME, 0L]
            if (cachedBootTime == 0L) {
                return false
            }

            // has boot time changed (simple check)
            val bootTimeChanged = SystemClock.elapsedRealtime() < cachedDeviceUptime
            Log.i(TAG, "---- boot time changed $bootTimeChanged")
            return !bootTimeChanged
        }
    val cachedDeviceUptime: Long
        get() = if (cacheUnavailable()) {
            0L
        } else cacheInterface!![CacheInterface.KEY_CACHED_DEVICE_UPTIME, 0L]
    val cachedSntpTime: Long
        get() = if (cacheUnavailable()) {
            0L
        } else cacheInterface!![CacheInterface.KEY_CACHED_SNTP_TIME, 0L]

    // -----------------------------------------------------------------------------------
    private fun cacheUnavailable(): Boolean {
        if (cacheInterface == null) {
            Log.w(TAG, "Cannot use disk caching strategy for TrueTime. CacheInterface unavailable")
            return true
        }
        return false
    }

    companion object {
        private val TAG = DiskCacheClient::class.java.simpleName
    }
}