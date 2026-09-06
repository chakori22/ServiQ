import 'package:local_markerplace/store/model/cart_product.dart';
import 'package:local_markerplace/visit/model/visit.dart';
import 'package:local_markerplace/visit/model/visit_mode.dart';
import 'package:local_markerplace/visit/model/visit_service.dart';
import 'package:local_markerplace/visit/model/visit_slot.dart';

/// The visit being put together, and the slots it can be booked into.
///
/// There is no booking endpoint yet, so this holds the one visit in progress
/// for the session. It is a single visit on purpose: the design is explicit
/// that a visit is one provider and one trip, so adding a service from a
/// different provider starts again rather than mixing them.
class VisitRepository {
  VisitRepository();

  static final VisitRepository shared = VisitRepository();

  Visit? _current;

  /// The visit being built, or null when nothing has been added.
  Visit? get current => _current;

  /// Visits that have been confirmed this session, newest first.
  final List<Visit> booked = <Visit>[];

  /// Adds [service] to the visit with [providerName], starting one if there
  /// is none — or replacing it when the seeker has moved to another
  /// provider, since a visit cannot span two.
  ///
  /// Returns true when an existing visit for a different provider was
  /// discarded, so the screen can say so rather than silently losing it.
  bool addService({
    required String providerName,
    required String providerLine,
    required VisitService service,
    bool isVerifiedProvider = true,
  }) {
    final existing = _current;
    final replaced = existing != null && existing.providerName != providerName;

    if (existing == null || replaced) {
      _current = Visit(
        providerName: providerName,
        providerLine: providerLine,
        isVerifiedProvider: isVerifiedProvider,
        services: [service],
      );
      return replaced;
    }

    // The same service added twice becomes one line with a bigger count,
    // which is what the stepper on the sheet is really editing.
    final services = [...existing.services];
    final index = services.indexWhere((s) => s.name == service.name);
    if (index == -1) {
      services.add(service);
    } else {
      services[index] = services[index].copyWith(
        quantity: services[index].quantity + service.quantity,
        note: service.note.isEmpty ? services[index].note : service.note,
      );
    }
    _current = existing.copyWith(services: services);
    return false;
  }

  /// Adds a part from the provider's store to the same cart the services
  /// are in.
  ///
  /// It behaves exactly like [addService] because it is the same cart: one
  /// provider, one trip. Moving to another provider's store starts again.
  bool addProduct({
    required String providerName,
    required String providerLine,
    required CartProduct product,
    bool isVerifiedProvider = true,
  }) {
    final existing = _current;
    final replaced = existing != null && existing.providerName != providerName;

    if (existing == null || replaced) {
      _current = Visit(
        providerName: providerName,
        providerLine: providerLine,
        isVerifiedProvider: isVerifiedProvider,
        parts: [product],
      );
      return replaced;
    }

    final parts = [...existing.parts];
    final index = parts.indexWhere((part) => part.name == product.name);
    if (index == -1) {
      parts.add(product);
    } else {
      parts[index] = parts[index].copyWith(
        quantity: parts[index].quantity + product.quantity,
      );
    }
    _current = existing.copyWith(parts: parts);
    return false;
  }

  void setPartQuantityAt(int index, int quantity) {
    final existing = _current;
    if (existing == null) return;
    if (quantity < 1) return removePartAt(index);
    final parts = [...existing.parts];
    parts[index] = parts[index].copyWith(quantity: quantity);
    _current = existing.copyWith(parts: parts);
  }

  void removePartAt(int index) {
    final existing = _current;
    if (existing == null) return;
    final parts = [...existing.parts]..removeAt(index);
    _current = _emptied(existing.copyWith(parts: parts));
  }

  /// A cart with nothing left in it is no cart at all.
  Visit? _emptied(Visit visit) =>
      visit.services.isEmpty && visit.parts.isEmpty ? null : visit;

