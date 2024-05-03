import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:next_audio_recorder/src/common/constants/exception_strings.dart';
import 'package:next_audio_recorder/src/common/errors/exceptions.dart';

class AudioHandler {
  AudioHandler._privateConstructor();
  bool _isInitialized = false;
  static final AudioHandler instance = AudioHandler._privateConstructor();
  final FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  double subscriptionDuration = 300;
  StreamSubscription? _recorderSubscription;
  int pos = 0;
  double dbLevel = 0;
  final Codec _codec = Codec.aacMP4;
  static Future<void> initialize() async {
    if (!instance._isInitialized) {
      await instance._initializeRecorder();
    }
  }

  bool get isInitialized => _isInitialized;

  // Initializes the FlutterSoundRecorder and FlutterSoundPlayer
  Future<bool> _initializeRecorder() async {
    try {
      await _mRecorder.openRecorder();
      final session = await AudioSession.instance;
      await session.configure(
        AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.allowBluetooth |
                  AVAudioSessionCategoryOptions.defaultToSpeaker,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            flags: AndroidAudioFlags.none,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
          androidWillPauseWhenDucked: true,
        ),
      );
      _isInitialized = true;
      debugPrint('Audio initialized');
      return true;
    } catch (e) {
      throw AudioHandlerException('${ExceptionStrings.initializingRecorder}$e');
    }
  }

  /// Initiates subscriptions for recording audio and listens for changes.
  ///
  /// Parameters:
  /// - onValueChanged: Callback function triggered on recording disposition change.
  StreamSubscription<dynamic>? startRecorderSubscriptions(
      Function(RecordingDisposition) onValueChanged) {
    _recorderSubscription = _mRecorder.onProgress!.listen((e) {
      onValueChanged(e);
      pos = e.duration.inMilliseconds;
      if (e.decibels != null) {
        dbLevel = e.decibels as double;
      }
    });
    return _recorderSubscription;
  }

  /// Cancels subscriptions for recording audio.
  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
      debugPrint('Audio subscriptions is canceled');
    }
  }

  /// Sets the duration for the audio recording subscription.
  /// Smaller value result to a faster callback on onValueChanged in [startRecorderSubscriptions].
  ///
  /// Parameters:
  /// - d: The duration (in milliseconds) for the audio recording subscription.
  Future<void> setSubscriptionDuration(double d) async {
    subscriptionDuration = d;
    await _mRecorder.setSubscriptionDuration(
      Duration(milliseconds: d.floor()),
    );
  }

  /// Starts the audio recording process and saves to the specified file path.
  ///
  /// Parameters:
  /// - targetFilePath: The file path where the recorded audio will be saved.
  Future<void> startRecorder(String targetFilePath) async {
    try {
      await _mRecorder.startRecorder(
        toFile: targetFilePath,
        codec: _codec,
      );
      debugPrint('Recorder is started');
    } catch (e) {
      throw AudioHandlerException('${ExceptionStrings.startingRecorder}$e');
    }
  }

  /// Stops the audio recording and returns the file path of the recorded audio.
  ///
  /// Returns:
  /// A [String] representing the file path of the recorded audio.
  Future<String?> stopRecorder() async {
    try {
      debugPrint('Recorder is stopped');
      return await _mRecorder.stopRecorder();
    } catch (e) {
      throw AudioHandlerException('${ExceptionStrings.stoppingRecorder}$e');
    }
  }

  /// Disposes of resources used for audio handling.
  void dispose() {
    _isInitialized = false;
    try {
      _mRecorder.closeRecorder();
      //_mRecorder = null;

      cancelRecorderSubscriptions();
    } catch (e) {
      throw AudioHandlerException('${ExceptionStrings.disposing}$e');
    }
  }
}
