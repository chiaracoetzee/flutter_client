// Fork: tests the fork adds, kept out of upstream's embed_animated_image_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/media/animated_image_playback_controller.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/media/embed_animated_image.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/media/fluxer_animated_image.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'embed_animated_image_test.dart' hide main;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmbedAnimatedImage', () {
    setUp(() {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
    });

    tearDown(() {
      VisibilityDetectorController.instance.updateInterval = const Duration(
        milliseconds: 500,
      );
    });

    testWidgets('keeps playing when its subtree is rebuilt under a new key', (
      tester,
    ) async {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController(
            maxActiveVideos: kMaxActiveChatAnimatedImages,
          );
      addTearDown(controller.dispose);

      Widget build(int epoch) {
        return forkUpstream.wrap(
          AnimatedImagePlaybackScope(
            controller: controller,
            child: KeyedSubtree(
              key: ValueKey<int>(epoch),
              child: const SizedBox(
                height: 200,
                child: EmbedAnimatedImage(
                  animatedUrl: 'https://x/a.webp',
                  staticUrl: 'https://x/a.png',
                ),
              ),
            ),
          ),
        );
      }

      bool playing() => tester
          .widget<FluxerAnimatedImage>(find.byType(FluxerAnimatedImage))
          .playing;

      await tester.pumpWidget(build(0));
      await tester.pump();
      await tester.pump();
      expect(playing(), isTrue);

      // The replacement state mounts before the old one is disposed.
      await tester.pumpWidget(build(1));
      await tester.pump();
      await tester.pump();
      expect(playing(), isTrue);
    });
  });
}
