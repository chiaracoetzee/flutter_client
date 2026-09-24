import 'dart:async';

import 'package:chrono_dart/chrono_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/theme/fluxer_theme_extension.dart';
import 'package:fluxer_app/features/chat/providers/pickers/timestamp_insert_provider.dart';
import 'package:fluxer_app/features/chat/utils/messages/markdown_timestamp_format.dart';
import 'package:fluxer_app/features/chat/utils/timezone_data.dart';
import 'package:fluxer_app/features/chat/utils/timezone_picker_utils.dart';
import 'package:fluxer_app/features/settings/providers/use_12_hour_time_format_provider.dart';
import 'package:fluxer_app/features/settings/providers/user_settings_view_model.dart';
import 'package:fluxer_app/features/ui/bottom_sheet/fluxer_bottom_sheet.dart';
import 'package:fluxer_app/features/ui/button/fluxer_button.dart';
import 'package:fluxer_app/features/ui/input/fluxer_input.dart';
import 'package:fluxer_app/features/ui/select/fluxer_select.dart';
import 'package:fluxer_app/features/ui/tappable/fluxer_tappable.dart';
import 'package:fluxer_app/l10n/generated/fluxer_localizations.dart';
import 'package:fluxer_app/material_ui.dart';
import 'package:fluxer_app/shared/utils/user_date_formatting.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TimestampPickerSheet {
  TimestampPickerSheet._();

  static Future<void> show(
    BuildContext context, {
    void Function(int epoch, String style)? onInsert,
    int? initialEpoch,
    String? initialStyle,
  }) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    return FluxerBottomSheet.showScrollable<void>(
      context,
      title: l10n.timestampPickerTitle,
      builder: (BuildContext sheetContext, ScrollController scrollController, VoidCallback close) {
        return _TimestampPickerBody(
          scrollController: scrollController,
          onClose: close,
          initialEpoch: initialEpoch,
          initialStyle: initialStyle,
          onInsert: onInsert,
        );
      },
    );
  }
}

class _TimestampPickerBody extends ConsumerStatefulWidget {
  const _TimestampPickerBody({
    required this.scrollController,
    required this.onClose,
    this.onInsert,
    this.initialEpoch,
    this.initialStyle,
  });

  final ScrollController scrollController;
  final VoidCallback onClose;
  final void Function(int epoch, String style)? onInsert;
  final int? initialEpoch;
  final String? initialStyle;

  @override
  ConsumerState<_TimestampPickerBody> createState() =>
      _TimestampPickerBodyState();
}

