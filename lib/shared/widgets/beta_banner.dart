import 'package:fluxer_app/core/build/app_build_config.dart';
import 'package:fluxer_app/material_ui.dart';

// Fork imports.
// Fork: upstream's imports above stay as upstream has them, though the fork's changes leave
// some of them unused.
// ignore_for_file: unused_import

class BetaBanner extends StatelessWidget {
  const BetaBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
