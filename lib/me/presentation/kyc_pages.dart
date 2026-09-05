import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:local_markerplace/core/app_color.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_assets.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_header.dart';
import 'package:local_markerplace/discovery/presentation/components/discovery_text.dart';
import 'package:local_markerplace/me/model/kyc_document.dart';
import 'package:local_markerplace/me/presentation/components/me_components.dart';
import 'package:local_markerplace/me/repository/me_repository.dart';

const _privacyNote =
    'Uploaded privately. Links expire after 15 minutes and are never shared '
    'with providers.';

/// 04 · KYC — list. What the seeker has submitted and where each one stands.
class KycListPage extends StatelessWidget {
  const KycListPage({super.key, this.repository = const MeRepository()});

  final MeRepository repository;

  @override
  Widget build(BuildContext context) {
    final documents = repository.documents();

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DiscoveryHeader(title: 'Identity verification'),
            const SizedBox(height: 6),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  Text(
                    'Verified members get the Provider check on their '
                    'profile. Documents are private — only you and a reviewer '
                    'can open them.',
                    style: DiscoveryText.publicNote,
                  ),
                  const SizedBox(height: 18),
                  for (final document in documents) ...[
                    _DocumentCard(
                      document: document,
                      onReupload: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => KycRejectedPage(document: document),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const SizedBox(height: 6),
                  OutlinedActionButton(
                    label: 'Add a document',
                    leading: SvgPicture.asset(
                      DiscoveryAssets.plus,
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColor.discoveryGradientEnd,
                        BlendMode.srcIn,
                      ),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => KycUploadPage(repository: repository),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const PrivacyNote(message: _privacyNote),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document, this.onReupload});

  final KycDocument document;
  final VoidCallback? onReupload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13.2),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.discoveryBorder, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: AppColor.discoveryShadow.withValues(alpha: 0.05),
            blurRadius: 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  document.type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DiscoveryText.rowTitle,
                ),
              ),
              KycStatusPill(status: document.status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  document.statusLine,
                  style: DiscoveryText.statusDate,
                ),
              ),
              if (document.isRejected)
                GestureDetector(
                  onTap: onReupload,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'Re-upload',
                    style: DiscoveryText.inlineLink.copyWith(
                      color: AppColor.kycRejectText,
                    ),
                  ),
                ),
            ],
          ),
          if (document.rejectionReason != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.kycRejectTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                document.rejectionReason!,
                style: DiscoveryText.rejectionReason,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 05 · KYC — upload. Picking a type, adding both sides, and the tips that
/// keep a submission from bouncing.
class KycUploadPage extends StatefulWidget {
  const KycUploadPage({super.key, this.repository = const MeRepository()});

  final MeRepository repository;

  @override
  State<KycUploadPage> createState() => _KycUploadPageState();
}

class _KycUploadPageState extends State<KycUploadPage> {
  late String _type = widget.repository.documentTypes().first;
  bool _hasFront = true;
  bool _hasBack = false;

  bool get _canSubmit => _hasFront && _hasBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DiscoveryHeader(title: 'Add a document'),
            const SizedBox(height: 6),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  Text('DOCUMENT TYPE', style: DiscoveryText.fieldLabel),
                  const SizedBox(height: 8),
                  _TypeField(value: _type, onTap: _pickType),
                  const SizedBox(height: 24),
                  _SideLabel(
                    label: 'FRONT SIDE',
                    action: _hasFront ? 'Replace' : null,
                    onAction: () => setState(() => _hasFront = true),
                  ),
                  const SizedBox(height: 8),
                  _UploadTarget(
                    isFilled: _hasFront,
                    onTap: () => setState(() => _hasFront = !_hasFront),
                  ),
                  const SizedBox(height: 24),
                  _SideLabel(
                    label: 'BACK SIDE',
                    action: _hasBack ? 'Replace' : null,
                    onAction: () => setState(() => _hasBack = true),
                  ),
                  const SizedBox(height: 8),
                  _UploadTarget(
                    isFilled: _hasBack,
                    onTap: () => setState(() => _hasBack = !_hasBack),
                  ),
                  const SizedBox(height: 22),
                  const TipsBox(
                    heading: 'AVOIDS THE USUAL REJECTIONS',
                    tips: [
                      'All four corners visible',
                      'Good light, no glare',
                      'Name matches your profile',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SubmitButton(
                    label: _canSubmit
                        ? 'Submit for review'
                        : 'Add the back side to submit',
                    isEnabled: _canSubmit,
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              '$_type submitted for review.',
                              style: DiscoveryText.heroSubtitle.copyWith(
                                color: AppColor.white,
                              ),
                            ),
                          ),
                        );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickType() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColor.discoveryBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 22),
            for (final type in widget.repository.documentTypes())
              ListTile(
                title: Text(type, style: DiscoveryText.sheetOption),
                onTap: () => Navigator.of(context).pop(type),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _type = chosen);
  }
}

