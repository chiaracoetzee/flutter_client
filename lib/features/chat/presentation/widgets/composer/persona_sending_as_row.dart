// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/chat/presentation/sheets/persona_picker_sheet.dart';
import 'package:fluxer_app/features/chat/presentation/widgets/composer/persona_composer_pill.dart';
import 'package:fluxer_app/features/profile/domain/persona.dart';
import 'package:fluxer_app/features/profile/domain/persona_matcher.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/l10n_fork/fork_localizations_x.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/fluxer_haptics.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Fork: "Sending as ..." as a row of a form sheet (new thread, new forum
/// post), above the message field. Tapping it opens the persona picker.
///
/// The channel composer shows the persona as a round button among its other
/// round buttons. A sheet of labelled, full-width fields has no such row, so
/// here it is a row of its own that names the persona in words. Renders
/// nothing for a user without personas.
class PersonaSendingAsRow extends ConsumerWidget {
  const PersonaSendingAsRow({
    required this.text,
    this.hasAttachments = false,
    this.posting = false,
    super.key,
  });

  /// The message as typed so far: a persona tag in it changes who it is sent as.
  final String text;
  final bool hasAttachments;

  /// A forum post is posted, a thread's first message is sent.
  final bool posting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Persona> personas =
        ref.watch(myPersonasProvider).asData?.value ?? const <Persona>[];
    if (personas.isEmpty) {
      return const SizedBox.shrink();
    }
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final activeState = ref.watch(activePersonaProvider);
    final String username = ref.watch(
      userSettingsViewModelProvider.select((settings) => settings.username),
    );
    final String? latchedId = activeState.isLatched
        ? activeState.activePersonaId
        : null;
    final PreviewResult preview = previewPersona(
      text,
      personas,
      latchedId,
      hasAttachments,
    );
    final Persona? persona = preview.persona;
    final String name = persona?.name ?? '@$username';
    final String label = posting
        ? l10n.fork.personaPostingAs(name)
        : l10n.fork.personaSendingAs(name);
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FluxerHaptics.light();
          unawaited(PersonaPickerSheet.show(context));
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: context.layout.s2),
          child: Row(
            children: <Widget>[
              ExcludeSemantics(
                child: PersonaComposerPill(
                  text: text,
                  hasAttachments: hasAttachments,
                ),
              ),
              SizedBox(width: context.layout.s2),
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
              ),
              PhosphorIcon(
                PhosphorIconsBold.caretRight,
                size: 14,
                color: context.colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
