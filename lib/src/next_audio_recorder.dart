import 'dart:async';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:next_audio_recorder/src/data/data_sources/audio_handler.dart';

class NextAudioRecorder {
  final AudioHandler _audioHandler = AudioHandler.instance;

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

  /// Stops the audio recording and returns the file path of the recorded audio.
  ///
  /// Returns:
  /// - A [String] representing the file path of the recorded audio.
  Future<String?> stopRecorder() async {
    return await _audioHandler.stopRecorder();
  }

  /// Starts playing audio from the provided URI and triggers a function on finish.
  ///
  /// Parameters:
  /// - fromURI: The URI or file path from where the audio playback will start.
  /// - onFinish: Callback function triggered upon completion of audio playback.
  void startPlayer(String fromURI, Function()? onFinish) async {
    if (!_audioHandler.isInitialized) {
      await AudioHandler.initialize();
    }
    _audioHandler.startPlayer(fromURI, onFinish);
  }

  /// Stops the audio player.
  void stopPlayer() {
    _audioHandler.stopPlayer();
  }

  /// Disposes of resources used for audio handling.
  void dispose() {
    _audioHandler.dispose();
  }
}
