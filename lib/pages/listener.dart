
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import '../utils/permission_utils.dart';

class ListenerScreen extends StatefulWidget {
  const ListenerScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _ListenerState();
  }
}

class _ListenerState extends State<ListenerScreen> {
  late stt.SpeechToText _speech;
  Timer? _timer;
  bool _isListening = false;
  String _text = "等待...";
  Color _buttonColor = Colors.grey;

  @override
  void initState(){
    super.initState();
    initSpeechRecognizer();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void initSpeechRecognizer() async {
    bool hasPermission = await PermissionUtils.checkAndRequestMicrophonePermission(context);
    if (hasPermission) {
      // 初始化语音识别器
      log("麦克风权限已授予");
    } else {
      log("没有麦克风权限");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('语音转文字'),),
      body: Center(
        child: Text(_text),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleListening,
        backgroundColor: _buttonColor,
        child: Icon(Icons.mic),
      ),
    );
  }

  void _toggleListening() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _buttonColor = Colors.grey;
      });
      await _speech.stop();
    } else {
      bool available = await _speech.initialize().then((val){
        log("init result = $val");
        return val;
      }).catchError((err){
        log("init error msg = $err");
        return false;
      });
      log("message $available");
      if (available) {
        setState(() {
          _isListening = true;
          _buttonColor = Colors.green;
          startBlinking();
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
        );
      }
    }
  }

  void startBlinking() {
    int _timerInterval = 500; // 半秒切换一次颜色
    _timer?.cancel(); // 取消之前的定时器以防多次点击
    _timer = Timer.periodic(Duration(milliseconds: _timerInterval), (timer) {
      setState(() {
        _buttonColor = (_buttonColor == Colors.green ? Colors.green[200] : Colors.green)!;
      });
    });
  }

}