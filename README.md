Here's a README.md file for your Next Audio Recorder Package:

```markdown
# Next Audio Recorder Package

Next Audio Recorder is a Flutter package for recording audio with additional features like setting subscription duration.

## Features

- Record audio in Flutter apps.
- Set subscription duration for recording.

## Getting Started

To use this package, add `next_audio_recorder` as a dependency in your `pubspec.yaml` file.

### Permissions

Before starting recording, make sure to add audio permissions to your AndroidManifest.xml file and request permission using the PermissionHandler package.

Add the following permissions to your AndroidManifest.xml file:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

Request audio permission using PermissionHandler package:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> _requestPermission() async {
  var status = await Permission.microphone.request();
  if (status != PermissionStatus.granted) {
    return false;
  }
  return true;
}
```

### Example Usage

#### Start Recording

```dart
startRecording() async {
  bool recordPermission = await _requestPermission();
  if (recordPermission) {
    await _nextAudioRecorder.startRecorder('output.mp4');
    await _nextAudioRecorder.setSubscriptionDuration(_subscriptionDuration);
    _nextAudioRecorder.startRecorderSubscriptions((e) async {
      // You can use this to trigger function or listen for special tasks like detecting when the user stops talking.
    });
  } else {
    if (kDebugMode) {
      print('Audio permission is required.');
    }
  }
}
```

#### Stop Recording

```dart
stopRecorder() async {
  if (kDebugMode) {
    print('[StartRecordEvent] Stopping recorder');
  }
  _nextAudioRecorder.cancelRecorderSubscriptions();
  String? outputFilePath = await _nextAudioRecorder.stopRecorder();
  if (outputFilePath != null) {
    if (kDebugMode) {
      print('[StartRecordEvent] Output recorded FilePath: $outputFilePath');
    }
  } else {
    if (kDebugMode) {
      print('[StartRecordEvent] No output file path found.');
    }
  }
}
```

Feel free to explore more methods and functionalities provided by Next Audio Recorder in the official documentation.

## Issues and Contributions

If you encounter any issues or have suggestions for improvements, feel free to open an issue on the GitHub repository.

We welcome contributions from the community. If you'd like to contribute, please fork the repository, make your changes, and submit a pull request.

## License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

Feel free to adjust the README.md according to your package's specific details and requirements.