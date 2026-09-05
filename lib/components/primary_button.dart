import 'package:flutter/material.dart';

import '../core/app_color.dart';

/// A full-width pill button that greys out until [enabled] is true.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.isLoading = false,
    this.gradient = false,
    this.trailingIcon,
    this.leading,
    this.height = 52,
    this.gradientColors,
    this.labelStyle,
  });

  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  /// Paints the enabled button with the auth flow's blue gradient and a soft
  /// drop shadow. Opt-in so the dashboard's buttons keep their flat fill.
  final bool gradient;

  /// Optional icon after the label, e.g. the arrow on "Continue".
  final IconData? trailingIcon;

  /// Optional widget before the label — used where the design calls for an
  /// exported glyph rather than a Material icon, e.g. the pin on "Use my
  /// current location".
  final Widget? leading;

  final double height;

  /// Stops of the gradient when [gradient] is on. Defaults to the auth
  /// flow's blues; the discovery flow passes its own so both can share this
  /// button without one restyling the other.
  final List<Color>? gradientColors;

  /// Overrides the label's type. Defaults to the button's 16pt bold.
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient =
        gradientColors ?? const [AppColor.authAccent, AppColor.authAccentDeep];

    final button = SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ButtonStyle(
          // Resolved from `enabled` instead of the disabled state so loading
          // (which nulls onPressed) doesn't grey out the button.
          backgroundColor: WidgetStateProperty.all(
            // Transparent when gradient-painted, so the Container behind
            // shows through instead of a flat fill on top of it.
            gradient && enabled
                ? Colors.transparent
                : enabled
                ? AppColor.indicativeBlueColor400
                : AppColor.neutralGreyColor100,
          ),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(
            enabled ? AppColor.white : AppColor.neutralGreyColor300,
          ),
          elevation: WidgetStateProperty.all(0),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColor.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 10)],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          labelStyle ??
                          const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 18),
                  ],
                ],
              ),
      ),
    );

    if (!gradient || !enabled) return button;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: effectiveGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveGradient.last.withValues(alpha: 0.32),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: button,
    );
  }
}
