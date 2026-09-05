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
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.enabledLabelColor,
    this.width,
    this.borderColor,
    this.borderWidth = 1.0,
    this.floatingLabel = false,
    this.fillColor,
    this.cornerRadius = 12,
    this.verticalPadding = 18,
    this.textStyle,
    this.hintStyle,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
    this.textInputAction,
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

  /// Icon shown inside the field, before the text — e.g. the pin on a
  /// locality input. Sits where [prefixText] would, and the two can be used
  /// together.
  final Widget? prefixIcon;

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

  /// Fill behind the field. Defaults to the dashboard's grey; the discovery
  /// flow passes its own cooler tint so its search box matches that palette
  /// without a second field widget existing to drift from this one.
  final Color? fillColor;

  /// Corner radius of the field.
  final double cornerRadius;

  /// Space above and below the text. Lower it for a compact field such as
  /// a search box.
  final double verticalPadding;

  /// Style of the entered text. Falls back to the theme's body style.
  final TextStyle? textStyle;

  /// Style of [hintText]. Falls back to the grey placeholder.
  final TextStyle? hintStyle;

  /// Focuses the field as soon as it is shown — used by screens whose whole
  /// purpose is the field, e.g. search.
  final bool autofocus;

  final FocusNode? focusNode;

  /// Called when the keyboard's action key is pressed.
  final ValueChanged<String>? onSubmitted;

  final TextInputAction? textInputAction;

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
    final borderRadius = BorderRadius.circular(cornerRadius);
    final hasPrefix = prefixText != null && prefixText!.isNotEmpty;
    final effectiveBorderColor = _effectiveBorderColor;
    final showFloatingLabel = floatingLabel && _hasLabel;

    final field = Container(
      decoration: BoxDecoration(
        color: fillColor ?? AppColor.neutralGreyColor60,
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
          if (prefixIcon != null)
            Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: hasPrefix ? 0 : 10,
              ),
              child: prefixIcon,
            ),
          if (hasPrefix)
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 12,
                top: verticalPadding,
                bottom: verticalPadding,
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
              autofocus: autofocus,
              focusNode: focusNode,
              onSubmitted: onSubmitted,
              textInputAction: textInputAction,
              style:
                  textStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColor.neutralGreyColor900,
                  ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle:
                    hintStyle ??
                    const TextStyle(color: AppColor.neutralGreyColor300),
                suffixIcon: suffixIcon,
                errorText: errorText,
                counterText: '',
                filled: false,
                contentPadding: EdgeInsets.only(
                  left: hasPrefix || prefixIcon != null ? 0 : 20,
                  right: 20,
                  top: verticalPadding,
                  bottom: verticalPadding,
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
