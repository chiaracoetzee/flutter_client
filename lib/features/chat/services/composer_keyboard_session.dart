import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/features/chat/providers/pickers/attachment_panel_provider.dart';
import 'package:fluxer_app/features/chat/providers/pickers/bottom_input_slot_provider.dart';
import 'package:fluxer_app/features/chat/providers/pickers/expression_panel_provider.dart';
import 'package:fluxer_app/features/chat/providers/pickers/mobile_keyboard_metrics_provider.dart';
import 'package:fluxer_app/features/chat/utils/composer/bottom_input_slot_layout.dart';
import 'package:fluxer_app/features/chat/utils/composer/composer_keyboard_breadcrumb.dart';
import 'package:fluxer_app/features/chat/utils/composer/composer_panel.dart';
import 'package:fluxer_app/features/input/providers/physical_keyboard_provider.dart';
import 'package:fluxer_app/shared/utils/keyboard_focus_restore.dart';

enum ComposerKeyboardState {
  idle,
  keyboardOpen,
  panelOpen,
  transitioningToPanel,
  transitioningToKeyboard,
  restoringAfterResume,
  imeReconnecting,
}

typedef ComposerKeyboardMounted = bool Function();
typedef ComposerKeyboardMobileLayout = bool Function();
typedef ComposerKeyboardSlashActive = bool Function();
typedef ComposerKeyboardEntryFocused = bool Function();
typedef ComposerKeyboardRequestRebuild = void Function();

class ComposerKeyboardSession {
  ComposerKeyboardSession({
    required this._ref,
    required FocusNode focusNode,
    required this._isMounted,
    required this._isMobileLayout,
    required this._isSlashSessionActive,
    required this._composerEntryFocused,
    required this._requestRebuild,
  }) : _focusNode = focusNode {
    _keyboardRestore = KeyboardFocusRestoreHandle(
      focusNode: focusNode,
      shouldTrackOnBackground: _shouldTrackKeyboardRestore,
      canRestoreFocus: _canRestoreKeyboardFocus,
      toggleReadOnly: _setReconnectReadOnly,
    );
  }

  final WidgetRef _ref;
  final FocusNode _focusNode;
  final ComposerKeyboardMounted _isMounted;
  final ComposerKeyboardMobileLayout _isMobileLayout;
  final ComposerKeyboardSlashActive _isSlashSessionActive;
  final ComposerKeyboardEntryFocused _composerEntryFocused;
  final ComposerKeyboardRequestRebuild _requestRebuild;

  late final KeyboardFocusRestoreHandle _keyboardRestore;

  ComposerKeyboardState _keyboardState = ComposerKeyboardState.idle;
  bool _reconnectReadOnly = false;

  ComposerKeyboardState get keyboardState => _keyboardState;
  bool get reconnectReadOnly => _reconnectReadOnly;
  bool get hasPendingRestore => _keyboardRestore.hasPendingRestore;

  void dispose() {
    _keyboardRestore.dispose();
    _reconnectReadOnly = false;
    _keyboardState = ComposerKeyboardState.idle;
  }

  void onChannelChanged() {
    cancelReadOnlyReconnect();
  }

