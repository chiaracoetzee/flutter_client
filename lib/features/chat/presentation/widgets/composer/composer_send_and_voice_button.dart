import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/voice_message_recorder.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/voice_message_recording_bar.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/voice_message_recording_controller.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/wide_composer_layout.dart';
import 'package:fluxer_app/features/chat/providers/channel/channel_message_permissions_provider.dart';
import 'package:fluxer_app/features/chat/providers/core/chat_view_model.dart';
import 'package:fluxer_app/features/chat/providers/slowmode/slowmode_blocked_provider.dart';
import 'package:fluxer_app/features/chat/utils/composer/composer_voice_button_visibility.dart';
import 'package:fluxer_app/features/quick_switcher/presentation/sheets/quick_switcher_bottom_sheet.dart';
import 'package:fluxer_app/features/settings/providers/advanced_preferences_provider.dart';
import 'package:fluxer_app/features/settings/providers/quick_switcher_button_preferences_provider.dart';
import 'package:fluxer_app/features/ui/ui.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/providers/input_modality_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

const double _kDisabledOpacity = 0.6;
const double _kWideActionExtent = WideComposerLayout.actionButtonExtent;
const Duration _kPostSendCooldown = Duration(milliseconds: 600);

class ComposerSendAndVoiceButton extends ConsumerStatefulWidget {
  const ComposerSendAndVoiceButton({
    required this.perms,
    required this.hasSendable,
    required this.isOverCharacterLimit,
    required this.useHoldToRecord,
    required this.voiceRecording,
    required this.onSend,
    required this.onNoSendPermission,
    this.size = FluxerButtonSize.compact,
    super.key,
  });

  final ChannelMessagePermissions perms;
  final bool hasSendable;
  final bool isOverCharacterLimit;
  final bool useHoldToRecord;
  final VoiceMessageRecordingController voiceRecording;
  final VoidCallback onSend;
  final VoidCallback onNoSendPermission;
  final FluxerButtonSize size;

  @override
  ConsumerState<ComposerSendAndVoiceButton> createState() =>
      _ComposerSendAndVoiceButtonState();
}

