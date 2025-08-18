part of 'petty_cash_bloc.dart';

abstract class PettyCashState extends Equatable {
  const PettyCashState();
}

class PettyCashInitial extends PettyCashState {
  final String? billType;
  final List<File> photos;
  const PettyCashInitial({required this.billType, required this.photos});
  @override
  List<Object?> get props => [billType, photos];
}

class ImageUploading extends PettyCashState {
  @override
  List<Object?> get props => [];
}

class ImageUploaded extends PettyCashState {
  final List<File> photos;
  const ImageUploaded(this.photos);
  @override
  List<Object?> get props => [photos];
}

class PettyCashLoading extends PettyCashState {
  @override
  List<Object?> get props => [];
}

class PettyCashSuccess extends PettyCashState {
  @override
  List<Object?> get props => [];
}

class PettyCashError extends PettyCashState {
  final String message;
  const PettyCashError(this.message);
  @override
  List<Object?> get props => [message];
}

