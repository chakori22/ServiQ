/// Money as the app writes it.
///
/// Prices arrive from the catalogue as the phrase they are displayed as
/// ("from ₹499"), but a cart and a visit both have to add them up and write
/// the answer back out, so the reading and the writing live together here
/// rather than in whichever feature needed them first.
library;

/// Pulls the rupees out of a price written for display — "from ₹499",
/// "₹1,200".
double rupeesFrom(String price) {
  final digits = RegExp(r'[\d,]+').firstMatch(price)?.group(0);
  if (digits == null) return 0;
  return double.tryParse(digits.replaceAll(',', '')) ?? 0;
}

/// "₹1,897" — an amount written the way the design writes it.
String rupees(double amount) {
  final whole = amount.round().toString();
  final buffer = StringBuffer();
  // Indian grouping is 3 then 2s, but at these amounts a plain thousands
  // separator is what the design shows.
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return '₹$buffer';
}
