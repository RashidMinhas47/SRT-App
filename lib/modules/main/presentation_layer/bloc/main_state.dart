part of 'main_bloc.dart';

abstract class MainState extends Equatable {
  const MainState();
}

class MainInitial extends MainState {
  @override
  List<Object> get props => [];
}

class SelectPropertySiteState extends MainState {
  final String propertySite;

  const SelectPropertySiteState({required this.propertySite});

  @override
  List<Object> get props => [propertySite];
}

class SelectAcTypeState extends MainState {
  final String acType;

  const SelectAcTypeState({required this.acType});

  @override
  List<Object> get props => [acType];
}

class SelectWorkStatusState extends MainState {
  final String workStatus;

  const SelectWorkStatusState({required this.workStatus});

  @override
  List<Object> get props => [workStatus];
}

class SelectServiceTypeState extends MainState {
  final String serviceType;
  final int serviceTypeId;

  const SelectServiceTypeState(
      {required this.serviceType, required this.serviceTypeId});

  @override
  List<Object> get props => [serviceType];
}

class SelectSpareState extends MainState {
  final String spare;

  const SelectSpareState({required this.spare});

  @override
  List<Object> get props => [spare];
}

class SelectCategoryState extends MainState {
  final String category;

  const SelectCategoryState({required this.category});

  @override
  List<Object> get props => [category];
}

class SelectSubState extends MainState {
  final String sub;

  const SelectSubState({required this.sub});

  @override
  List<Object> get props => [sub];
}

class SelectAmcCardPropertyState extends MainState {
  final String property;
  final int propertyIndex;

  const SelectAmcCardPropertyState(
      {required this.property, required this.propertyIndex});

  @override
  List<Object> get props => [property, propertyIndex];
}

class SelectTypeOfServiceState extends MainState {
  final String selectedTypeOfService;

  const SelectTypeOfServiceState({required this.selectedTypeOfService});

  @override
  List<Object> get props => [selectedTypeOfService];
}

class SelectAmcCardAcTypeState extends MainState {
  final String acType;

  const SelectAmcCardAcTypeState({required this.acType});

  @override
  List<Object> get props => [acType];
}

class AddToListAmcReportState extends MainState {
  final int index;
  final List<int> list;

  const AddToListAmcReportState({
    required this.index,
    required this.list,
  });

  @override
  List<Object> get props => [index];
}

class RemoveFromListAmcReportState extends MainState {
  final int index;
  final List<int> list;

  const RemoveFromListAmcReportState({
    required this.index,
    required this.list,
  });

  @override
  List<Object> get props => [index];
}

class AddToAmcCardQuestionListState extends MainState {
  final int index;

  const AddToAmcCardQuestionListState({
    required this.index,
  });

  @override
  List<Object> get props => [index];
}

class RemoveFromAmcCardQuestionListState extends MainState {
  final int index;

  const RemoveFromAmcCardQuestionListState({
    required this.index,
  });

  @override
  List<Object> get props => [index];
}

class SubmitAmcReportSuccessfullyState extends MainState {
  const SubmitAmcReportSuccessfullyState();

  @override
  List<Object> get props => [];
}

class ReviewReportLoadingState extends MainState {
  const ReviewReportLoadingState();

  @override
  List<Object> get props => [];
}

class ReviewReportState extends MainState {
  const ReviewReportState();

  @override
  List<Object> get props => [];
}

class SubmitAmcReportLoadingState extends MainState {
  const SubmitAmcReportLoadingState();

  @override
  List<Object> get props => [];
}

class SubmitAmcCardReportSuccessfullyState extends MainState {
  @override
  List<Object> get props => [];
}

class SubmitAmcCardReportLoadingState extends MainState {
  @override
  List<Object> get props => [];
}

class SaveFaultDataSuccessfullyState extends MainState {
  final FaultFormModel faultFormModel;

  const SaveFaultDataSuccessfullyState(this.faultFormModel);

  @override
  List<Object?> get props => [];
}

class SaveFaultDataLoadingState extends MainState {
  @override
  List<Object?> get props => [];
}

class SaveFaultDataErrorState extends MainState {
  final String error;

  const SaveFaultDataErrorState(this.error);

  @override
  List<Object> get props => [];
}

