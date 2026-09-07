import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:local_markerplace/components/primary_button.dart';
import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/components/textfield.dart';
import 'package:local_markerplace/dashboard/model/post_offer.dart';
import 'package:local_markerplace/dashboard/presentation/create_post/components/composer_fields.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';

/// Offering on somebody else's requirement.
///
/// Anyone can offer — a listed provider or a neighbour — so this asks only
/// for the three things the requirement's owner actually chooses between:
/// what it will cost, when you can come, and anything they should know.
///
/// Pops with the [PostOffer], or with nothing if the sheet is dismissed.
Future<PostOffer?> showMakeOfferSheet(
  BuildContext context, {
  required String offeredBy,
}) {
  return showModalBottomSheet<PostOffer>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColor.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      // Lifts the sheet clear of the keyboard while a field has focus.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _MakeOfferSheet(offeredBy: offeredBy),
    ),
  );
}

class _MakeOfferSheet extends StatefulWidget {
  const _MakeOfferSheet({required this.offeredBy});

  final String offeredBy;

  @override
  State<_MakeOfferSheet> createState() => _MakeOfferSheetState();
}

class _MakeOfferSheetState extends State<_MakeOfferSheet> {
  final TextEditingController _price = TextEditingController();
  final TextEditingController _timing = TextEditingController();
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _price.dispose();
    _timing.dispose();
    _note.dispose();
    super.dispose();
  }

  /// A price and a time are the minimum the owner needs to compare offers;
  /// the note is theirs to add or not.
  bool get _isValid =>
      _price.text.trim().isNotEmpty && _timing.text.trim().isNotEmpty;

  void _submit() {
    Navigator.of(context).pop(
      PostOffer(
        name: widget.offeredBy,
        badge: OfferBadge.neighbour,
        price: '₹${_price.text.trim()}',
        timing: _timing.text.trim(),
        note: _note.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.discoveryBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('Make an offer', style: DiscoveryText.sheetTitle),
            const SizedBox(height: 6),
            Text(
              'The seeker sees this next to every other offer.',
              style: DiscoveryText.footnoteStrong,
            ),
            const SizedBox(height: 20),
            ComposerField(
              label: 'YOUR PRICE',
              child: AppTextField(
                controller: _price,
                hintText: '800',
                prefixText: '₹',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLines: 1,
                maxLength: 10,
                fillColor: AppColor.white,
                borderColor: AppColor.discoveryBorder,
                borderWidth: 1.4,
                cornerRadius: 16,
                verticalPadding: 14.2,
                textStyle: DiscoveryText.fieldInput,
                hintStyle: DiscoveryText.searchHint,
                onChanged: (_) => setState(() {}),
              ),
            ),
            ComposerField(
              label: 'WHEN YOU CAN COME',
              child: AppTextField(
                controller: _timing,
                hintText: 'today, 4–6 pm',
                keyboardType: TextInputType.text,
                maxLines: 1,
                maxLength: 40,
                fillColor: AppColor.white,
                borderColor: AppColor.discoveryBorder,
                borderWidth: 1.4,
                cornerRadius: 16,
                verticalPadding: 14.2,
                textStyle: DiscoveryText.fieldInput,
                hintStyle: DiscoveryText.searchHint,
                onChanged: (_) => setState(() {}),
              ),
            ),
            ComposerField(
              label: 'ANYTHING THEY SHOULD KNOW',
              child: AppTextField(
                controller: _note,
                hintText: 'Optional',
                keyboardType: TextInputType.text,
                maxLines: 3,
                maxLength: 140,
                fillColor: AppColor.white,
                borderColor: AppColor.discoveryBorder,
                borderWidth: 1.4,
                cornerRadius: 16,
                verticalPadding: 14.2,
                textStyle: DiscoveryText.fieldInput,
                hintStyle: DiscoveryText.searchHint,
              ),
            ),
            PrimaryButton(
              label: 'Send offer',
              enabled: _isValid,
              gradient: true,
              height: 56,
              gradientColors: const [
                AppColor.discoveryGradientStart,
                AppColor.discoveryGradientEnd,
              ],
              labelStyle: _isValid
                  ? DiscoveryText.onAccent(16.5, letterSpacing: -0.165)
                  : DiscoveryText.buttonDisabled,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
