import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:next_audio_recorder/src/data/data_sources/audio_handler.dart';

class NextAudioRecorder {
  final AudioHandler _audioHandler = AudioHandler.instance;
  final double _subscriptionDuration = 100;
  bool _userHadSpeak = false;
  int _userHadSpeakIndex = 0;
  // 20 of _maxDelayIndex with _subscriptionDuration = 100 equal to 2 seconds of delay when user finished their speaking.
  final int maxDelayIndex = 20;
  // When user do talk something, this value will increase to _maxDelayIndex and then when it reached the _maxDelayIndex
  // it mean that user delay talking and we should switch to bot turn to think and speak
  int _delayIndex = 0;
  // When user talk something, with _userSpeakingLength = 3 and _subscriptionDuration = 100, it means that
  // we only recognize 300 milliseconds length of talking is a valid question, those shorter will be ignored.
  final int _userSpeakingLength = 3;

  /// Initiates subscriptions for recording audio and listens for changes.
  ///
  /// Parameters:
  /// - onValueChanged: Callback function triggered on recording disposition change.
  StreamSubscription<dynamic>? startRecorderSubscriptions(
    Function(RecordingDisposition) onValueChanged,
  ) {
    return _audioHandler.startRecorderSubscriptions(onValueChanged);
  }

  /// Cancels subscriptions for recording audio.
  void cancelRecorderSubscriptions() {
    _audioHandler.cancelRecorderSubscriptions();
  }

  /// Sets the duration delay in which the recorder subscription will wait to return a [RecordingDisposition] value.
  /// Smaller value result to a faster callback on onValueChanged in [startRecorderSubscriptions].
  ///
  /// Parameters:
  /// - duration: The duration (in milliseconds) for the audio recording subscription.
  Future<void> setSubscriptionDuration(double duration) async {
    if (!_audioHandler.isInitialized) {
      await AudioHandler.initialize();
    }
    await _audioHandler.setSubscriptionDuration(duration);
  }

  /// Starts the audio recording process and saves to the specified file path.
  ///
  /// Parameters:
  /// - targetFilePath: The file path where the recorded audio will be saved.
  Future<void> startRecorder(String targetFilePath) async {
    if (!_audioHandler.isInitialized) {
      await AudioHandler.initialize();
    }
    await _audioHandler.startRecorder(targetFilePath);
  }

  /// Initiates audio recording with automatic stop functionality based on predefined thresholds for silence duration and decibel levels.
  ///
  /// Parameters:
  /// - [silentDecibelThreshold]: Specifies the decibel threshold below which audio is considered silent.
  /// - [silentDurationSecond]: Defines the duration of silence in seconds that triggers automatic stoppage of the recording.
  /// - [targetFilePath]: Specifies the file path where the recorded audio will be saved.
  ///
  /// This function checks if the audio handler is initialized and initializes it if necessary.
  /// It then starts the audio recording process at the specified target file path.
  /// Subscription duration is set for the audio handler.
  /// The function continuously monitors the audio input, detecting periods of silence and user speech.
  /// If prolonged silence is detected, surpassing the specified duration threshold, the recording is automatically stopped.
  /// Upon stopping the recording, the function retrieves the output file path and provides debugging information if available.

  Future<void> startRecorderWithAutoStop(
      {required int silentDecibelThreshold,
      required int silentDurationSecond,
      required String targetFilePath,
      required Function(String) onFinished}) async {
    if (!_audioHandler.isInitialized) {
      await AudioHandler.initialize();
    }
    await _audioHandler.startRecorder(targetFilePath);
    await _audioHandler.setSubscriptionDuration(_subscriptionDuration);
    _audioHandler.startRecorderSubscriptions((e) async {
      debugPrint('[StartRecordEvent] Silent time: $_delayIndex');
      if (e.decibels! < silentDecibelThreshold && _userHadSpeak) {
        _delayIndex = _delayIndex + 1;
      } else {
        _delayIndex = 0;
      }
      if (e.decibels! > silentDecibelThreshold) {
        _userHadSpeakIndex = _userHadSpeakIndex + 1;
      }
      if (_userHadSpeakIndex > _userSpeakingLength) {
        _userHadSpeak = true;
      }
      if (_delayIndex >= silentDurationSecond * 10) {
        if (kDebugMode) {
          print('[StartRecordEvent] User stopped talking');
        }
        _audioHandler.cancelRecorderSubscriptions();
        String? outputFilePath = await _audioHandler.stopRecorder();
        if (outputFilePath != null) {
          _resetAutoStopValueToDefault();
          onFinished(outputFilePath);
          if (kDebugMode) {
            print(
              '[StartRecordEvent] Output recorded FilePath: $outputFilePath',
            );
          }
        } else {
          _resetAutoStopValueToDefault();
          if (kDebugMode) {
            print('[StartRecordEvent] No output file path found.');
          }
        }
      }
    });
  }

  void _resetAutoStopValueToDefault() {
    _delayIndex = 0;
    _userHadSpeakIndex = 0;
    _userHadSpeak = false;
  }

  /// Stops the audio recording and returns the file path of the recorded audio.
  ///
  /// Returns:
  /// - A [String] representing the file path of the recorded audio.
  Future<String?> stopRecorder() async {
    return await _audioHandler.stopRecorder();
  }

  /// Disposes of resources used for audio handling.
  void dispose() {
    _audioHandler.dispose();
  }
}
