package com.example.sigma_video_player

import com.sigma.drm.NativeHelper
import com.sigma.drm.SigmaHelper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** SigmaVideoPlayerPlugin */
class SigmaVideoPlayerPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sigma_video_player")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "getSigmaDeviceId" -> {
                try {
                    SigmaHelper.instance().init();
                    val macAddress = NativeHelper.getMacAddress();
                    val androidId = NativeHelper.getDeviceId();
                    val deviceId = if (macAddress.equals("02:00:00:00:00:00")) androidId else macAddress;

                    result.success(deviceId)
                } catch (e: Exception) {
                    result.error("SIGMA_ERROR", e.message, null)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
