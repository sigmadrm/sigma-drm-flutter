import Flutter
import UIKit

public class SigmaVideoPlayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sigma_video_player", binaryMessenger: registrar.messenger())
    let instance = SigmaVideoPlayerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getSigmaDeviceId":
      // Comming soon
      result("ios_device_id_placeholder")
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
