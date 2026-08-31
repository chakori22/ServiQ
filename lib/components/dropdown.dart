import 'package:flutter/material.dart';

import '../core/app_color.dart';

/// A themed dropdown field, styled identically to [AppTextField].
/// Uses [showMenu] instead of the stock [DropdownButton] so the menu
/// reliably opens BELOW the field, matches its width, and has proper
/// item padding — the built-in DropdownButton menu doesn't guarantee any
/// of that and can render misaligned depending on available screen space.
///
/// The field manages its OWN selected value internally, so tapping an
/// option updates what's displayed immediately without the parent needing
/// to feed a new [value] back in via setState. [onChanged] is purely a
/// notification callback — pass it if the parent needs to react to the
/// selection (e.g. update other form state), but it's optional.
class AppDropdownField<T> extends StatefulWidget {
  const AppDropdownField({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.enabled = true,
    this.prefixText,
    this.errorText,
    this.enabledLabelColor,
    this.width,
    this.borderColor,
    this.borderWidth = 1.0,
    this.floatingLabel = false,
  });

  /// Initial selected value. After the first build, selection is tracked
  /// internally — updating this from the parent later will NOT force a
  /// change (see [didUpdateWidget] note below if you need that instead).
  final T? value;

  final List<AppDropdownItem<T>> items;

  /// Optional callback fired after the field updates its own displayed
  /// value, letting the parent react to the change if needed.
  final ValueChanged<T?>? onChanged;

  final String? labelText;
  final String? hintText;
  final bool enabled;
  final String? prefixText;
  final String? errorText;
  final Color? enabledLabelColor;
  final double? width;
  final Color? borderColor;
  final double borderWidth;
  final bool floatingLabel;

  @override
  State<AppDropdownField<T>> createState() => _AppDropdownFieldState<T>();
}

class _AppDropdownFieldState<T> extends State<AppDropdownField<T>> {
  final GlobalKey _fieldKey = GlobalKey();

  /// Tracked internally so the field can update itself the moment an
  /// option is picked, independent of whether the parent re-passes [value].
  late T? _selectedValue = widget.value;

  /// Drives the chevron rotation: true while the menu is open.
  bool _isExpanded = false;

  @override
  void didUpdateWidget(covariant AppDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent explicitly passes a new `value`, respect it (e.g. a
    // form-reset case). Internal selections in between don't get
    // overwritten unless the parent's value actually changes.
    if (oldWidget.value != widget.value) {
      _selectedValue = widget.value;
    }
  }

  bool get _hasLabel =>
      widget.labelText != null && widget.labelText!.isNotEmpty;
  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  Color get _labelColor {
    if (_hasError) return Colors.red;
    if (!widget.enabled) return AppColor.neutralGreyColor300;
    return widget.enabledLabelColor ?? AppColor.neutralGreyColor700;
  }

  Color? get _effectiveBorderColor {
    if (_hasError) return Colors.red;
    return widget.borderColor;
  }

  Future<void> _openMenu() async {
    if (!widget.enabled) return;

    final renderBox = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final fieldSize = renderBox.size;
    final fieldOffset = renderBox.localToGlobal(Offset.zero);

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromLTWH(
        fieldOffset.dx,
        fieldOffset.dy + fieldSize.height + 4,
        fieldSize.width,
        0,
      ),
      Offset.zero & overlay.size,
    );

    setState(() => _isExpanded = true);

    final selected = await showMenu<T>(
      context: context,
      position: position,
      constraints: BoxConstraints(
        minWidth: fieldSize.width,
        maxWidth: fieldSize.width,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 4,
      items: widget.items
          .map(
            (item) => PopupMenuItem<T>(
              value: item.value,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColor.neutralGreyColor900,
                  fontWeight: item.value == _selectedValue
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          )
          .toList(),
    );

    // Menu is closed either way (item picked or dismissed) — flip the
    // chevron back regardless of the outcome.
    if (!mounted) return;
    setState(() {
      _isExpanded = false;
      if (selected != null) {
        _selectedValue = selected;
      }
    });

    if (selected != null) {
      widget.onChanged?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);
    final hasPrefix =
        widget.prefixText != null && widget.prefixText!.isNotEmpty;
    final effectiveBorderColor = _effectiveBorderColor;
    final showFloatingLabel = widget.floatingLabel && _hasLabel;

    final selectedLabel = widget.items
        .where((item) => item.value == _selectedValue)
        .map((item) => item.label)
        .firstOrNull;

    final field = Material(
      color: Colors.transparent,
      child: InkWell(
        key: _fieldKey,
        onTap: _openMenu,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.neutralGreyColor60,
            borderRadius: borderRadius,
            border: effectiveBorderColor != null
                ? Border.all(
                    color: effectiveBorderColor,
                    width: widget.borderWidth,
                  )
                : null,
          ),
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
                    widget.prefixText!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColor.neutralGreyColor900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: hasPrefix ? 0 : 20,
                    right: 12,
                    top: 18,
                    bottom: 18,
                  ),
                  child: Text(
                    selectedLabel ?? widget.hintText ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selectedLabel != null
                          ? AppColor.neutralGreyColor900
                          : AppColor.neutralGreyColor300,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                // Rotates to point up while the menu is open, back down
                // once it's closed — mirrors the collapsed/expanded
                // chevron behavior from the accordion pattern.
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: widget.enabled
                        ? AppColor.neutralGreyColor700
                        : AppColor.neutralGreyColor300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return SizedBox(
      width: widget.width,
      child: showFloatingLabel
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                field,
                Positioned(
                  left: 16,
                  top: 0,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      widget.labelText!,
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
                    widget.labelText!,
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
                if (_hasError) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
    );
  }
}

/// A single selectable option for [AppDropdownField].
class AppDropdownItem<T> {
  const AppDropdownItem({required this.value, required this.label});

  final T value;
  final String label;
}
