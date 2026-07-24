import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Under plain `flutter test` there's no real platform to answer
/// `SystemSound.play` / `HapticFeedback.*` calls, and unlike a real device
/// (which reports "no handler" immediately), the test binary messenger
/// leaves the call's Future pending forever — hanging any test that awaits
/// it. Stub the channel so those calls resolve immediately.
void mockSystemChannels() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
}

/// Same problem for `FlutterCompass.events` (Qibla screen): its EventChannel
/// has no real platform handler under `flutter test`, so the 'listen' call
/// it sends on first subscription hangs forever without this. Stubbing it to
/// answer immediately (with no further events) is enough — screens render
/// their "waiting for a reading" state, which is all these tests check.
void mockCompassChannel() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('hemanthraj/flutter_compass'),
        (call) async => null,
      );
}
