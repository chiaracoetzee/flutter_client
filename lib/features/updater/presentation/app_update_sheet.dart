import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/core/updater/app_update_info.dart';
import 'package:fluxer_app/core/updater/app_update_provider.dart';
import 'package:fluxer_app/features/ui/bottom_sheet/fluxer_bottom_sheet.dart';
import 'package:fluxer_app/features/ui/button/fluxer_button.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppUpdateSheet extends ConsumerWidget {
  const AppUpdateSheet({
    required this.info,
    required this.close,
    super.key,
  });

  final AppUpdateInfo info;
  final VoidCallback close;

  static Future<void> show(BuildContext context, AppUpdateInfo info) {
    final l10n = FluxerLocalizations.of(context);
    return FluxerBottomSheet.show<void>(
      context,
      title: l10n.userSettingsUpdateAvailableTitle,
      useRootNavigator: true,
      builder: (sheetContext, close) => AppUpdateSheet(
        info: info,
        close: close,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = FluxerLocalizations.of(context);
    final updateState = ref.watch(appUpdateProvider);

    final bool isDownloading =
        updateState.status == AppUpdateStatus.downloading;
    final bool isReadyToInstall =
        updateState.status == AppUpdateStatus.readyToInstall;
    final int percentInt = (updateState.progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colors.brandPrimary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    PhosphorIconsFill.arrowCircleUp,
                    color: context.colors.brandPrimary,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title.isNotEmpty ? info.title : info.tagName,
                      style: context.textStyles.heading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${info.tagName}${info.formattedFileSize.isNotEmpty ? ' • ${info.formattedFileSize}' : ''}',
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (info.releaseNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: Text(
                  info.releaseNotes,
                  style: context.textStyles.bodySmall,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (isDownloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: updateState.progress > 0 ? updateState.progress : null,
                minHeight: 8,
                backgroundColor: context.colors.backgroundSecondary,
                valueColor:
                    AlwaysStoppedAnimation<Color>(context.colors.brandPrimary),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                l10n.userSettingsDownloadingUpdate(percentInt),
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ] else if (isReadyToInstall) ...[
            FluxerButton.primary(
              label: l10n.userSettingsUpdateInstallAction,
              icon: PhosphorIconsBold.check,
              onPressed: () => ref.read(appUpdateProvider.notifier).install(),
            ),
          ] else ...[
            FluxerButton.primary(
              label: l10n.userSettingsUpdateDownloadAction,
              icon: PhosphorIconsBold.downloadSimple,
              onPressed: () =>
                  ref.read(appUpdateProvider.notifier).startDownload(),
            ),
          ],
          if (updateState.status == AppUpdateStatus.error) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                l10n.userSettingsUpdateFailed,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colors.textDanger,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