  /// Changes how many of a service are wanted. Below one the line goes,
  /// which is how the cart's stepper removes it.
  void setQuantityAt(int index, int quantity) {
    final existing = _current;
    if (existing == null) return;
    if (quantity < 1) return removeServiceAt(index);
    final services = [...existing.services];
    services[index] = services[index].copyWith(quantity: quantity);
    _current = existing.copyWith(services: services);
  }

  void removeServiceAt(int index) {
    final existing = _current;
    if (existing == null) return;
    final services = [...existing.services]..removeAt(index);
    _current = _emptied(existing.copyWith(services: services));
  }

  void setMode(VisitMode mode) {
    final existing = _current;
    if (existing == null) return;
    // Instant has no slot, and leaving recurring drops the repeat — keeping
    // either would confirm something the seeker is no longer asking for.
    _current = existing.copyWith(
      mode: mode,
      clearSlot: !mode.needsSlot,
      clearRecurrence: mode != VisitMode.recurring,
      recurrence: mode == VisitMode.recurring
          ? (existing.recurrence ?? VisitRecurrence.weekly)
          : null,
    );
  }

  void setRecurrence(VisitRecurrence recurrence) {
    final existing = _current;
    if (existing == null) return;
    _current = existing.copyWith(
      mode: VisitMode.recurring,
      recurrence: recurrence,
    );
  }

  /// Keeps whichever slotted mode is showing — picking a time on the
  /// recurring tab must not silently turn the booking into a one-off.
  void setSlot(VisitSlot slot) {
    final existing = _current;
    if (existing == null) return;
    final mode = existing.mode == VisitMode.recurring
        ? VisitMode.recurring
        : VisitMode.scheduled;
    _current = existing.copyWith(mode: mode, slot: slot);
  }

  void setPayment(VisitPayment payment) {
    final existing = _current;
    if (existing == null) return;
    _current = existing.copyWith(payment: payment);
  }

  /// Books a visit straight from an accepted offer.
  ///
  /// Nothing is chosen here: the provider named a price and a time when they
  /// offered, and taking the offer agreed to both — so this skips the
  /// picker and the confirm screen and lands in [booked] already done. It
  /// deliberately leaves [current] alone, because a seeker part-way through
  /// building a visit with somebody else should not lose it by accepting an
  /// offer from a third party.
  Visit bookFromOffer({
    required String providerName,
    required String providerLine,
    required VisitService service,
    required String agreedWhen,
    bool isVerifiedProvider = true,
  }) {
    final confirmed = Visit(
      providerName: providerName,
      providerLine: providerLine,
      isVerifiedProvider: isVerifiedProvider,
      services: [service],
      agreedWhen: agreedWhen,
      reference: _nextReference(),
    );
    booked.insert(0, confirmed);
    return confirmed;
  }

  /// Books the visit and hands back the confirmed copy.
  Visit confirm() {
    final existing = _current!;
    final confirmed = existing.copyWith(reference: _nextReference());
    booked.insert(0, confirmed);
    _current = null;
    return confirmed;
  }

  void clear() => _current = null;

  int _sequence = 4820;

  String _nextReference() => 'SQ-${++_sequence}';

  /// Whether an instant visit can be placed right now.
  ///
  /// There is no dispatcher to ask yet, so this is simply true; the cart
  /// draws the design's "instant unavailable" state from it, which is what a
  /// real answer would switch off.
  bool instantAvailable = true;

  /// The next three days, each with its half-hour start times.
  ///
  /// A few are marked taken so the grid shows what a busy day looks like; a
  /// real endpoint would say which are actually free.
  List<VisitDay> days({int count = 3}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      for (var offset = 0; offset < count; offset++)
        () {
          final date = today.add(Duration(days: offset));
          return VisitDay(
            date: date,
            slots: [
              for (var half = 13; half <= 42; half++)
                VisitSlot(
                  startHour: half ~/ 2,
                  startMinute: half.isEven ? 0 : 30,
                  date: date,
                  // Starts already gone: a scattering the provider has
                  // taken, and anything already past on today's date.
                  isFree:
                      half % 7 != 6 && !(offset == 0 && half ~/ 2 <= now.hour),
                ),
            ],
          );
        }(),
    ];
  }
}
