package com.tencent.instacart.library.truetime

import android.content.Context
import android.os.SystemClock
import android.util.Log
import java.io.IOException
import java.util.*

class TrueTime {
    private var ntpHost = "1.us.pool.ntp.org"
    @Throws(IOException::class)
    fun initialize() {
        initialize(ntpHost)
    }

    @Throws(IOException::class)
    protected fun initialize(ntpHost: String?) {
        if (isInitialized) {
            Log.i(TAG, "---- TrueTime already initialized from previous boot/init")
            return
        }
        requestTime(ntpHost)
        saveTrueTimeInfoToDisk()
    }

    @Throws(IOException::class)
    fun requestTime(ntpHost: String?): LongArray {
        return SNTP_CLIENT.requestTime(
            ntpHost!!,
            _rootDelayMax,
            _rootDispersionMax,
            _serverResponseDelayMax,
            _udpSocketTimeoutInMillis
        )
    }

    fun cacheTrueTimeInfo(response: LongArray?) {
        SNTP_CLIENT.cacheTrueTimeInfo(response!!)
    }

    /**
     * Cache TrueTime initialization information in SharedPreferences
     * This can help avoid additional TrueTime initialization on app kills
     */
    @Synchronized
    fun withSharedPreferencesCache(context: Context?): TrueTime {
        DISK_CACHE_CLIENT.enableCacheInterface(SharedPreferenceCacheImpl(context!!))
        return INSTANCE
    }

    /**
     * Customized TrueTime Cache implementation.
     */
    @Synchronized
    fun withCustomizedCache(cacheInterface: CacheInterface?): TrueTime {
        DISK_CACHE_CLIENT.enableCacheInterface(cacheInterface)
        return INSTANCE
    }

    @Synchronized
    fun withConnectionTimeout(timeoutInMillis: Int): TrueTime {
        _udpSocketTimeoutInMillis = timeoutInMillis
        return INSTANCE
    }

    @Synchronized
    fun withRootDelayMax(rootDelayMax: Float): TrueTime {
        if (rootDelayMax > _rootDelayMax) {
            val log = String.format(
                Locale.getDefault(),
                "The recommended max rootDelay value is %f. You are setting it at %f",
                _rootDelayMax, rootDelayMax
            )
            Log.w(TAG, log)
        }
        _rootDelayMax = rootDelayMax
        return INSTANCE
    }

    @Synchronized
    fun withRootDispersionMax(rootDispersionMax: Float): TrueTime {
        if (rootDispersionMax > _rootDispersionMax) {
            val log = String.format(
                Locale.getDefault(),
                "The recommended max rootDispersion value is %f. You are setting it at %f",
                _rootDispersionMax, rootDispersionMax
            )
            Log.w(TAG, log)
        }
        _rootDispersionMax = rootDispersionMax
        return INSTANCE
    }

    @Synchronized
    fun withServerResponseDelayMax(serverResponseDelayInMillis: Int): TrueTime {
        _serverResponseDelayMax = serverResponseDelayInMillis
        return INSTANCE
    }

    @Synchronized
    fun withNtpHost(ntpHost: String): TrueTime {
        this.ntpHost = ntpHost
        return INSTANCE
    }

    @Synchronized
    fun withLoggingEnabled(isLoggingEnabled: Boolean): TrueTime {
        return INSTANCE
    }

    val isInitialized :Boolean = Companion.isInitialized


    companion object {
        private val TAG = TrueTime::class.java.simpleName
        private val INSTANCE = TrueTime()
        private val DISK_CACHE_CLIENT = DiskCacheClient()
        private val SNTP_CLIENT = SntpClient()
        private var _rootDelayMax = 100f
        private var _rootDispersionMax = 100f
        private var _serverResponseDelayMax = 750
        private var _udpSocketTimeoutInMillis = 30000

        /**
         * @return Date object that returns the current time in the default Timezone
         */
        @JvmStatic
        fun now(): Date {
            check(isInitialized) { "You need to call init() on TrueTime at least once." }
            val cachedSntpTime = cachedSntpTime
            val cachedDeviceUptime = cachedDeviceUptime
            val deviceUptime = SystemClock.elapsedRealtime()
            val now = cachedSntpTime + (deviceUptime - cachedDeviceUptime)
            return Date(now)
        }

        private val cachedDeviceUptime: Long
            private get() {
                val cachedDeviceUptime =
                    if (SNTP_CLIENT.wasInitialized()) SNTP_CLIENT.getCachedDeviceUptime() else DISK_CACHE_CLIENT.cachedDeviceUptime
                if (cachedDeviceUptime == 0L) {
                    throw RuntimeException("expected device time from last boot to be cached. couldn't find it.")
                }
                return cachedDeviceUptime
            }
        private val cachedSntpTime: Long
            private get() {
                val cachedSntpTime =
                    if (SNTP_CLIENT.wasInitialized()) SNTP_CLIENT.getCachedSntpTime() else DISK_CACHE_CLIENT.cachedSntpTime
                if (cachedSntpTime == 0L) {
                    throw RuntimeException("expected SNTP time from last boot to be cached. couldn't find it.")
                }
                return cachedSntpTime
            }
         val isInitialized: Boolean
            get() = SNTP_CLIENT.wasInitialized() || DISK_CACHE_CLIENT.isTrueTimeCachedFromAPreviousBoot

        @JvmStatic
        fun build(): TrueTime {
            return INSTANCE
        }

        /**
         * clear the cached TrueTime info on device reboot.
         */
        @JvmStatic
        fun clearCachedInfo() {
            DISK_CACHE_CLIENT.clearCachedInfo()
        }

        // -----------------------------------------------------------------------------------
        @Synchronized
        fun saveTrueTimeInfoToDisk() {
            if (!SNTP_CLIENT.wasInitialized()) {
                Log.i(TAG, "---- SNTP client not available. not caching TrueTime info in disk")
                return
            }
            DISK_CACHE_CLIENT.cacheTrueTimeInfo(SNTP_CLIENT)
        }
    }
}