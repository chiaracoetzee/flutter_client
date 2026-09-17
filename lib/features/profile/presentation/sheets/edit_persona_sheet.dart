import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/api/fluxer_client_provider.dart';
import 'package:fluxer_app/core/talker.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/profile/domain/public_persona.dart';
import 'package:fluxer_app/features/profile/providers/persona_providers.dart';
import 'package:fluxer_app/features/profile/providers/public_persona_provider.dart';
import 'package:fluxer_app/features/ui/ui.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EditPersonaSheet {
  EditPersonaSheet._();

  static Future<PublicPersona?> show(
    BuildContext context, {
    required PublicPersona persona,
  }) {
    return FluxerBottomSheet.showScrollable<PublicPersona?>(
      context,
      title: 'Edit Persona',
      useRootNavigator: true,
      minChildSize: 0.5,
      showDragHandle: true,
      builder: (sheetContext, scrollController, close) {
        return _EditPersonaBody(
          persona: persona,
          scrollController: scrollController,
          onClose: close,
        );
      },
    );
  }
}

class _EditPersonaBody extends ConsumerStatefulWidget {
  const _EditPersonaBody({
    required this.persona,
    required this.scrollController,
    required this.onClose,
  });

  final PublicPersona persona;
  final ScrollController scrollController;
  final VoidCallback onClose;

  @override
  ConsumerState<_EditPersonaBody> createState() => _EditPersonaBodyState();
}

class _EditPersonaBodyState extends ConsumerState<_EditPersonaBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _tagController;
  late final TextEditingController _pronounsController;
  late final TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.persona.name);
    _tagController =
        TextEditingController(text: widget.persona.systemName ?? '');
    _pronounsController =
        TextEditingController(text: widget.persona.pronouns ?? '');
    _bioController = TextEditingController(text: widget.persona.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _pronounsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    setState(() => _isSaving = true);
    try {
      final Dio dio = ref.read(fluxerDioProvider);
      final String? systemName = _tagController.text.trim().isEmpty
          ? null
          : _tagController.text.trim();
      final String? pronouns = _pronounsController.text.trim().isEmpty
          ? null
          : _pronounsController.text.trim();
      final String? bio = _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim();

      final Response<dynamic> response = await dio.patch<dynamic>(
        '/users/@me/personas/${widget.persona.id}',
        data: <String, dynamic>{
          'name': name,
          'system_name': systemName,
          'pronouns': pronouns,
          'bio': bio,
        },
      );

      final dynamic data = response.data;
      final PublicPersona updated;
      if (data is Map<String, dynamic>) {
        updated = PublicPersona.fromJson(data);
      } else if (data is Map) {
        updated = PublicPersona.fromJson(Map<String, dynamic>.from(data));
      } else {
        updated = widget.persona.copyWith(
          name: name,
          systemName: systemName,
          pronouns: pronouns,
          bio: bio,
        );
      }

      ref.invalidate(
        publicPersonaProvider(
          (userId: '', personaId: widget.persona.id),
        ),
      );
      unawaited(ref.read(myPersonasProvider.notifier).reloadSilently());

      ref.read(toastProvider.notifier).show(
        const FluxerToast(
          message: 'Persona updated',
          variant: FluxerToastVariant.success,
        ),
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(updated);
      }
    } catch (err, st) {
      talker.error('[EditPersonaSheet] Failed to update persona: $err', err, st);
      ref.read(toastProvider.notifier).show(
        const FluxerToast(
          message: 'Failed to update persona',
          variant: FluxerToastVariant.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(
        layout.s4,
        0,
        layout.s4,
        layout.s4 + FluxerBottomSheet.scrollBottomPaddingOf(context),
      ),
      children: [
        FluxerInput(
          controller: _nameController,
          label: 'Display Name',
          hint: 'Persona name',
          maxLength: 100,
          enabled: !_isSaving,
          autofocus: true,
        ),
        SizedBox(height: layout.s3),
        FluxerInput(
          controller: _tagController,
          label: 'System Tag / Badge',
          hint: 'e.g. TEST SYSTEM',
          maxLength: 100,
          enabled: !_isSaving,
        ),
        SizedBox(height: layout.s3),
        FluxerInput(
          controller: _pronounsController,
          label: 'Pronouns',
          hint: 'e.g. they/them',
          maxLength: 100,
          enabled: !_isSaving,
        ),
        SizedBox(height: layout.s3),
        FluxerInput.multiline(
          controller: _bioController,
          label: 'Bio / About Me',
          hint: 'Tell others about this persona...',
          maxLines: 5,
          maxLength: 1024,
          showCounter: true,
          enabled: !_isSaving,
        ),
        SizedBox(height: layout.s4),
        SizedBox(
          width: double.infinity,
          child: FluxerButton.primary(
            label: 'Save Changes',
            icon: PhosphorIconsFill.check,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
        ),
      ],
    );
  }
}
