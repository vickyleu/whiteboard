package com.tencent.tic.core.impl

class UserInfo {
    var userId = ""
        private set
    var userSig = ""
        private set

    constructor() {}
    constructor(userId: String, userSig: String) {
        this.userId = userId
        this.userSig = userSig
    }

    fun setUserInfo(userId: String, userSig: String) {
        this.userId = userId
        this.userSig = userSig
    }
}