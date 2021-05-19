package com.bond.whiteboard

import androidx.annotation.NonNull
import com.bond.whiteboard.nativeView.WhiteboardViewFactory
import com.pigeon.PigeonPlatformMessage
import com.pigeon.PigeonPlatformMessage.PigeonApi.setup
import com.tencent.teduboard.TEduBoardController.TEduBoardColor
import com.tencent.teduboard.TEduBoardController.TEduBoardInitParam
import com.tencent.tic.core.TICClassroomOption
import com.tencent.tic.core.TICManager.TICCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


/** WhiteboardPlugin */
class WhiteboardPlugin: FlutterPlugin,ActivityAware {
  private var awareManager = AwareManager()
  private var boardFactory = WhiteboardViewFactory()

  private var activityAware:ActivityPluginBinding?=null

  private val api = object :PigeonPlatformMessage.PigeonApi{
    override fun init(arg: PigeonPlatformMessage.InitRequest?): PigeonPlatformMessage.DataModel {
      val context = activityAware?.activity?.application?.applicationContext
      return if(context!=null&&arg!=null){
        awareManager.init(context,arg.appID.toInt())
        PigeonPlatformMessage.DataModel().apply {
          this.code=1
          this.msg="初始化成功"
        }
      }else{
        PigeonPlatformMessage.DataModel().apply {
          this.code=-1
          this.msg="初始化不成功"
        }
      }
    }
    override fun login(arg: PigeonPlatformMessage.LoginRequest?, result: PigeonPlatformMessage.Result<PigeonPlatformMessage.DataModel>?) {
      if(arg!=null){
        awareManager.login(arg.userID,arg.userSig, object : TICCallback<Any?> {
          override fun onError(module: String, errCode: Int, errMsg: String) {
            result?.success(PigeonPlatformMessage.DataModel().apply {
              this.code=-1
              this.msg="${arg.userID}:登录失败,$errMsg"
            })
          }
          override fun onSuccess(data: Any?) {
            result?.success(PigeonPlatformMessage.DataModel().apply {
              this.code=1
              this.msg="${arg.userID}:登录成功"
            })
          }
        })
      }else{
        result?.success(PigeonPlatformMessage.DataModel().apply {
          this.code=-1
          this.msg="登录失败:参数错误"
        })
      }
    }

    override fun joinClass(arg: PigeonPlatformMessage.JoinClassRequest?, result: PigeonPlatformMessage.Result<PigeonPlatformMessage.DataModel>?) {
      if(arg!=null){
        //2、如果用户希望白板显示出来时，不使用系统默认的参数，就需要设置特性缺省参数，如是使用默认参数，则填null。
        val initParam = TEduBoardInitParam()
        initParam.brushColor = TEduBoardColor(255, 0, 0, 255)
        initParam.smoothLevel = 0f //用于指定笔迹平滑级别，默认值0.1，取值[0, 1]
        val classroomOption = TICClassroomOption()
        classroomOption.classId = arg.roomId.toInt()
        classroomOption.boardInitPara = initParam
        awareManager.joinClassroom(classroomOption, object : TICCallback<Any?> {
          override fun onSuccess(data: Any?) {
            result?.success(PigeonPlatformMessage.DataModel().apply {
              this.code= 1
              this.msg="进入课堂成功:${arg.roomId.toInt()}"
            })
          }
          override fun onError(module: String, errCode: Int, errMsg: String) {
            if (errCode == 10015) {
              result?.success(PigeonPlatformMessage.DataModel().apply {
                this.code= errCode.toLong()
                this.msg="课堂不存在:${arg.roomId.toInt()},$errMsg"
              })
            } else {
              result?.success(PigeonPlatformMessage.DataModel().apply {
                this.code= errCode.toLong()
                this.msg="进入课堂失败:${arg.roomId.toInt()},$errMsg"
              })
            }
          }
        })
      }else{
        result?.success(PigeonPlatformMessage.DataModel().apply {
          this.code= -1
          this.msg="进入课堂失败:参数有误"
        })
      }
    }

    override fun quitClass(result: PigeonPlatformMessage.Result<PigeonPlatformMessage.DataModel>?) {
      //如果是老师，可以清除；
      //如查是学生一般是不要清除数据
      awareManager.quitClassroom(true, object : TICCallback<Any?> {
        override fun onError(module: String, errCode: Int, errMsg: String) {
          result?.success(PigeonPlatformMessage.DataModel().apply {
            this.code= -1
            this.msg="退出课堂失败,$errMsg"
          })
        }
        override fun onSuccess(data: Any?) {
          result?.success(PigeonPlatformMessage.DataModel().apply {
            this.code= 1
            this.msg="退出课堂成功"
          })
        }
      })
    }
  }


  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    setup(binding.binaryMessenger,api)
    binding.platformViewRegistry.registerViewFactory("plugins.whiteboard/_001", boardFactory)
    val flutterApi =PigeonPlatformMessage.PigeonFlutterApi(binding.binaryMessenger)
    awareManager.flutterApi=flutterApi
    awareManager.nativeViewLink=boardFactory
  }



  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    setup(binding.binaryMessenger, null)
    awareManager.flutterApi=null
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityAware=binding
  }

  override fun onDetachedFromActivity() {
    activityAware=null
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }



}
