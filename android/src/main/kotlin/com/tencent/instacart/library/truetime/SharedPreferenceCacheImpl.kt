package com.tencent.instacart.library.truetime

import android.content.Context
import android.content.SharedPreferences

internal class SharedPreferenceCacheImpl(context: Context) : CacheInterface {
    private val sharedPreferences = context.getSharedPreferences(KEY_CACHED_SHARED_PREFS, Context.MODE_PRIVATE)

    override fun put(key: String?, value: Long) {
        sharedPreferences.edit().putLong(key, value).apply()
    }

    override fun get(key: String?, defaultValue: Long): Long {
        return sharedPreferences.getLong(key, defaultValue)
    }

    override fun clear() {
        remove(CacheInterface.KEY_CACHED_BOOT_TIME)
        remove(CacheInterface.KEY_CACHED_DEVICE_UPTIME)
        remove(CacheInterface.KEY_CACHED_SNTP_TIME)
    }

    private fun remove(keyCachedBootTime: String) {
        sharedPreferences.edit().remove(keyCachedBootTime).apply()
    }

    companion object {
        private const val KEY_CACHED_SHARED_PREFS =
            "com.tencent.instacart.library.truetime.shared_preferences"
    }

}