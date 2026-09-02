import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_color.dart';

/// The status line under the OTP boxes, which the verification screen drives.
enum OtpFieldStatus {
  /// Nothing typed yet — the screen is watching for an SMS.
  awaitingSms,

  /// A complete code arrived in one go, from autofill or a paste.
  filled,

  /// The user is typing, or has typed a full code by hand. Nothing is
  /// claimed, because saying "detected from SMS" over a hand-typed code
  /// would be a lie about where it came from.
  none,

  /// The server rejected the code; [OtpInputField.errorText] carries why.
  error,
}

/// Six separate boxes for entering an OTP.
///
/// A single hidden [TextField] holds the value and the boxes are painted from
/// it, so platform autofill (`AutofillHints.oneTimeCode`), paste and the
/// system keyboard all behave normally — reproducing that across six real
/// fields means fighting focus on every keystroke.
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    required this.controller,
    required this.length,
    required this.onChanged,
    this.errorText,
    this.autofocus = false,
    this.status = OtpFieldStatus.awaitingSms,
    this.statusLabel,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool autofocus;
  final OtpFieldStatus status;

  /// Overrides the default copy for [status]; the error message always comes
  /// from [errorText] instead.
  final String? statusLabel;

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField> {
  final _focusNode = FocusNode();

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => requestFocus());
    }
  }

  void _onTextChanged() => setState(() {});

  /// Lets the screen put the caret back after "Paste" or a resend.
  void requestFocus() {
    if (mounted) _focusNode.requestFocus();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  Color _borderColor(int index, String value) {
    if (_hasError) return AppColor.authError;
    final isNext = index == value.length && _focusNode.hasFocus;
    if (index < value.length || isNext) return AppColor.authAccent;
    return AppColor.authFieldBorder;
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 0.86,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _hasError
                              ? AppColor.authErrorTint
                              : AppColor.authFieldFill,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _borderColor(i, value),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          i < value.length ? value[i] : '',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _hasError
                                ? AppColor.authError
                                : AppColor.authTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            // The real field, stretched over the boxes and made invisible, so
            // a tap anywhere on the row opens the keyboard at the right spot.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  maxLength: widget.length,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
            ),
          ],
        ),
        if (_hasError || widget.status != OtpFieldStatus.none) ...[
          const SizedBox(height: 10),
          _StatusLine(
            status: _hasError ? OtpFieldStatus.error : widget.status,
            errorText: widget.errorText,
            label: widget.statusLabel,
          ),
        ],
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.status, this.errorText, this.label});

  final OtpFieldStatus status;
  final String? errorText;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (IconData? icon, Color color, String text) = switch (status) {
      OtpFieldStatus.error => (
        Icons.error_outline,
        AppColor.authError,
        errorText ?? 'Incorrect code',
      ),
      OtpFieldStatus.filled => (
        Icons.check_circle_outline,
        AppColor.authSuccess,
        label ?? 'Code detected from SMS',
      ),
      OtpFieldStatus.awaitingSms => (
        Icons.autorenew,
        AppColor.authTextSecondary,
        label ?? 'Auto-detecting the code from your SMS…',
      ),
      // Never rendered: the field skips the status line entirely for `none`.
      OtpFieldStatus.none => (null, AppColor.authTextSecondary, ''),
    };

    return Row(
      mainAxisAlignment: status == OtpFieldStatus.error
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: status == OtpFieldStatus.awaitingSms
                  ? FontWeight.w400
                  : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
