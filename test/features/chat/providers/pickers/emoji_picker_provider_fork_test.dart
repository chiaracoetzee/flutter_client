// Fork: tests the fork adds, kept out of upstream's emoji_picker_provider_test.dart so that file stays as
// upstream has it.
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxer_app/features/chat/providers/pickers/emoji_picker_provider.dart';
import 'package:fluxer_app/features/guilds/domain/guild.dart';
import 'package:fluxer_app/shared/utils/emoji_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await EmojiRegistry.preload();
  });

  group('guildEmojiEntriesForPicker', () {
    const guilds = <Guild>[
      Guild(id: '1', name: 'One'),
      Guild(id: '2', name: 'Two'),
    ];

    test(
      'sorts guild emoji entries alphabetically by name case-insensitively',
      () {
        final unsortedEmojis = <GuildEmojiEntry>[
          GuildEmojiEntry(
            id: '1',
            name: 'zebra',
            animated: false,
            guildId: '1',
          ),
          GuildEmojiEntry(
            id: '2',
            name: 'Apple',
            animated: false,
            guildId: '1',
          ),
          GuildEmojiEntry(
            id: '3',
            name: 'banana',
            animated: false,
            guildId: '1',
          ),
        ];
        final result = guildEmojiEntriesForPicker(
          guilds: guilds,
          emojis: unsortedEmojis,
          activeGuildId: '1',
          isPremium: false,
        );

        expect(result[guilds.first]!.map((emoji) => emoji.name), [
          'Apple',
          'banana',
          'zebra',
        ]);
      },
    );
  });
}
