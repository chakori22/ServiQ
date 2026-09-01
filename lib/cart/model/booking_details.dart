import 'package:equatable/equatable.dart';

/// Where the professional is going and who they are meeting there.
class BookingDetails extends Equatable {
  final String address;
  final String customerName;
  final String customerPhone;

  const BookingDetails({
    required this.address,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  List<Object?> get props => [address, customerName, customerPhone];
}
