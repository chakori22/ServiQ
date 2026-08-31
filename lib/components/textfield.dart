import 'package:flutter/material.dart';

import '../core/app_color.dart';

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
    this.maxLines = 1,
    this.prefixText,
    this.suffixIcon,
    this.errorText,
    this.enabledLabelColor,
    this.width,
    this.borderColor,
    this.borderWidth = 1.0,
    this.floatingLabel = false,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;

  /// Number of lines the field can grow to. Set to null for an
  /// unbounded multi-line field (e.g. a description box).
  final int? maxLines;

  final String? prefixText;
  final Widget? suffixIcon;
  final String? errorText;
  final Color? enabledLabelColor;
  final double? width;

  /// Optional border color for the field. When null (default), the field
  /// stays borderless — matching the original design — and only the fill
  /// color from [AppColor.neutralGreyColor60] shows.
  final Color? borderColor;

  /// Width of the border, only applied when [borderColor] is set.
  final double borderWidth;

  /// When true and [labelText] is set, the label is embedded directly in
  /// the top-left of the field's border (Material "outlined" style)
  /// instead of being shown as a separate line above the field.
  /// Requires [borderColor] to be set too, since there's no border for
  /// the label to sit on otherwise.
  final bool floatingLabel;

  bool get _hasLabel => labelText != null && labelText!.isNotEmpty;
  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  Color get _labelColor {
    if (_hasError) return Colors.red;
    if (!enabled && controller.text.isEmpty) {
      return AppColor.neutralGreyColor300;
    }
    return enabledLabelColor ?? AppColor.neutralGreyColor700;
  }

  /// The effective border color: explicit [errorText] takes priority so a
  /// red field border is visible even if a custom [borderColor] was set.
  Color? get _effectiveBorderColor {
    if (_hasError) return Colors.red;
    return borderColor;
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final hasPrefix = prefixText != null && prefixText!.isNotEmpty;
    final effectiveBorderColor = _effectiveBorderColor;
    final showFloatingLabel = floatingLabel && _hasLabel;

    final field = Container(
      decoration: BoxDecoration(
        color: AppColor.neutralGreyColor60,
        borderRadius: borderRadius,
        border: effectiveBorderColor != null
            ? Border.all(color: effectiveBorderColor, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      // Extra top margin makes room for the label notch cut into the
      // border, so the label doesn't overlap the field's own text.
      margin: showFloatingLabel ? const EdgeInsets.only(top: 10) : null,
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              maxLines: obscureText ? 1 : maxLines,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColor.neutralGreyColor900,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: AppColor.neutralGreyColor300),
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
    );

    return SizedBox(
      width: width,
      child: showFloatingLabel
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                field,
                Positioned(
                  left: 16,
                  top: 0,
                  child: Container(
                    // Background matches the page, not the field, so it
                    // visually "cuts" a notch out of the border line
                    // behind it — same trick Material outlined fields use.
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      labelText!,
                      softWrap: false,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _labelColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_hasLabel) ...[
                  Text(
                    labelText!,
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                field,
              ],
            ),
    );
  }
}
