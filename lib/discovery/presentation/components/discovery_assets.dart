/// Paths of the artwork exported from the discovery Figma frames.
///
/// Named here so a re-export only has to land on the same filename, and so
/// nothing has to spell an asset path out inline.
class DiscoveryAssets {
  DiscoveryAssets._();

  static const String _base = 'assets/images/discovery';

  // Area picker hero.
  static const String heroRingOuter = '$_base/hero_ring_outer.png';
  static const String heroRingInner = '$_base/hero_ring_inner.svg';
  static const String heroDotCyan = '$_base/hero_dot_a.svg';
  static const String heroDotBlue = '$_base/hero_dot_b.svg';

  // Icons.
  static const String pin = '$_base/icon_pin.svg';
  static const String pinHeader = '$_base/icon_pin_header.svg';
  static const String caretDown = '$_base/icon_caret_down.svg';
  static const String chevronRight = '$_base/icon_chevron_right.svg';
  static const String chevronLink = '$_base/icon_chevron_link.svg';
  static const String chevronOnAccent = '$_base/icon_chevron_white.svg';
  static const String search = '$_base/icon_search.svg';
  static const String chat = '$_base/icon_chat.svg';
  static const String bell = '$_base/icon_bell.svg';
  static const String back = '$_base/icon_back.svg';
  static const String backPlain = '$_base/icon_back_plain.svg';
  static const String clearGlyph = '$_base/search_clear_x.svg';
  static const String star = '$_base/icon_star.svg';
  static const String verified = '$_base/icon_verified.svg';
  static const String liveDot = '$_base/dot_live.svg';
  static const String plus = '$_base/icon_plus.svg';

  // Tab bar.
  static const String tabHomeActive = '$_base/tab_home_active.svg';
  static const String tabHomeInactive = '$_base/tab_home_inactive.svg';
  static const String tabExploreActive = '$_base/tab_explore_active.svg';
  static const String tabExploreInactive = '$_base/tab_explore_inactive.svg';
  static const String tabMe = '$_base/tab_me.svg';
}
