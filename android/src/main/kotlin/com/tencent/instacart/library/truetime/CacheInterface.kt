package com.tencent.instacart.library.truetime

interface CacheInterface {
    fun put(key: String?, value: Long)
    operator fun get(key: String?, defaultValue: Long): Long
    fun clear()

    companion object {
        const val KEY_CACHED_BOOT_TIME = "com.tencent.instacart.library.truetime.cached_boot_time"
        const val KEY_CACHED_DEVICE_UPTIME =
            "com.tencent.instacart.library.truetime.cached_device_uptime"
        const val KEY_CACHED_SNTP_TIME = "com.tencent.instacart.library.truetime.cached_sntp_time"
    }
}