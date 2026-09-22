// ignore: unused_import // Fork: upstream's import, unused since the fork's changes.
import 'package:fluxer_app/core/build/app_build_config.dart';
import 'package:fluxer_app/material_ui.dart';

class BetaBanner extends StatelessWidget {
  const BetaBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
