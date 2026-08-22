import 'package:flutter/material.dart';

import '../app_color.dart';

/// A themed text field with an optional label row, styled to match the app's blue palette.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.maxLength,
    this.prefixText,
    this.suffixIcon,
    this.errorText,
    this.enabledLabelColor,
    this.width,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? errorText;
  final Color? enabledLabelColor;
  final double? width;

  bool get _hasLabel => labelText != null && labelText!.isNotEmpty;
  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  Color get _labelColor {
    if (_hasError) return Colors.red;
    if (!enabled && controller.text.isEmpty) {
      return AppColor.neutralGreyColor300;
    }
    return enabledLabelColor ?? AppColor.indicativeBlueColor700;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);
    final hasPrefix = prefixText != null && prefixText!.isNotEmpty;
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasLabel) ...[
            Text(
              labelText!,
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _labelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
          ],
          ClipRRect(
            borderRadius: borderRadius,
            child: ColoredBox(
              color: AppColor.neutralGreyColor60,
              child: Row(
                children: [
                  if (hasPrefix)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 12,
                        top: 18,
                        bottom: 18,
                      ),
                      child: Text(
                        prefixText!,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: AppColor.neutralGreyColor900,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: enabled,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      maxLength: maxLength,
                      onChanged: onChanged,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColor.neutralGreyColor900,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: AppColor.neutralGreyColor300,
                        ),
                        suffixIcon: suffixIcon,
                        errorText: errorText,
                        counterText: '',
                        filled: false,
                        contentPadding: EdgeInsets.only(
                          left: hasPrefix ? 0 : 20,
                          right: 20,
                          top: 18,
                          bottom: 18,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


