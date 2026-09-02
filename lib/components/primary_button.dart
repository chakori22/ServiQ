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

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: double.infinity,
      height: 52,
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
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.authAccent, AppColor.authAccentDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.authAccent.withValues(alpha: 0.32),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: button,
    );
  }
}
