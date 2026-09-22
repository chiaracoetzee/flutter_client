// Fork: tests the fork adds, kept out of upstream's composer_voice_button_visibility_test.dart so that file stays as
// upstream has it.
import 'package:fluxer_app/features/chat/utils/composer/composer_voice_button_visibility.dart';
import 'package:test/test.dart';

const ({bool hasSendable, bool isEditing, bool showMessageSendButtonPreference})
_emptyComposer = (
  hasSendable: false,
  isEditing: false,
  showMessageSendButtonPreference: false,
);

void main() {
  test('shows quick switcher when preference enabled and composer empty', () {
    expect(
      shouldShowComposerQuickSwitcherButton(
        showQuickSwitcherButtonPreference: true,
        hasSendable: _emptyComposer.hasSendable,
        isEditing: _emptyComposer.isEditing,
        showMessageSendButtonPreference:
            _emptyComposer.showMessageSendButtonPreference,
      ),
      isTrue,
    );
  });

  test('hides quick switcher when preference disabled', () {
    expect(
      shouldShowComposerQuickSwitcherButton(
        showQuickSwitcherButtonPreference: false,
        hasSendable: _emptyComposer.hasSendable,
        isEditing: _emptyComposer.isEditing,
        showMessageSendButtonPreference:
            _emptyComposer.showMessageSendButtonPreference,
      ),
      isFalse,
    );
  });

  test('hides quick switcher when composer has sendable content', () {
    expect(
      shouldShowComposerQuickSwitcherButton(
        showQuickSwitcherButtonPreference: true,
        hasSendable: true,
        isEditing: false,
        showMessageSendButtonPreference: false,
      ),
      isFalse,
    );
  });

  test('hides quick switcher when editing', () {
    expect(
      shouldShowComposerQuickSwitcherButton(
        showQuickSwitcherButtonPreference: true,
        hasSendable: false,
        isEditing: true,
        showMessageSendButtonPreference: false,
      ),
      isFalse,
    );
  });
}
