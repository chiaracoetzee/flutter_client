import 'package:flutter/foundation.dart';

// Fork: the alternate icons are variations of the Fluxer logo, which Tyne does not use (upstream's
// name and marks policy), so the picker is hidden until Tyne has alternates of its own.
bool get _forkHasAlternateAppIcons => false;

bool get isAlternateAppIconSettingsAvailable {
  if (!_forkHasAlternateAppIcons) {
    return false;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => true,
    TargetPlatform.android => true,
    _ => false,
  };
}
