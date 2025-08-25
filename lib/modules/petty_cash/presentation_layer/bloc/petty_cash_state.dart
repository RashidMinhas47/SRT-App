part of 'petty_cash_bloc.dart';

abstract class PettyCashState extends Equatable {
  const PettyCashState();
}

class PettyCashInitial extends PettyCashState {
  @override
  List<Object?> get props => [];
}

class BillPhotosChangedState extends PettyCashState {
  final List<File> photos;
  const BillPhotosChangedState(this.photos);
  @override
  List<Object?> get props => [photos];
}

class SubmitPettyCashLoadingState extends PettyCashState {
  @override
  List<Object?> get props => [];
}

class SubmitPettyCashSuccessState extends PettyCashState {
  @override
  List<Object?> get props => [];
}

class SubmitPettyCashErrorState extends PettyCashState {
  final String message;
  const SubmitPettyCashErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
