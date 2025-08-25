import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/domain.dart';
import 'petty_cash_event.dart';
import 'petty_cash_state.dart';

class PettyCashBloc extends Bloc<PettyCashEvent, PettyCashState> {
  final SubmitPettyCashBill submitPettyCashBill;
  final CompleteAdvancePayment completeAdvancePayment;
  final GetUserBills getUserBills;
  final GetPendingAdvances getPendingAdvances;
  final UpdateBillStatus updateBillStatus;
  final ExportToExcel exportToExcel;
  final UploadPhoto uploadPhoto;

  PettyCashBloc({
    required this.submitPettyCashBill,
    required this.completeAdvancePayment,
    required this.getUserBills,
    required this.getPendingAdvances,
    required this.updateBillStatus,
    required this.exportToExcel,
    required this.uploadPhoto,
  }) : super(const PettyCashInitial()) {
    on<SubmitBillEvent>(_onSubmitBill);
    on<SelectBillTypeEvent>(_onSelectBillType);
    on<UploadPhotoEvent>(_onUploadPhoto);
    on<LoadUserBillsEvent>(_onLoadUserBills);
    on<LoadPendingAdvancesEvent>(_onLoadPendingAdvances);
    on<CompleteAdvanceEvent>(_onCompleteAdvance);
    on<UpdateBillStatusEvent>(_onUpdateBillStatus);
    on<ExportToExcelEvent>(_onExportToExcel);
    on<ClearPhotoEvent>(_onClearPhoto);
    on<ResetFormEvent>(_onResetForm);
  }

  Future<void> _onSubmitBill(
    SubmitBillEvent event,
    Emitter<PettyCashState> emit,
  ) async {
    emit(const PettyCashLoading());

    final result = await submitPettyCashBill(event.bill);

    result.fold(
      (exception) => emit(PettyCashError(exception.toString())),
      (bill) => emit(BillSubmittedSuccess(bill)),
    );
  }

  void _onSelectBillType(
    SelectBillTypeEvent event,
    Emitter<PettyCashState> emit,
  ) {
    emit(BillTypeSelected(event.billType));
  }

  Future<void> _onUploadPhoto(
    UploadPhotoEvent event,
    Emitter<PettyCashState> emit,
  ) async {
    emit(const PettyCashLoading());

    final result = await uploadPhoto(event.photoFile.path);

    result.fold(
      (exception) => emit(PettyCashError(exception.toString())),
      (photoUrl) => emit(PhotoUploaded(
        photoFile: event.photoFile,
        photoUrl: photoUrl,
      )),
    );
  }

  Future<void> _onLoadUserBills(
    LoadUserBillsEvent event,
    Emitter<PettyCashState> emit,
  ) async {
    emit(const PettyCashLoading());

    final result = await getUserBills(event.userId);

    result.fold(
      (exception) => emit(PettyCashError(exception.toString())),
      (bills) => emit(UserBillsLoaded(bills)),
    );
  }

  Future<void> _onLoadPendingAdvances(
    LoadPendingAdvancesEvent event,
    Emitter<PettyCashState> emit,
  ) async {
    emit(const PettyCashLoading());

    final result = await getPendingAdvances(event.userId);

    result.fold(
      (exception) => emit(PettyCashError(exception.toString())),
      (advances) => emit(PendingAdvancesLoaded(advances)),
    );
  }

  Future<void> _onCompleteAdvance(
    CompleteAdvanceEvent event,
    Emitter<PettyCashState> emit,
  ) async {
    emit(const PettyCashLoading());

    final result = await completeAdvancePayment(
      billId: event.billId,
      advanceId: event.advanceId,
    );

    result.fold(
      (exception) => emit(PettyCashError(exception.toString())),
      (bill) => emit(AdvanceCompleted(bill)),
    );
  }

  Future<void> _onUpdateBillStatus(
    UpdateBillStatusEvent event,
    Emitter<PettyCashState> emit,
  ) async {
    emit(const PettyCashLoading());

    final result = await updateBillStatus(
      billId: event.billId,
      status: event.status,
      adminComments: event.adminComments,
    );

    result.fold(
      (exception) => emit(PettyCashError(exception.toString())),
      (bill) => emit(BillStatusUpdated(bill)),
    );
  }

  Future<void> _onExportToExcel(
    ExportToExcelEvent event,
    Emitter<PettyCashState> emit,
  ) async {
    emit(const PettyCashLoading());

    final result = await exportToExcel(
      userId: event.userId,
      status: event.status,
      billType: event.billType,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (exception) => emit(PettyCashError(exception.toString())),
      (filePath) => emit(ExcelExported(filePath)),
    );
  }

  void _onClearPhoto(
    ClearPhotoEvent event,
    Emitter<PettyCashState> emit,
  ) {
    emit(const PhotoCleared());
  }

  void _onResetForm(
    ResetFormEvent event,
    Emitter<PettyCashState> emit,
  ) {
    emit(const FormReset());
  }
}