class _SideLabel extends StatelessWidget {
  const _SideLabel({required this.label, this.action, this.onAction});

  final String label;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: DiscoveryText.fieldLabel),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(
              action!,
              style: DiscoveryText.inlineLink.copyWith(fontSize: 12.5),
            ),
          ),
      ],
    );
  }
}

class _TypeField extends StatelessWidget {
  const _TypeField({required this.value, this.onTap});

  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.discoveryAccent, width: 1.8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(value, style: DiscoveryText.fieldInput)),
            SvgPicture.asset(
              DiscoveryAssets.caretDown,
              width: 9.7,
              height: 5.7,
            ),
          ],
        ),
      ),
    );
  }
}

/// Either the uploaded document's preview, or the dashed target that invites
/// one.
class _UploadTarget extends StatelessWidget {
  const _UploadTarget({required this.isFilled, this.onTap});

  final bool isFilled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isFilled) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SvgPicture.asset(
          DiscoveryAssets.uploadPreview,
          height: 168,
          fit: BoxFit.fitWidth,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: const _DashedBorderPainter(),
        child: Container(
          height: 132,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.discoveryTint,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _CameraGlyph(),
              const SizedBox(height: 20),
              Text(
                'Take a photo or choose a file',
                style: DiscoveryText.uploadPrompt,
              ),
              const SizedBox(height: 6),
              Text(
                'JPG or PNG, under 5 MB',
                style: DiscoveryText.smallPrint.copyWith(
                  color: AppColor.discoveryTextDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma draws the camera out of rectangles rather than a vector, so there is
/// no glyph to export — it is rebuilt the same way.
class _CameraGlyph extends StatelessWidget {
  const _CameraGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 0,
            child: Container(
              width: 8,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.discoveryTextTertiary,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
          Positioned(
            top: 3,
            child: Container(
              width: 24,
              height: 18,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.discoveryTextTertiary,
                  width: 1.8,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColor.discoveryTextTertiary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColor.uploadDashedBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      );

    // Walks the rounded rectangle and draws a 6pt dash every 11pt.
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.isEnabled,
    this.onTap,
  });

  final String label;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isEnabled ? null : AppColor.buttonDisabledFill,
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [
                    AppColor.discoveryGradientStart,
                    AppColor.discoveryGradientEnd,
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isEnabled
                ? DiscoveryText.onAccent(16, letterSpacing: -0.16)
                : DiscoveryText.buttonDisabled,
          ),
        ),
      ),
    );
  }
}

/// 06 · KYC — rejected. The reviewer's reason, verbatim, and the way back in.
class KycRejectedPage extends StatelessWidget {
  const KycRejectedPage({super.key, required this.document});

  final KycDocument document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DiscoveryHeader(title: document.type),
            const SizedBox(height: 6),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColor.discoveryBorder,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  _RejectedBand(document: document),
                  const SizedBox(height: 18),
                  Text(
                    'That is the reviewer’s note, word for word. Fix just '
                    'that and re-upload — the rest of your submission is '
                    'kept.',
                    style: DiscoveryText.publicNote,
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    children: [
                      // The rejected preview, which carries no approval tick
                      // — the uploaded state's does, and it would contradict
                      // the pill sitting on top of it.
                      SvgPicture.asset(
                        DiscoveryAssets.rejectedPreview,
                        height: 150,
                        fit: BoxFit.fitWidth,
                      ),
                      const Positioned(
                        right: 16,
                        top: 16,
                        child: KycStatusPill(status: KycStatus.rejected),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const TipsBox(
                    heading: 'BEFORE YOU RETAKE IT',
                    tips: [
                      'Lay it flat, not in your hand',
                      'Daylight, no flash',
                      'All four corners in frame',
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SubmitButton(
                    label: 'Retake and re-upload',
                    isEnabled: true,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'Something wrong with this decision? Contact support',
                      style: DiscoveryText.smallPrint.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RejectedBand extends StatelessWidget {
  const _RejectedBand({required this.document});

  final KycDocument document;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.kycRejectTint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      DiscoveryAssets.rejectDisc,
                      width: 32,
                      height: 32,
                    ),
                    // The exclamation is two rectangles in the design, not a
                    // glyph, so it is drawn rather than loaded.
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 1.8,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: 2.6,
                          height: 2.6,
                          decoration: const BoxDecoration(
                            color: AppColor.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Not accepted', style: DiscoveryText.rejectedTitle),
                    const SizedBox(height: 4),
                    Text(
                      document.statusLine.replaceFirst('Rejected', 'Reviewed'),
                      style: DiscoveryText.statusDate.copyWith(
                        color: AppColor.kycRejectText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '“${document.rejectionReason ?? ''}”',
            style: DiscoveryText.rejectedQuote,
          ),
        ],
      ),
    );
  }
}
