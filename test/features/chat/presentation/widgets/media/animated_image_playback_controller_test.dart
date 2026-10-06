// Cascade invocations are intentional in these tests.
// ignore_for_file: cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/media/animated_image_playback_controller.dart';

extension _ControllerExpects on AnimatedImagePlaybackController {
  void expectPlaying(String key, Matcher matcher) {
    expect(isPlaying(key), matcher);
  }
}

void main() {
  group('AnimatedImagePlaybackController', () {
    test('plays every visible image when no cap is set', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();

      for (int index = 0; index < 8; index += 1) {
        controller.register('gif-$index', 1);
      }

      for (int index = 0; index < 8; index += 1) {
        controller.expectPlaying('gif-$index', isTrue);
      }
    });

    test('activates visible images up to the configured cap', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController(maxActiveVideos: 6);

      for (int index = 0; index < 8; index += 1) {
        controller.register('gif-$index', 1);
      }

      final int playing = <int>[
        for (int index = 0; index < 8; index += 1) index,
      ].where((int index) => controller.isPlaying('gif-$index')).length;
      expect(playing, 6);
    });

    test('chat list plays at most 4 animated images at once', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController(
            maxActiveVideos: kMaxActiveChatAnimatedImages,
            suppressWhileScrolling: true,
          );

      for (int index = 0; index < 5; index += 1) {
        controller.register('gif-$index', 1);
      }

      controller
        ..expectPlaying('gif-1', isTrue)
        ..expectPlaying('gif-2', isTrue)
        ..expectPlaying('gif-3', isTrue)
        ..expectPlaying('gif-4', isTrue)
        ..expectPlaying('gif-0', isFalse)
        ..unregister('gif-4')
        ..expectPlaying('gif-0', isTrue);
    });

    test('over the cap, the most visible animated images play', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController(maxActiveVideos: 3);

      controller
        ..register('edge', 0.2)
        ..register('a', 1)
        ..register('b', 1)
        ..register('c', 1)
        ..expectPlaying('a', isTrue)
        ..expectPlaying('b', isTrue)
        ..expectPlaying('c', isTrue)
        ..expectPlaying('edge', isFalse);
    });

    test('a newly scrolled-in fully visible image wins a tie over the earliest '
        'mounted one', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController(maxActiveVideos: 3);

      controller
        ..register('a', 1)
        ..register('b', 1)
        ..register('c', 1)
        ..register('d', 0)
        ..updateVisibility('d', 1)
        ..expectPlaying('d', isTrue)
        ..expectPlaying('c', isTrue)
        ..expectPlaying('b', isTrue)
        ..expectPlaying('a', isFalse);
    });

    test('an image scrolling out of view yields its slot by fraction', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController(maxActiveVideos: 1);

      controller
        ..register('a', 1)
        ..register('b', 1)
        ..expectPlaying('b', isTrue)
        ..updateVisibility('b', 0.3)
        ..expectPlaying('a', isTrue)
        ..expectPlaying('b', isFalse);
    });

    test('does not activate images with zero visibility', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();

      controller
        ..register('a', 0.5)
        ..register('b', 0)
        ..expectPlaying('a', isTrue)
        ..expectPlaying('b', isFalse);
    });

    test('stops playback when an image unregisters', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();

      controller
        ..register('a', 1)
        ..register('b', 1)
        ..expectPlaying('a', isTrue)
        ..unregister('a')
        ..expectPlaying('a', isFalse)
        ..expectPlaying('b', isTrue);
    });

    test('keeps visible images playing while scrolling', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();

      controller
        ..register('a', 1)
        ..register('b', 1)
        ..expectPlaying('a', isTrue)
        ..setScrollActive(active: true)
        ..expectPlaying('a', isTrue)
        ..expectPlaying('b', isTrue)
        ..updateVisibility('b', 0)
        ..expectPlaying('b', isFalse)
        ..expectPlaying('a', isTrue);
    });

    test('can suppress playback while scrolling when enabled', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController(suppressWhileScrolling: true);

      controller
        ..register('a', 1)
        ..register('b', 1)
        ..expectPlaying('a', isTrue)
        ..setScrollActive(active: true)
        ..expectPlaying('a', isFalse)
        ..expectPlaying('b', isFalse)
        ..setScrollActive(active: false)
        ..expectPlaying('a', isTrue)
        ..expectPlaying('b', isTrue);
    });

    test('notifies listeners when active set changes', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();
      int notificationCount = 0;
      controller.addListener(() => notificationCount++);

      controller
        ..register('a', 1)
        ..expectPlaying('a', isTrue);
      expect(notificationCount, 1);

      controller
        ..updateVisibility('a', 0)
        ..expectPlaying('a', isFalse);
      expect(notificationCount, 2);

      controller
        ..updateVisibility('a', 1)
        ..expectPlaying('a', isTrue);
      expect(notificationCount, 3);
    });

    test('does not notify when scroll-active is set to the same value', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();
      int notificationCount = 0;
      controller.addListener(() => notificationCount++);

      controller
        ..register('a', 1)
        ..setScrollActive(active: true)
        ..setScrollActive(active: true);
      expect(notificationCount, 1);
    });

    test('does not recompute when register values are unchanged', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();
      int notificationCount = 0;
      controller.addListener(() => notificationCount++);

      controller
        ..register('a', 1)
        ..register('a', 1);
      expect(notificationCount, 1);
    });

    test('does not notify listeners when state is unchanged', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();
      int notificationCount = 0;
      controller.addListener(() => notificationCount++);

      controller
        ..register('a', 1)
        ..expectPlaying('a', isTrue);
      expect(notificationCount, 1);

      controller
        ..updateVisibility('a', 1)
        ..expectPlaying('a', isTrue);
      expect(notificationCount, 1);
    });

    test('a stale owner cannot unregister its replacement', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();
      final Object oldOwner = Object();
      final Object newOwner = Object();

      controller
        ..register('a', 1, owner: oldOwner)
        ..register('a', 0, owner: newOwner)
        ..unregister('a', owner: oldOwner)
        ..expectPlaying('a', isTrue)
        ..updateVisibility('a', 0, owner: newOwner)
        ..expectPlaying('a', isFalse)
        ..updateVisibility('a', 1, owner: newOwner)
        ..expectPlaying('a', isTrue)
        ..unregister('a', owner: newOwner)
        ..expectPlaying('a', isFalse);
    });

    test('a stale owner cannot change its replacement visibility', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();
      final Object oldOwner = Object();
      final Object newOwner = Object();

      controller
        ..register('a', 1, owner: oldOwner)
        ..register('a', 1, owner: newOwner)
        ..updateVisibility('a', 0, owner: oldOwner)
        ..expectPlaying('a', isTrue);
    });

    test('a takeover does not notify listeners', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();
      int notificationCount = 0;
      controller
        ..register('a', 1, owner: Object())
        ..addListener(() => notificationCount++)
        ..register('a', 0, owner: Object());
      expect(notificationCount, 0);
    });

    test('an owned visibility update restores a missing entry', () {
      final AnimatedImagePlaybackController controller =
          AnimatedImagePlaybackController();
      final Object owner = Object();

      controller
        ..register('a', 1, owner: owner)
        ..unregister('a')
        ..expectPlaying('a', isFalse)
        ..updateVisibility('a', 1, owner: owner)
        ..expectPlaying('a', isTrue);
    });
  });
}
