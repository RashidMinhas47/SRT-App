import 'dart:io';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data_layer/models/petty_cash_model.dart';
import '../../domain_layer/use_cases/submit_petty_cash_usecase.dart';

part 'petty_cash_event.dart';
part 'petty_cash_state.dart';

class PettyCashBloc extends Bloc<PettyCashEvent, PettyCashState> {
  final SubmitPettyCashUseCase submitUseCase;

  List<File> billPhotos = [];

  PettyCashBloc({required this.submitUseCase}) : super(PettyCashInitial()) {
    on<PettyCashEvent>((event, emit) async {
      if (event is AddBillPhotoEvent) {
        billPhotos.addAll(event.photos);
        emit(BillPhotosChangedState(List<File>.from(billPhotos)));
      } else if (event is RemoveBillPhotoEvent) {
        billPhotos.removeAt(event.index);
        emit(BillPhotosChangedState(List<File>.from(billPhotos)));
      } else if (event is SubmitPettyCashEvent) {
        emit(SubmitPettyCashLoadingState());
        final base64Photos = await _encodePhotos(billPhotos);
        final model = PettyCashModel(
          vendorName: event.vendorName,
          description: event.description,
          amount: event.amount,
          date: event.date,
          billPhotosBase64: base64Photos,
        );
        final result = await submitUseCase.submit(pettyCash: model);
        result.fold(
          (l) => emit(SubmitPettyCashErrorState(l.toString())),
          (r) {
            billPhotos.clear();
            emit(SubmitPettyCashSuccessState());
          },
        );
      }
    });
  }

  Future<List<String>> _encodePhotos(List<File> photos) async {
    final encoded = <String>[];
    for (final photo in photos) {
      final bytes = await photo.readAsBytes();
      encoded.add(base64Encode(bytes));
    }
    return encoded;
  }
}

