part of 'addresses_bloc.dart';

class AddressesState extends Equatable {
  final List<SavedAddress> addresses;
  final bool isLoading;

  const AddressesState({required this.addresses, required this.isLoading});

  const AddressesState.initial({
    this.addresses = const [],
    this.isLoading = true,
  });

  AddressesState copyWith({List<SavedAddress>? addresses, bool? isLoading}) {
    return AddressesState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [addresses, isLoading];
}
