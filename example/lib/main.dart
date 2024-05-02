import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:next_audio_recoder/next_audio_recoder.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next Audio Recoder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _nextAudioRecorder = NextAudioRecorder();
  // This value control the refresh time of audio subscription
  final double _subscriptionDuration = 100;

  startRecording() async {
    bool recordPermission = await _requestPermission();
    if (recordPermission) {
      await _nextAudioRecorder.startRecorder('output.mp4');
      await _nextAudioRecorder.setSubscriptionDuration(_subscriptionDuration);
      _nextAudioRecorder.startRecorderSubscriptions((e) async {
        // You can use this to trigger function or listen for special task like: detect user stop talking.
      });
    } else {
      if (kDebugMode) {
        print('Audio permission is required.');
      }
    }
  }

  stopRecorder() async {
    if (kDebugMode) {
      print('[StartRecordEvent] Stopping recorder');
    }
    _nextAudioRecorder.cancelRecorderSubscriptions();
    String? outputFilePath = await _nextAudioRecorder.stopRecorder();
    if (outputFilePath != null) {
      if (kDebugMode) {
        print(
          '[StartRecordEvent] Output recorded FilePath: $outputFilePath',
        );
      }
    } else {
      if (kDebugMode) {
        print('[StartRecordEvent] No output file path found.');
      }
    }
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Audio Recoder'),
      ),
      body: Center(
        child: Column(children: [
          const SizedBox(
            height: 50,
          ),
          FilledButton(
            onPressed: startRecording,
            child: const Text('Start recording'),
          ),
          FilledButton(
            onPressed: stopRecorder,
            child: const Text('Stop recording'),
          ),
          const Spacer(),
          const Text('Zeroboy'),
          const SizedBox(
            height: 50,
          ),
        ]),
      ),
    );
  }
}
