import 'package:flutter/material.dart';

import '../core/app_color.dart';

/// The application's one back affordance: a bare
/// `arrow_back_ios_rounded` with no background of any kind.
///
/// Several designs draw this as a chevron inside a white disc or rounded
/// square; the app deliberately does not, so the icon sits directly on
/// whatever is behind it. The 44pt box around it is a tap target, not a
/// surface — nothing is painted.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap, this.color, this.size = 20});

  /// Defaults to popping the current route.
  final VoidCallback? onTap;

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Align(
          // Nudged left so the glyph's own leading space does not leave the
          // arrow looking inset from the screen edge.
          alignment: const Alignment(-0.35, 0),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            size: size,
            color: color ?? AppColor.discoveryInk,
          ),
        ),
      ),
    );
  }
}
