part of 'addresses_bloc.dart';

sealed class AddressesEvent extends Equatable {
  const AddressesEvent();
}

final class AddressesRequested extends AddressesEvent {
  const AddressesRequested();

  @override
  List<Object> get props => [];
}
