import 'package:equatable/equatable.dart';

class Spare extends Equatable {
  final int id;
  final String spareName;
  const Spare({
    required this.id,
    required this.spareName,
  });

  @override
  List<Object?> get props => [id, spareName];
}