class _ComposerSendAndVoiceButtonState
    extends ConsumerState<ComposerSendAndVoiceButton> {
  Timer? _cooldownTimer;
  bool _cooldownActive = false;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _handleSend() {
    widget.onSend();
    _startCooldown();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() {
      _cooldownActive = true;
    });
    _cooldownTimer = Timer(_kPostSendCooldown, () {
      if (mounted) {
        setState(() {
          _cooldownActive = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String channelId = ref.watch(
      chatViewModelProvider.select((s) => s.channelId),
    );
    final bool isEditing = ref.watch(
      chatViewModelProvider.select((s) => s.editingMessage != null),
    );
    final bool isSlowmodeBlocked =
        !isEditing &&
        ref.watch(
          isSlowmodeBlockedProvider(
            channelId,
          ).select((AsyncValue<bool> value) => value.value ?? false),
        );
    final bool canUseVoice = widget.perms.isVoiceEnabled && !isSlowmodeBlocked;
    final bool touchActions = isTouchPrimaryInput(ref);
    final bool showSendButtonPreference = ref.watch(
      advancedPreferencesProvider.select(
        (state) => state.showMessageSendButton,
      ),
    );
    final bool showQuickSwitcherPreference = ref.watch(
      quickSwitcherButtonPreferencesProvider,
    );
    final bool showQuickSwitcherButton = shouldShowComposerQuickSwitcherButton(
      showQuickSwitcherButtonPreference: showQuickSwitcherPreference,
      hasSendable: widget.hasSendable,
      isEditing: isEditing,
      showMessageSendButtonPreference: showSendButtonPreference,
      isTouchPrimary: touchActions,
    );
    final bool showVoiceButton = !showQuickSwitcherPreference &&
        shouldShowComposerVoiceButton(
          permissions: widget.perms,
          hasSendable: widget.hasSendable,
          isEditing: isEditing,
          showMessageSendButtonPreference: showSendButtonPreference,
          isTouchPrimary: touchActions,
        );
    final bool isCooldown = _cooldownActive && !widget.hasSendable;
    final bool showSendButton =
        widget.hasSendable ||
        _cooldownActive ||
        (!touchActions && showSendButtonPreference) ||
        (!showQuickSwitcherPreference &&
            shouldShowComposerSendButtonFallback(
              permissions: widget.perms,
              hasSendable: widget.hasSendable,
              isEditing: isEditing,
              showMessageSendButtonPreference: showSendButtonPreference,
              isTouchPrimary: touchActions,
            ));
    final bool voiceDisabled =
        !canUseVoice ||
        !widget.perms.isComposerEnabled ||
        widget.isOverCharacterLimit;
    final VoidCallback? sendOnPressed = isCooldown ||
            !widget.hasSendable ||
            widget.isOverCharacterLimit
        ? null
        : widget.perms.isComposerEnabled
        ? _handleSend
        : widget.onNoSendPermission;
    final bool sendVisuallyEnabled =
        widget.perms.isComposerEnabled &&
        sendOnPressed != null &&
        !isSlowmodeBlocked;
    final bool voiceVisuallyEnabled = !voiceDisabled;
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final FluxerButtonSize voiceSize = widget.useHoldToRecord
        ? widget.size
        : (touchActions ? FluxerButtonSize.small : FluxerButtonSize.compact);
    Widget wrapWideAction(Widget child) {
      if (widget.useHoldToRecord || touchActions) {
        return child;
      }
      return SizedBox(
        width: _kWideActionExtent,
        height: _kWideActionExtent,
        child: child,
      );
    }

    if (widget.voiceRecording.isActive) {
      if (widget.voiceRecording.isLocked) {
        return wrapWideAction(
          VoiceMessageRecordingSendButton(
            key: const ValueKey<String>('voice-send'),
            controller: widget.voiceRecording,
            size: voiceSize,
          ),
        );
      }
      return wrapWideAction(
        VoiceMessageRecorder(
          key: const ValueKey<String>('voice'),
          channelId: channelId,
          disabled: voiceDisabled,
          controller: widget.voiceRecording,
          holdToRecord: widget.useHoldToRecord,
          buttonSize: voiceSize,
        ),
      );
    }
    final Widget voiceMic = _opacity(
      context: context,
      key: const ValueKey<String>('voice'),
      enabled: voiceVisuallyEnabled,
      child: VoiceMessageRecorder(
        channelId: channelId,
        disabled: voiceDisabled,
        controller: widget.voiceRecording,
        holdToRecord: widget.useHoldToRecord,
        buttonSize: voiceSize,
      ),
    );

    final Widget quickSwitcherButton = FluxerButton.circleAlt(
      key: const ValueKey<String>('quick-switcher'),
      icon: PhosphorIconsBold.lightning,
      size: widget.useHoldToRecord ? widget.size : FluxerButtonSize.small,
      semanticLabel: l10n.quickSwitcherTabSearch,
      onPressed: () => unawaited(QuickSwitcherBottomSheet.show(context, ref)),
    );

    if (!widget.useHoldToRecord) {
      if (touchActions) {
        return AnimatedSwitcher(
          duration: context.motion.panel,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(opacity: animation, child: child),
          child: showSendButton
              ? _opacity(
                  context: context,
                  key: const ValueKey<String>('send'),
                  enabled: sendVisuallyEnabled,
                  child: FluxerButton.circle(
                    icon: PhosphorIconsBold.arrowUp,
                    iconSize: 20,
                    size: FluxerButtonSize.small,
                    semanticLabel: l10n.permissionSendMessages,
                    onPressed: sendOnPressed,
                  ),
                )
              : showQuickSwitcherButton
              ? quickSwitcherButton
              : showVoiceButton
              ? voiceMic
              : const SizedBox.shrink(key: ValueKey<String>('voice-hidden')),
        );
      }
      return SizedBox(
        width: _kWideActionExtent,
        height: _kWideActionExtent,
        child: AnimatedSwitcher(
          duration: context.motion.panel,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(opacity: animation, child: child),
          child: showSendButton
              ? _opacity(
                  context: context,
                  key: const ValueKey<String>('send'),
                  enabled: sendVisuallyEnabled,
                  child: IconButton(
                    icon: const PhosphorIcon(
                      PhosphorIconsBold.arrowUp,
                      size: 20,
                    ),
                    color: context.colors.interactiveNormal,
                    tooltip: l10n.permissionSendMessages,
                    onPressed: sendOnPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: _kWideActionExtent,
                      minHeight: _kWideActionExtent,
                    ),
                  ),
                )
              : showQuickSwitcherButton
              ? SizedBox(
                  key: const ValueKey<String>('quick-switcher'),
                  width: _kWideActionExtent,
                  height: _kWideActionExtent,
                  child: IconButton(
                    icon: const PhosphorIcon(
                      PhosphorIconsBold.lightning,
                      size: 20,
                    ),
                    color: context.colors.interactiveNormal,
                    tooltip: l10n.quickSwitcherTabSearch,
                    onPressed: () =>
                        unawaited(QuickSwitcherBottomSheet.show(context, ref)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: _kWideActionExtent,
                      minHeight: _kWideActionExtent,
                    ),
                  ),
                )
              : showVoiceButton
              ? voiceMic
              : const SizedBox.shrink(key: ValueKey<String>('voice-hidden')),
        ),
      );
    }
    return AnimatedSwitcher(
      duration: context.motion.panel,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(opacity: animation, child: child),
      child: showSendButton
          ? _opacity(
              context: context,
              key: const ValueKey<String>('send'),
              enabled: sendVisuallyEnabled,
              child: FluxerButton.circle(
                icon: PhosphorIconsBold.arrowUp,
                iconSize: 20,
                size: widget.size,
                semanticLabel: l10n.permissionSendMessages,
                onPressed: sendOnPressed,
              ),
            )
          : showQuickSwitcherButton
          ? quickSwitcherButton
          : showVoiceButton
          ? voiceMic
          : const SizedBox.shrink(key: ValueKey<String>('voice-hidden')),
    );
  }
}

Widget _opacity({
  required BuildContext context,
  required bool enabled,
  required Widget child,
  Key? key,
}) {
  return AnimatedOpacity(
    key: key,
    opacity: enabled ? 1 : _kDisabledOpacity,
    duration: context.motion.panel,
    curve: context.motion.curve,
    child: child,
  );
}
