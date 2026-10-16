// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// Whether upstream's search fields may ask the keyboard for suggestions.
///
/// Upstream turns suggestions off on its search fields, with autocorrect, so
/// that search terms are not rewritten. On Android, Flutter answers a field
/// without suggestions by also declaring it a visible password field (some
/// keyboards ignore the no-suggestions flag alone), and Gboard then shows its
/// password layout: a number row and no swipe typing. Keep suggestions on
/// there; autocorrect stays off, so nothing typed is replaced. Other
/// platforms keep upstream's choice.
bool get forkSearchFieldEnableSuggestions =>
    defaultTargetPlatform == TargetPlatform.android;