  void deactivate() {
    cancelReadOnlyReconnect();
    if (!_isMounted()) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMounted()) {
        return;
      }
      _ref
          .read(mobileKeyboardMetricsProvider.notifier)
          .clearUnmeasuredKeyboardReservation();
    });
  }

  void handleAppLifecycle(AppLifecycleState state) {
    if (_isSlashSessionActive()) {
      if (state == AppLifecycleState.resumed) {
        maybeReserveUnmeasuredKeyboard();
      }
      return;
    }
    if (state == AppLifecycleState.resumed) {
      _keyboardState = ComposerKeyboardState.restoringAfterResume;
      _recordDebugBreadcrumb();
    }
    _keyboardRestore.handleLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      maybeReserveUnmeasuredKeyboard();
      if (_keyboardState == ComposerKeyboardState.restoringAfterResume) {
        _keyboardState = _resolveIdleKeyboardState();
        _recordDebugBreadcrumb();
      }
    }
  }

  void handleFocusChange({required bool focused}) {
    if (focused) {
      maybeReserveUnmeasuredKeyboard();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isMounted() || !_reconnectReadOnly) {
          return;
        }
        if (!isActiveReadOnlyReconnect()) {
          _setReconnectReadOnly(readOnly: false);
        }
      });
      if (_keyboardState == ComposerKeyboardState.imeReconnecting &&
          !isActiveReadOnlyReconnect()) {
        _keyboardState = ComposerKeyboardState.keyboardOpen;
      }
    } else {
      cancelReadOnlyReconnect();
      if (_isMounted()) {
        _ref
            .read(mobileKeyboardMetricsProvider.notifier)
            .clearUnmeasuredKeyboardReservation();
      }
      _keyboardState = _resolveIdleKeyboardState();
      _recordDebugBreadcrumb();
    }
  }

  void onComposerFieldTap(BuildContext context) {
    if (isComposerPanelOpen(
      expressionPanelOpen: _ref.read(expressionPanelProvider),
      attachmentPanelOpen: _ref.read(attachmentPanelProvider),
    )) {
      closePanelsAndFocusComposer();
      return;
    }
    if (_focusNode.hasFocus && resolvedKeyboardInsetBottom(context) <= 0) {
      _keyboardState = ComposerKeyboardState.imeReconnecting;
      _keyboardRestore.reconnectOpenField();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isActiveReadOnlyReconnect()) {
          _keyboardState = ComposerKeyboardState.keyboardOpen;
        }
      });
    }
  }

  void closePanelsAndFocusComposer() {
    if (!isComposerPanelOpen(
      expressionPanelOpen: _ref.read(expressionPanelProvider),
      attachmentPanelOpen: _ref.read(attachmentPanelProvider),
    )) {
      return;
    }
    _keyboardState = ComposerKeyboardState.transitioningToKeyboard;
    beginPanelToKeyboardTransition();
    _ref.read(expressionPanelProvider.notifier).close();
    _ref.read(attachmentPanelProvider.notifier).close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMounted()) {
        return;
      }
      if (_focusNode.canRequestFocus) {
        _focusNode.requestFocus();
      }
      if (_focusNode.hasFocus) {
        _keyboardState = ComposerKeyboardState.imeReconnecting;
        _keyboardRestore.reconnectOpenField();
      } else {
        _keyboardRestore.scheduleRestoreIfPending();
        _keyboardState = _resolveIdleKeyboardState();
      }
    });
  }

  void beginPanelToKeyboardTransition() {
    if (!_isMobileLayout()) {
      return;
    }
    final MobileKeyboardMetricsState metrics = _ref.read(
      mobileKeyboardMetricsProvider,
    );
    final double lockHeight =
        _ref.read(expressionPanelHeightProvider) ??
        metrics.resolveAnchorHeight();
    _ref
        .read(bottomInputSlotProvider.notifier)
        .beginKeyboardTransition(lockHeight);
  }

  void preparePanelFromKeyboard() {
    if (!_isMobileLayout()) {
      return;
    }
    if (isComposerPanelOpen(
      expressionPanelOpen: _ref.read(expressionPanelProvider),
      attachmentPanelOpen: _ref.read(attachmentPanelProvider),
    )) {
      return;
    }
    _keyboardState = ComposerKeyboardState.transitioningToPanel;
    final MobileKeyboardMetricsState metrics = _ref.read(
      mobileKeyboardMetricsProvider,
    );
    if (metrics.isKeyboardVisible &&
        isImeKeyboardHeight(metrics.liveKeyboardHeight)) {
      final double grossLock = resolveTransitionLockHeight(
        liveKeyboardHeight: metrics.liveKeyboardHeight,
        anchorHeight: metrics.resolveAnchorHeight(),
      );
      _ref
          .read(bottomInputSlotProvider.notifier)
          .beginPanelTransition(grossLock);
    }
    _keyboardState = ComposerKeyboardState.panelOpen;
  }

  void maybeReserveUnmeasuredKeyboard() {
    if (!_isMounted() || !_isMobileLayout()) {
      return;
    }
    if (isComposerPanelOpen(
      expressionPanelOpen: _ref.read(expressionPanelProvider),
      attachmentPanelOpen: _ref.read(attachmentPanelProvider),
    )) {
      return;
    }
    if (_ref.read(physicalKeyboardConnectedProvider).value ?? false) {
      return;
    }
    if (!_composerEntryFocused() && !_keyboardRestore.hasPendingRestore) {
      return;
    }
    _ref
        .read(mobileKeyboardMetricsProvider.notifier)
        .reserveUnmeasuredKeyboard();
  }

  void cancelReadOnlyReconnect() {
    _keyboardRestore.cancelReadOnlyReconnect();
    if (_keyboardState == ComposerKeyboardState.imeReconnecting) {
      _keyboardState = _resolveIdleKeyboardState();
      _recordDebugBreadcrumb();
    }
  }

  void reconnectOpenField() {
    _keyboardState = ComposerKeyboardState.imeReconnecting;
    _keyboardRestore.reconnectOpenField();
  }

  bool _shouldTrackKeyboardRestore() {
    if (!_isMounted() || !_isMobileLayout()) {
      return false;
    }
    if (isComposerPanelOpen(
      expressionPanelOpen: _ref.read(expressionPanelProvider),
      attachmentPanelOpen: _ref.read(attachmentPanelProvider),
    )) {
      return false;
    }
    if (!_focusNode.canRequestFocus) {
      return false;
    }
    if (_focusNode.hasFocus) {
      return true;
    }
    return _ref.read(mobileKeyboardMetricsProvider).isKeyboardVisible;
  }

  bool _canRestoreKeyboardFocus() {
    if (!_isMounted() || !_isMobileLayout()) {
      return false;
    }
    if (isComposerPanelOpen(
      expressionPanelOpen: _ref.read(expressionPanelProvider),
      attachmentPanelOpen: _ref.read(attachmentPanelProvider),
    )) {
      return false;
    }
    return _focusNode.canRequestFocus;
  }

  void _setReconnectReadOnly({required bool readOnly}) {
    if (_reconnectReadOnly == readOnly) {
      return;
    }
    _reconnectReadOnly = readOnly;
    if (readOnly) {
      _keyboardState = ComposerKeyboardState.imeReconnecting;
    } else if (_keyboardState == ComposerKeyboardState.imeReconnecting) {
      _keyboardState = _focusNode.hasFocus
          ? ComposerKeyboardState.keyboardOpen
          : ComposerKeyboardState.idle;
    }
    _requestRebuild();
    _recordDebugBreadcrumb();
  }

  void _recordDebugBreadcrumb() {
    if (!kDebugMode) {
      return;
    }
    unawaited(
      persistComposerKeyboardBreadcrumb(
        keyboardState: _keyboardState.name,
        reconnectReadOnly: _reconnectReadOnly,
      ),
    );
  }

  ComposerKeyboardState _resolveIdleKeyboardState() {
    if (isComposerPanelOpen(
      expressionPanelOpen: _ref.read(expressionPanelProvider),
      attachmentPanelOpen: _ref.read(attachmentPanelProvider),
    )) {
      return ComposerKeyboardState.panelOpen;
    }
    if (_focusNode.hasFocus) {
      return ComposerKeyboardState.keyboardOpen;
    }
    return ComposerKeyboardState.idle;
  }
}