// UpdateFaultData
class UpdateFaultDataSuccessfullyState extends MainState {
  final FaultFormModel faultFormModel;

  const UpdateFaultDataSuccessfullyState(this.faultFormModel);

  @override
  List<Object?> get props => [];
}

class RemoveImageState extends MainState {
  final String image;

  const RemoveImageState(this.image);

  @override
  List<Object?> get props => [image];
}

// DeleteFaultData
class DeleteFaultDataSuccessfullyState extends MainState {
  final FaultFormModel faultFormModel;

  const DeleteFaultDataSuccessfullyState(this.faultFormModel);

  @override
  List<Object?> get props => [];
}

class DeleteFaultDataLoadingState extends MainState {
  @override
  List<Object?> get props => [];
}

class DeleteFaultDataErrorState extends MainState {
  final String error;

  const DeleteFaultDataErrorState(this.error);

  @override
  List<Object?> get props => [];
}

class UpdateFaultDataLoadingState extends MainState {
  @override
  List<Object?> get props => [];
}

class UpdateFaultDataErrorState extends MainState {
  final String error;

  const UpdateFaultDataErrorState(this.error);

  @override
  List<Object> get props => [];
}

class CheckIsAcBeforeState extends MainState {
  final bool isAcBefore;

  const CheckIsAcBeforeState(this.isAcBefore);

  @override
  List<Object> get props => [];
}

class AddServiceTypeToListState extends MainState {
  final ServiceTypeModel serviceType;

  const AddServiceTypeToListState(this.serviceType);

  @override
  List<Object> get props => [];
}

class AddSparesBuilderToListState extends MainState {
  const AddSparesBuilderToListState();

  @override
  List<Object> get props => [];
}

class RemoveFromServiceTypeListState extends MainState {
  final ServiceTypeModel serviceType;

  const RemoveFromServiceTypeListState(this.serviceType);

  @override
  List<Object> get props => [serviceType];
}

class SubmitFaultReportSuccessfullyState extends MainState {
  const SubmitFaultReportSuccessfullyState();

  @override
  List<Object> get props => [];
}

class AddFaultReportSuccessfullyState extends MainState {
  const AddFaultReportSuccessfullyState();

  @override
  List<Object> get props => [];
}

class SubmitFaultReportLoadingState extends MainState {
  const SubmitFaultReportLoadingState();

  @override
  List<Object> get props => [];
}

class SubmitFaultReportErrorState extends MainState {
  const SubmitFaultReportErrorState();

  @override
  List<Object> get props => [];
}

class GetPDFSuccessfullyState extends MainState {
  final String pdf;

  const GetPDFSuccessfullyState(this.pdf);

  @override
  List<Object?> get props => [];
}

class GetPDFErrorState extends MainState {
  const GetPDFErrorState();

  @override
  List<Object?> get props => [];
}

class ClosePDFState extends MainState {
  const ClosePDFState();

  @override
  List<Object?> get props => [];
}

// class GetJobCardSuccessfullyState extends MainState {
//   final BuildContext context;
//   final List<JobCard> jobCards;

//   const GetJobCardSuccessfullyState(this.context, this.jobCards);

//   @override
//   List<Object> get props => [jobCards];
// }

//New State Added
class JobCardsBatchLoadingState extends MainState {
  final List<JobCard> jobCards;

  const JobCardsBatchLoadingState(this.jobCards);

  @override
  List<Object> get props => [jobCards];
}

class GetJobCardSuccessfullyState extends MainState {
  final List<JobCard> jobCards;

  const GetJobCardSuccessfullyState(this.jobCards);

  @override
  List<Object> get props => [jobCards];
}

// class GetJobCardSuccessfullyState extends MainState {
//   final BuildContext context;

//   const GetJobCardSuccessfullyState(this.context);

//   @override
//   List<Object> get props => [];
// }

class AcceptJobCardSuccessfullyState extends MainState {
  const AcceptJobCardSuccessfullyState();

  @override
  List<Object> get props => [];
}

class IgnoreJobCardSuccessfullyState extends MainState {
  const IgnoreJobCardSuccessfullyState();

  @override
  List<Object> get props => [];
}

