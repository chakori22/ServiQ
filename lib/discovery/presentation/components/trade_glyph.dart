/// Maps a provider's trade to the glyph the category grid already uses for
/// it.
///
/// A provider's trade is free text — "RO Repair · Chimney", "Pest control" —
/// so it is matched loosely rather than looked up. The glyph is decoration:
/// picking a near-enough one is better than leaving a card blank, which is
/// why there is a fallback rather than a null.
class TradeGlyph {
  TradeGlyph._();

  static const String _base = 'assets/images/discovery';

  /// Anything unrecognised gets the general repair glyph.
  static const String fallback = '$_base/cat_appliance.svg';

  static const _matches = <String, String>{
    'electric': '$_base/cat_electrician.svg',
    'plumb': '$_base/cat_plumber.svg',
    'ac ': '$_base/cat_ac_repair.svg',
    'air': '$_base/cat_ac_repair.svg',
    'ro ': '$_base/cat_ro_repair.svg',
    'chimney': '$_base/cat_ro_repair.svg',
    'water': '$_base/cat_ro_repair.svg',
    'carpen': '$_base/cat_carpenter.svg',
    'wood': '$_base/cat_carpenter.svg',
  };

  /// The glyph for [trade], or [fallback] when nothing matches.
  static String forTrade(String trade) {
    final needle = trade.toLowerCase();
    for (final entry in _matches.entries) {
      if (needle.contains(entry.key)) return entry.value;
    }
    return fallback;
  }
}
