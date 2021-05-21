package com.tencent.instacart.library.truetime;

import android.content.Context;
import android.content.SharedPreferences;

import static android.content.Context.MODE_PRIVATE;

class SharedPreferenceCacheImpl implements CacheInterface {

    private static final String KEY_CACHED_SHARED_PREFS = "com.tencent.instacart.library.truetime.shared_preferences";

    private SharedPreferences sharedPreferences;

    public SharedPreferenceCacheImpl(Context context) {
        sharedPreferences = context.getSharedPreferences(KEY_CACHED_SHARED_PREFS, MODE_PRIVATE);
    }

    @Override
    public void put(String key, long value) {
        sharedPreferences.edit().putLong(key, value).apply();
    }

    @Override
    public long get(String key, long defaultValue) {
        return sharedPreferences.getLong(key, defaultValue);
    }

    @Override
    public void clear() {
        remove(CacheInterface.KEY_CACHED_BOOT_TIME);
        remove(CacheInterface.KEY_CACHED_DEVICE_UPTIME);
        remove(CacheInterface.KEY_CACHED_SNTP_TIME);
    }

    private void remove(String keyCachedBootTime) {
        sharedPreferences.edit().remove(keyCachedBootTime).apply();
    }
}