import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'petty_cash_event.dart';
part 'petty_cash_state.dart';

class PettyCashBloc extends Bloc<PettyCashEvent, PettyCashState> {
  PettyCashBloc() : super(PettyCashInitial(billType: null, photos: const [])) {
    on<UploadImageEvent>((event, emit) async {
      emit(ImageUploading());
      // No remote upload here; UI-only attachment until submit
      final current = state;
      final currentPhotos = (current is PettyCashInitial)
          ? List<File>.from(current.photos)
          : <File>[];
      currentPhotos.addAll(event.photos);
      emit(ImageUploaded(currentPhotos));
    });

    on<BillTypeChangedEvent>((event, emit) {
      final currentPhotos = (state is PettyCashInitial)
          ? (state as PettyCashInitial).photos
          : (state is ImageUploaded)
              ? (state as ImageUploaded).photos
              : <File>[];
      emit(PettyCashInitial(billType: event.billType, photos: currentPhotos));
    });

    on<SubmitPettyCashEvent>((event, emit) async {
      emit(PettyCashLoading());
      try {
        // simple base64 conversion for photos; integration layer will handle uploads
        final List<String> base64Photos = [];
        for (final f in event.photos) {
          final bytes = await f.readAsBytes();
          base64Photos.add(base64Encode(bytes));
        }
        // TODO: inject use case to submit to backend; here we simulate success
        await Future.delayed(const Duration(milliseconds: 400));
        emit(PettyCashSuccess());
      } catch (e) {
        emit(PettyCashError(e.toString()));
      }
    });
  }
}

