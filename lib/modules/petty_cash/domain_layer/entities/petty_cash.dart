import 'package:equatable/equatable.dart';

class PettyCash extends Equatable {
  final String vendorName;
  final String description;
  final double amount;
  final DateTime date;
  final List<String> billPhotosBase64;

  const PettyCash({
    required this.vendorName,
    required this.description,
    required this.amount,
    required this.date,
    required this.billPhotosBase64,
  });

  @override
  List<Object?> get props => [vendorName, description, amount, date, billPhotosBase64];
}

