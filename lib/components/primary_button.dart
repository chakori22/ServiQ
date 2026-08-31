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
  });

  final String label;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ButtonStyle(
          // Resolved from `enabled` instead of the disabled state so loading
          // (which nulls onPressed) doesn't grey out the button.
          backgroundColor: WidgetStateProperty.all(
            enabled
                ? AppColor.indicativeBlueColor400
                : AppColor.neutralGreyColor100,
          ),
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
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
