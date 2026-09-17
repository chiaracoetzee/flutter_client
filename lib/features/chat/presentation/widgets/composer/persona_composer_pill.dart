// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/chat/presentation/sheets/persona_picker_sheet.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_matcher.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/features/ui/avatar/fluxer_avatar.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/fluxer_haptics.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PersonaComposerPill extends ConsumerWidget {
  const PersonaComposerPill({
    required this.text,
    this.hasAttachments = false,
    super.key,
  });

  final String text;
  final bool hasAttachments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personasAsync = ref.watch(myPersonasProvider);
    final personas = personasAsync.asData?.value ?? const [];

    // Hide completely if the user has no personas configured
    if (personas.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = FluxerLocalizations.of(context);
    final activeState = ref.watch(activePersonaProvider);
    final userSettings = ref.watch(userSettingsViewModelProvider);

    final String? latchedId =
        activeState.isLatched ? activeState.activePersonaId : null;
    final PreviewResult preview = previewPersona(
      text,
      personas,
      latchedId,
      hasAttachments,
    );

    final Persona? effectivePersona = preview.persona;
    final bool isFromTag = preview.isFromTag;
    final bool isLatched = activeState.isLatched && latchedId != null;

    final colors = context.colors;

    final String? avatarUrl = effectivePersona != null
        ? effectivePersona.avatarUrl
        : userSettings.avatarUrl;
    final String fallbackName = effectivePersona != null
        ? effectivePersona.name
        : (userSettings.displayName.isNotEmpty
            ? userSettings.displayName
            : userSettings.username);
    final int? avatarColor =
        effectivePersona?.color ?? userSettings.avatarColor;

    final String tooltip = isFromTag && effectivePersona != null
        ? l10n.personaSendingAsTag(effectivePersona.name)
        : isLatched && effectivePersona != null
            ? l10n.personaSendingAsLatched(effectivePersona.name)
            : l10n.personaSendingAsRoot(userSettings.username);

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FluxerHaptics.light();
          unawaited(PersonaPickerSheet.show(context));
        },
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFromTag
                        ? colors.brandPrimary
                        : isLatched
                            ? colors.brandPrimary.withValues(alpha: 0.6)
                            : colors.borderColor,
                    width: isFromTag ? 2.0 : 1.2,
                  ),
                ),
                child: ClipOval(
                  child: FluxerAvatar.user(
                    userId: effectivePersona != null ? null : userSettings.userId,
                    imageUrl: avatarUrl,
                    fallbackText: fallbackName,
                    avatarColor: avatarColor,
                    size: 28,
                    showStatus: false,
                  ),
                ),
              ),

              // Lock badge when latched
              if (isLatched && !isFromTag)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: colors.brandPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.chatInputBackground,
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        PhosphorIconsBold.lockSimple,
                        size: 7,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // Tag badge indicator when matched by tag
              if (isFromTag)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: colors.accentSuccess,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.chatInputBackground,
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        PhosphorIconsBold.tag,
                        size: 7,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
