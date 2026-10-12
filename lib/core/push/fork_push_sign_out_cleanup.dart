import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluxer_app/core/push/push_account_lifecycle.dart';

/// Fork: runs the sign-out push cleanup for the active account.
///
/// Widgets that reset `currentUserIdProvider` as part of signing out call this
/// first: [PushAccountLifecycle.leaveActiveAccount] reads that id and does
/// nothing once it is gone, which leaves the local registration record behind
/// and stops the app registering for push again after the next sign-in.
final forkPushSignOutCleanupProvider = Provider<Future<void> Function()>(
  (Ref ref) =>
      () => PushAccountLifecycle.leaveActiveAccount(
        ref,
        mode: LeavePushAccountMode.signOut,
      ),
);
