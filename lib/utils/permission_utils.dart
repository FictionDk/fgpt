import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  // 检查并请求麦克风权限
  static Future<bool> checkAndRequestMicrophonePermission(BuildContext context) async {
    var status = await Permission.microphone.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      // 如果权限被拒绝或永久拒绝，则显示对话框解释为什么需要这个权限，并引导用户去设置页面开启权限。
      if (await _showPermissionExplanationDialog(context)) {
        openAppSettings();
      }
      return false;
    } else if (status.isGranted) {
      return true;
    } else if (status.isLimited) { // iOS only, but safe to include for cross-platform compatibility
      return true; // Assuming limited access is enough for basic functionality.
    }

    // 请求权限
    var result = await Permission.microphone.request();

    if (result.isGranted) {
      return true;
    } else {
      _showPermissionDeniedDialog(context);
      return false;
    }
  }

  // 显示解释为什么需要麦克风权限的对话框
  static Future<bool> _showPermissionExplanationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("麦克风权限请求"),
        content: Text("我们需要访问您的麦克风以进行语音识别。请在设置中允许此权限。"),
        actions: <Widget>[
          TextButton(
            child: Text("取消"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text("去设置"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    ) ??
        false;
  }

  // 显示权限被拒绝的通知对话框
  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("权限被拒绝"),
        content: Text("无法访问麦克风，因此无法使用语音识别功能。"),
        actions: <Widget>[
          TextButton(
            child: Text("确定"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}