class GetJobCardErrorState extends MainState {
  const GetJobCardErrorState();

  @override
  List<Object> get props => [];
}

class GetFaultSuccessfullyState extends MainState {
  final List<FaultFormModel> faultFormModels;

  const GetFaultSuccessfullyState(this.faultFormModels);

  @override
  List<Object> get props => [];
}

class GetFaultErrorState extends MainState {
  const GetFaultErrorState();

  @override
  List<Object> get props => [];
}

class GetFaultLoadingState extends MainState {
  const GetFaultLoadingState();

  @override
  List<Object> get props => [];
}

class NavigationToFaultScreenState extends MainState {
  final BuildContext context;

  const NavigationToFaultScreenState({
    required this.context,
  });

  @override
  List<Object?> get props => [context];
}

class GetSparesState extends MainState {
  const GetSparesState();

  @override
  List<Object> get props => [];
}

class GetJobCardLoadingState extends MainState {
  const GetJobCardLoadingState();

  @override
  List<Object> get props => [];
}

class GetProductsState extends MainState {
  const GetProductsState();

  @override
  List<Object> get props => [];
}

class GetProductsErrorState extends MainState {
  const GetProductsErrorState();

  @override
  List<Object> get props => [];
}

class GetAmcCardLoadingState extends MainState {
  const GetAmcCardLoadingState();

  @override
  List<Object> get props => [];
}

class GetAmcCardSuccessfullyState extends MainState {
  const GetAmcCardSuccessfullyState();

  @override
  List<Object> get props => [];
}

class GetAmcBuildingState extends MainState {
  const GetAmcBuildingState();

  @override
  List<Object> get props => [];
}

class SelectBeforePhotoState extends MainState {
  final List<File> beforePhotos;

  const SelectBeforePhotoState({
    required this.beforePhotos,
  });

  @override
  List<Object> get props => [beforePhotos];
}

class RemoveBeforePhotoState extends MainState {
  final List<File> beforePhotos;

  const RemoveBeforePhotoState({
    required this.beforePhotos,
  });

  @override
  List<Object> get props => [beforePhotos];
}

class SelectAfterPhotoState extends MainState {
  final List<File> afterPhotos;

  const SelectAfterPhotoState({
    required this.afterPhotos,
  });

  @override
  List<Object> get props => [afterPhotos];
}

class RemoveAfterPhotoState extends MainState {
  final List<File> afterPhotos;

  const RemoveAfterPhotoState({
    required this.afterPhotos,
  });

  @override
  List<Object> get props => [afterPhotos];
}

class SelectBillPhotoState extends MainState {
  final List<File> billPhotos;

  const SelectBillPhotoState({
    required this.billPhotos,
  });

  @override
  List<Object> get props => [billPhotos];
}

class RemoveBillPhotoState extends MainState {
  final List<File> billPhotos;

  const RemoveBillPhotoState({
    required this.billPhotos,
  });

  @override
  List<Object> get props => [billPhotos];
}

class SelectSignaturePhotoState extends MainState {
  final File signaturePhoto;

  const SelectSignaturePhotoState({
    required this.signaturePhoto,
  });

  @override
  List<Object> get props => [signaturePhoto];
}

class RemoveSignaturePhotoState extends MainState {
  final File signaturePhoto;

  const RemoveSignaturePhotoState({
    required this.signaturePhoto,
  });

  @override
  List<Object> get props => [signaturePhoto];
}

class SelectReportTypeState extends MainState {
  final int selectedReportType;

  const SelectReportTypeState(this.selectedReportType);

  @override
  List<Object> get props => [selectedReportType];
}

class AddSignatureState extends MainState {
  const AddSignatureState();

  @override
  List<Object> get props => [];
}

class GetAmcBuildingsDataSuccessfullyState extends MainState {
  const GetAmcBuildingsDataSuccessfullyState();

  @override
  List<Object> get props => [];
}

class GetAmcBuildingsDataLoadingState extends MainState {
  const GetAmcBuildingsDataLoadingState();

  @override
  List<Object> get props => [];
}

class SearchJobCardState extends MainState {
  final List<JobCard> jobCardsFiltered;

  const SearchJobCardState({required this.jobCardsFiltered});

  @override
  List<Object> get props => [];
}
