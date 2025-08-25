import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data_layer/data_sources/petty_cash_remote_data_source.dart';
import '../../data_layer/models/petty_cash_model.dart';

part 'pending_bills_event.dart';
part 'pending_bills_state.dart';

class PendingBillsBloc extends Bloc<PendingBillsEvent, PendingBillsState> {
  final PettyCashRemoteDataSource remoteDataSource;

  PendingBillsBloc({required this.remoteDataSource})
      : super(PendingBillsInitial()) {
    on<LoadPendingBillsEvent>(_onLoadPendingBills);
    on<CompleteAdvancePaymentEvent>(_onCompleteAdvancePayment);
  }

  Future<void> _onLoadPendingBills(
    LoadPendingBillsEvent event,
    Emitter<PendingBillsState> emit,
  ) async {
    emit(PendingBillsLoading());

    final result = await remoteDataSource.getPendingBills();

    result.fold(
      (exception) => emit(PendingBillsError(exception.toString())),
      (bills) => emit(PendingBillsLoaded(bills)),
    );
  }

  Future<void> _onCompleteAdvancePayment(
    CompleteAdvancePaymentEvent event,
    Emitter<PendingBillsState> emit,
  ) async {
    emit(PendingBillsLoading());

    // Convert File objects to base64 strings
    final List<String> base64Photos = [];
    for (final photo in event.billPhotos) {
      final bytes = await photo.readAsBytes();
      base64Photos.add(base64Encode(bytes));
    }

    final result = await remoteDataSource.completeAdvancePayment(
      advanceId: event.advanceId,
      vendorName: event.vendorName,
      actualAmount: event.actualAmount,
      billPhotos: base64Photos,
    );

    result.fold(
      (exception) => emit(PendingBillsError(exception.toString())),
      (bill) => emit(AdvancePaymentCompleted(bill)),
    );
  }
}