class _TimestampPickerBodyState extends ConsumerState<_TimestampPickerBody> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _selectedSecond;
  late String _selectedFormat;
  late TimezoneOption _selectedTimezone;

  late final TextEditingController _nlpController;

  @override
  void initState() {
    super.initState();

    final DateTime baseDateTime;
    if (widget.initialEpoch != null) {
      baseDateTime = DateTime.fromMillisecondsSinceEpoch(
        widget.initialEpoch! * 1000,
      );
    } else {
      baseDateTime = DateTime.now();
    }

    _selectedDate = DateTime(baseDateTime.year, baseDateTime.month, baseDateTime.day);
    _selectedTime = TimeOfDay.fromDateTime(baseDateTime);
    _selectedSecond = baseDateTime.second;
    _selectedFormat = widget.initialStyle ?? 'combo';

    final String? userTimezone = ref.read(
      userSettingsViewModelProvider.select((s) => s.timezone),
    );
    _selectedTimezone = findTimezoneOption(
      userTimezone,
      DateTime.now().timeZoneOffset.inMinutes,
    );
    if (userTimezone == null || userTimezone.isEmpty) {
      unawaited(
        getDeviceIanaTimezone().then((iana) {
          if (mounted) {
            setState(() {
              _selectedTimezone = findTimezoneOption(
                null,
                DateTime.now().timeZoneOffset.inMinutes,
                iana,
              );
            });
          }
        }),
      );
    }

    _nlpController = TextEditingController();
  }

  @override
  void dispose() {
    _nlpController.dispose();
    super.dispose();
  }

  String _formatDateDisplay(DateTime date, String locale) {
    try {
      return DateFormat.yMMMEd(locale).format(date);
    } on Object catch (_) {
      return DateFormat.yMMMEd().format(date);
    }
  }

  String _formatTime(TimeOfDay time) {
    final bool use12Hour = ref.read(use12HourTimeFormatProvider);
    final String locale = FluxerLocalizations.of(context).localeName;
    final DateTime dt = DateTime(2026, 1, 1, time.hour, time.minute);
    return formatUserTime(dt, locale, use12Hour: use12Hour);
  }

  void _handleNlpChange(String text) {
    setState(() {});
    if (text.trim().isEmpty) {
      return;
    }

    try {
      final DateTime refDateTime = getCurrentWallClockTime(_selectedTimezone);
      final List<ParsedResult> results = Chrono.parse(
        text,
        ref: refDateTime,
        option: ParsingOption(forwardDate: true),
      );
      if (results.isNotEmpty && mounted) {
        final ParsedResult first = results.first;
        // Read raw parsed components directly instead of calling first.date(),
        // because date() bakes in the system timezone offset via
        // DateTime().millisecondsSinceEpoch, corrupting the wall-clock values
        // on non-UTC devices.
        setState(() {
          _selectedDate = DateTime(
            first.start.get(Component.year)?.toInt() ?? refDateTime.year,
            first.start.get(Component.month)?.toInt() ?? refDateTime.month,
            first.start.get(Component.day)?.toInt() ?? refDateTime.day,
          );
          final bool hasTime = first.start.isCertain(Component.hour) ||
              first.start.isCertain(Component.minute);
          if (hasTime) {
            _selectedTime = TimeOfDay(
              hour: first.start.get(Component.hour)?.toInt() ?? 0,
              minute: first.start.get(Component.minute)?.toInt() ?? 0,
            );
            _selectedSecond =
                first.start.get(Component.second)?.toInt() ?? 0;
          }
        });
      }
    } on Object catch (_) {
      // Ignore parse errors as user is typing
    }
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: now.add(const Duration(days: 365 * 50)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        _nlpController.clear();
      });
    }
  }

  Future<void> _pickTime() async {
    final bool use12Hour = ref.read(use12HourTimeFormatProvider);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: !use12Hour,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
        _selectedSecond = 0;
        _nlpController.clear();
      });
    }
  }

  int _computeEpoch() {
    return calculateEpochFromWallClock(
      wallClockDate: _selectedDate,
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      second: _selectedSecond,
      timezoneIana: _selectedTimezone.value,
    );
  }

  void _handleInsert() {
    final int epoch = _computeEpoch();
    if (widget.onInsert != null) {
      widget.onInsert!(epoch, _selectedFormat);
    } else {
      ref.read(pendingTimestampInsertProvider.notifier).emit(epoch, _selectedFormat);
    }
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final FluxerLocalizations l10n = FluxerLocalizations.of(context);
    final layout = context.layout;
    final colors = context.colors;
    final textStyles = context.textStyles;
    final bool use12Hour = ref.watch(use12HourTimeFormatProvider);

    final DateTime wallClockDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
      _selectedSecond,
    );

    final int previewEpoch = _computeEpoch();
    final DateTime epochInstant = DateTime.fromMillisecondsSinceEpoch(
      previewEpoch * 1000,
    );

    final String comboPreview =
        '${formatMarkdownTimestamp(wallClockDateTime, 'f', l10n, use12Hour: use12Hour)} (${formatMarkdownTimestamp(epochInstant, 'R', l10n, use12Hour: use12Hour)})';

    final List<FluxerSelectItem<String>> formatItems = <FluxerSelectItem<String>>[
      FluxerSelectItem<String>(
        value: 'combo',
        label: comboPreview,
      ),
      FluxerSelectItem<String>(
        value: 'f',
        label: formatMarkdownTimestamp(wallClockDateTime, 'f', l10n, use12Hour: use12Hour),
      ),
      FluxerSelectItem<String>(
        value: 'F',
        label: formatMarkdownTimestamp(wallClockDateTime, 'F', l10n, use12Hour: use12Hour),
      ),
      FluxerSelectItem<String>(
        value: 'R',
        label: formatMarkdownTimestamp(epochInstant, 'R', l10n, use12Hour: use12Hour),
      ),
      FluxerSelectItem<String>(
        value: 'd',
        label: formatMarkdownTimestamp(wallClockDateTime, 'd', l10n, use12Hour: use12Hour),
      ),
      FluxerSelectItem<String>(
        value: 'D',
        label: formatMarkdownTimestamp(wallClockDateTime, 'D', l10n, use12Hour: use12Hour),
      ),
      FluxerSelectItem<String>(
        value: 't',
        label: formatMarkdownTimestamp(wallClockDateTime, 't', l10n, use12Hour: use12Hour),
      ),
      FluxerSelectItem<String>(
        value: 'T',
        label: formatMarkdownTimestamp(wallClockDateTime, 'T', l10n, use12Hour: use12Hour),
      ),
    ];

    final List<FluxerSelectItem<String>> timezoneItems = kTimezoneOptions
        .map(
          (opt) => FluxerSelectItem<String>(
            value: opt.value,
            label: opt.label,
            searchText: opt.searchText,
            leading: PhosphorIcon(
              PhosphorIconsBold.globe,
              size: 18,
              color: colors.textSecondary,
            ),
          ),
        )
        .toList(growable: false);

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.all(layout.s4),
      children: <Widget>[
        // NLP Field
        FluxerInput(
          controller: _nlpController,
          hint: l10n.timestampPickerNlpPlaceholder,
          onChanged: _handleNlpChange,
          prefixIcon: Padding(
            padding: EdgeInsets.all(layout.s3),
            child: const PhosphorIcon(
              PhosphorIconsFill.lightning,
              size: 18,
              color: Color(0xFFFBBF24),
            ),
          ),
          suffixIcon: _nlpController.text.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.all(layout.s3),
                  child: PhosphorIcon(
                    PhosphorIconsFill.xCircle,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                )
              : null,
          onSuffixTap: _nlpController.text.isNotEmpty
              ? () {
                  _nlpController.clear();
                  setState(() {});
                }
              : null,
        ),
        SizedBox(height: layout.s4),

        // DATE & TIME Row (Google Calendar style)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Date Picker trigger
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.timestampPickerDateLabel,
                    style: textStyles.label.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: layout.s1_5),
                  FluxerTappable(
                    onTap: _pickDate,
                    semanticLabel: l10n.timestampPickerDateLabel,
                    builder: (context, states) {
                      final bool isPressed = states.contains(WidgetState.pressed);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isPressed
                              ? colors.backgroundSecondary
                              : colors.backgroundTertiary,
                          borderRadius: layout.radiusLg,
                          border: Border.all(
                            color: isPressed
                                ? colors.brandPrimary
                                : colors.backgroundModifierAccent,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            PhosphorIcon(
                              PhosphorIconsBold.calendar,
                              size: 18,
                              color: colors.textSecondary,
                            ),
                            SizedBox(width: layout.s2),
                            Expanded(
                              child: Text(
                                _formatDateDisplay(_selectedDate, l10n.localeName),
                                style: textStyles.bodySmall.copyWith(
                                  color: colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: layout.s3),
            // Time Picker trigger
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    l10n.timestampPickerTimeSectionLabel,
                    style: textStyles.label.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: layout.s1_5),
                  FluxerTappable(
                    onTap: _pickTime,
                    semanticLabel: l10n.timestampPickerTimeSectionLabel,
                    builder: (context, states) {
                      final bool isPressed = states.contains(WidgetState.pressed);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isPressed
                              ? colors.backgroundSecondary
                              : colors.backgroundTertiary,
                          borderRadius: layout.radiusLg,
                          border: Border.all(
                            color: isPressed
                                ? colors.brandPrimary
                                : colors.backgroundModifierAccent,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            PhosphorIcon(
                              PhosphorIconsBold.clock,
                              size: 18,
                              color: colors.textSecondary,
                            ),
                            SizedBox(width: layout.s2),
                            Expanded(
                              child: Text(
                                _formatTime(_selectedTime),
                                style: textStyles.bodySmall.copyWith(
                                  color: colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: layout.s4),

        // TIME ZONE Field
        FluxerSelect<String>(
          label: l10n.timestampPickerTimezoneLabel,
          searchHint: l10n.timestampPickerSearchTimezones,
          items: timezoneItems,
          value: _selectedTimezone.value,
          stretch: true,
          onChanged: (val) {
            setState(() {
              _selectedTimezone = findTimezoneOption(val);
              _nlpController.clear();
            });
          },
        ),
        SizedBox(height: layout.s4),

        // FORMAT PREVIEW Field
        FluxerSelect<String>(
          label: l10n.timestampPickerFormatPreviewLabel,
          items: formatItems,
          value: _selectedFormat,
          enableSearch: false,
          stretch: true,
          onChanged: (val) {
            setState(() {
              _selectedFormat = val;
            });
          },
        ),
        SizedBox(height: layout.s5),

        // Insert Button
        FluxerButton.primary(
          label: l10n.timestampPickerInsert,
          onPressed: _handleInsert,
        ),
      ],
    );
  }
}
