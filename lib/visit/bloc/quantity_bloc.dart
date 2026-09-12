import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'quantity_event.dart';
part 'quantity_state.dart';

/// How many of something the seeker is taking.
///
/// The two sheets that ask — a job on the add sheet, a part on its own page
/// — are the same question with a different noun, so they share this rather
/// than each keeping a number in a widget.
class QuantityBloc extends Bloc<QuantityEvent, QuantityState> {
  final double unitPrice;

  QuantityBloc({required this.unitPrice, int initial = 1})
    : super(QuantityState.initial(quantity: initial, unitPrice: unitPrice)) {
    on<QuantityChanged>(_onChanged);
  }

  void _onChanged(QuantityChanged event, Emitter<QuantityState> emit) {
    if (event.quantity < 1) return;
    emit(state.copyWith(quantity: event.quantity));
  }
}
