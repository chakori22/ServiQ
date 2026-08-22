import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_color.dart';

/// A single pill-shaped field for entering an OTP, spacing digits out and
/// showing a red border plus [errorText] when validation fails.
class OtpInputField extends StatelessWidget {
  const OtpInputField({
    super.key,
    required this.controller,
    required this.length,
    required this.onChanged,
    this.errorText,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool autofocus;

  bool get _hasError => errorText != null && errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColor.neutralGreyColor60,
            borderRadius: borderRadius,
            border: _hasError
                ? Border.all(color: Colors.red, width: 1.5)
                : null,
          ),
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: length,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 20,
              color: AppColor.neutralGreyColor900,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 18, bottom: 18, left: 20),
            ),
            onChanged: onChanged,
          ),
        ),
        if (_hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
