import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// A service category a seeker can express interest in.
///
/// Hardcoded because the backend has no categories endpoint yet — see the
/// TODO in OnboardingRepository. The labels and ordering come straight from
/// the onboarding design's 3x3 grid.
class ServiceInterest {
  final String id;
  final String label;
  final IconData icon;

  /// How the label reads mid-sentence on the closing screen. Defaults to the
  /// lowercased label, which is wrong for acronyms — "AC & RO" must not
  /// become "ac & ro" — so those spell it out explicitly.
  final String? _sentenceLabel;

  const ServiceInterest({
    required this.id,
    required this.label,
    required this.icon,
    String? sentenceLabel,
  }) : _sentenceLabel = sentenceLabel;

  String get sentenceLabel => _sentenceLabel ?? label.toLowerCase();
}

const seekerServiceInterests = [
  ServiceInterest(id: 'electrical', label: 'Electrical', icon: Icons.bolt),
  ServiceInterest(id: 'plumbing', label: 'Plumbing', icon: Icons.plumbing),
  ServiceInterest(
    id: 'cleaning',
    label: 'Cleaning',
    icon: Icons.cleaning_services_outlined,
  ),
  ServiceInterest(
    id: 'ac_ro',
    label: 'AC & RO',
    icon: Icons.ac_unit,
    sentenceLabel: 'AC & RO',
  ),
  ServiceInterest(id: 'carpentry', label: 'Carpentry', icon: Icons.carpenter),
  ServiceInterest(
    id: 'appliances',
    label: 'Appliances',
    icon: Icons.kitchen_outlined,
  ),
  ServiceInterest(id: 'beauty', label: 'Beauty', icon: Icons.spa_outlined),
  ServiceInterest(
    id: 'tutoring',
    label: 'Tutoring',
    icon: Icons.school_outlined,
  ),
  ServiceInterest(
    id: 'pest_control',
    label: 'Pest control',
    icon: Icons.pest_control,
  ),
];

/// What onboarding collects before the seeker reaches the dashboard.
///
/// Equatable so [OnboardingState] compares by value — otherwise every
/// copyWith would look like a change and rebuild every step.
class SeekerProfile extends Equatable {
  final String fullName;

  /// Free-text locality, e.g. "Ajnara Gen X" — the same shape the dashboard
  /// header displays.
  final String locality;

  /// Category ids from [seekerServiceInterests].
  final Set<String> interestIds;

  const SeekerProfile({
    this.fullName = '',
    this.locality = '',
    this.interestIds = const {},
  });

  SeekerProfile copyWith({
    String? fullName,
    String? locality,
    Set<String>? interestIds,
  }) {
    return SeekerProfile(
      fullName: fullName ?? this.fullName,
      locality: locality ?? this.locality,
      interestIds: interestIds ?? this.interestIds,
    );
  }

  /// The chosen categories in the order the grid shows them, so the closing
  /// screen reads them back in a predictable order rather than a set's.
  List<ServiceInterest> get chosenInterests => seekerServiceInterests
      .where((interest) => interestIds.contains(interest.id))
      .toList();

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'locality': locality,
    'interestIds': interestIds.toList(),
  };

  String encode() => jsonEncode(toJson());

  @override
  List<Object?> get props => [fullName, locality, interestIds];

  static SeekerProfile? decode(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return SeekerProfile(
        fullName: json['fullName'] as String? ?? '',
        locality: json['locality'] as String? ?? '',
        interestIds:
            (json['interestIds'] as List?)?.whereType<String>().toSet() ?? {},
      );
    } catch (_) {
      return null;
    }
  }
}
