import 'package:flutter_test/flutter_test.dart';
import 'package:soloud_package/main.dart';
import 'package:soloud_package/audio/audio_controller.dart';
import 'package:mockito/mockito.dart';

// Create a mock AudioController for testing
class MockAudioController extends Mock implements AudioController {
  @override
  Future<void> initialize() async {}

  @override
  void dispose() {}

  @override
  Future<void> playSound(String assetKey) async {}

  @override
  Future<void> startMusic() async {}

  @override
  void fadeOutMusic() {}

  @override
  void applyFilter() {}

  @override
  void removeFilter() {}
}

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Create a mock audio controller
    final mockAudioController = MockAudioController();

    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(audioController: mockAudioController));

    // Verify that our app renders correctly
    expect(find.text('Flutter SoLoud Demo'), findsOneWidget);
    expect(find.text('Play Sound'), findsOneWidget);
    expect(find.text('Start Music'), findsOneWidget);
    expect(find.text('Fade Out Music'), findsOneWidget);
    expect(find.text('Apply Filter'), findsOneWidget);
  });
}
