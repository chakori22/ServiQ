import 'package:flutter/material.dart';

/// Turns the icon name the server sends into something drawable.
///
/// The categories come from the API as names — "wrench", "bolt", "snow" —
/// not as assets, and there are twenty-three of them against the six SVGs the
/// design shipped. Material's set covers them recognisably, and an unknown
/// name falls back rather than leaving a hole: a new category should appear
/// the day the server adds it, not the day the app ships an icon for it.
IconData categoryIconFor(String name) => switch (name) {
  'wrench' => Icons.handyman_outlined,
  'bolt' => Icons.bolt_outlined,
  'droplet' => Icons.water_drop_outlined,
  'plug' => Icons.electrical_services_outlined,
  'snow' => Icons.ac_unit_rounded,
  'water' => Icons.opacity_rounded,
  'saw' => Icons.carpenter_outlined,
  'brush' => Icons.format_paint_outlined,
  'broom' => Icons.cleaning_services_outlined,
  'bug' => Icons.pest_control_outlined,
  'box' => Icons.local_shipping_outlined,
  'scissors' => Icons.content_cut_rounded,
  'book' => Icons.menu_book_outlined,
  'dumbbell' => Icons.fitness_center_rounded,
  'camera' => Icons.photo_camera_outlined,
  'laptop' => Icons.laptop_mac_rounded,
  'phone' => Icons.smartphone_rounded,
  'bike' => Icons.pedal_bike_rounded,
  'car' => Icons.directions_car_outlined,
  'paw' => Icons.pets_rounded,
  'leaf' => Icons.local_florist_outlined,
  'store' => Icons.storefront_outlined,
  'shop' => Icons.store_mall_directory_outlined,
  _ => Icons.home_repair_service_outlined,
};
