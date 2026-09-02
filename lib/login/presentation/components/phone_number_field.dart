import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_color.dart';

/// A dialling code the login screen can offer.
class CountryCode {
  final String dialCode;
  final String flag;
  final String name;

  const CountryCode({
    required this.dialCode,
    required this.flag,
    required this.name,
  });
}

/// India is the only market today; the picker exists so adding a second one
/// is a list entry rather than a layout change.
const supportedCountryCodes = [
  CountryCode(dialCode: '+91', flag: '🇮🇳', name: 'India'),
];

/// Country selector and national number in one bordered field, turning blue
/// while focused.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.countryCode,
    required this.onCountryChanged,
    this.hintText = '98765 43210',
    this.maxLength = 10,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String countryCode;
  final ValueChanged<String> onCountryChanged;
  final String hintText;
  final int maxLength;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  CountryCode get _selected => supportedCountryCodes.firstWhere(
    (c) => c.dialCode == widget.countryCode,
    orElse: () => supportedCountryCodes.first,
  );

  Future<void> _pickCountry() async {
    final picked = await showModalBottomSheet<CountryCode>(
      context: context,
      backgroundColor: AppColor.authSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.authFieldBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            for (final country in supportedCountryCodes)
              ListTile(
                leading: Text(
                  country.flag,
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text(country.name),
                trailing: Text(
                  country.dialCode,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () => Navigator.of(sheetContext).pop(country),
              ),
          ],
        ),
      ),
    );
    if (picked != null) widget.onCountryChanged(picked.dialCode);
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 58,
      decoration: BoxDecoration(
        color: focused ? AppColor.authSurface : AppColor.authFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused ? AppColor.authAccent : AppColor.authFieldBorder,
          width: focused ? 1.6 : 1.2,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _pickCountry,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selected.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selected.dialCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColor.authTextPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColor.authTextSecondary,
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 26, color: AppColor.authFieldBorder),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.phone,
              maxLength: widget.maxLength,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColor.authTextPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                  color: AppColor.neutralGreyColor300,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
