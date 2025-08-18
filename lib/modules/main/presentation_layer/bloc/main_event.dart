// ignore_for_file: must_be_immutable

part of 'main_bloc.dart';

abstract class MainEvent extends Equatable {
  const MainEvent();
}

class AddToListAmcReport extends MainEvent {
  final int index;
  final List<int> list;

  const AddToListAmcReport({
    required this.index,
    required this.list,
  });

  @override
  List<Object?> get props => [index];
}

class SelectPropertySiteEvent extends MainEvent {
  final String propertySite;

  const SelectPropertySiteEvent({required this.propertySite});

  @override
  List<Object?> get props => [propertySite];
}

class SelectAcTypeEvent extends MainEvent {
  final String acType;

  const SelectAcTypeEvent({required this.acType});

  @override
  List<Object?> get props => [acType];
}

class SelectWorkStatusEvent extends MainEvent {
  final String workStatus;

  const SelectWorkStatusEvent({required this.workStatus});

  @override
  List<Object?> get props => [workStatus];
}

class SelectSpareEvent extends MainEvent {
  final String spare;

  const SelectSpareEvent({required this.spare});

  @override
  List<Object?> get props => [spare];
}

class SelectServiceTypeEvent extends MainEvent {
  final String serviceType;
  int? serviceTypeId;

  SelectServiceTypeEvent(
      {required this.serviceType, required this.serviceTypeId});

  @override
  List<Object?> get props => [serviceType];
}

class AddSigntureEvent extends MainEvent {
  final File signturePhoto;
  final String type;

  const AddSigntureEvent({required this.signturePhoto, required this.type});

  @override
  List<Object?> get props => [signturePhoto];
}

class SelectCategoryEvent extends MainEvent {
  final String category;

  const SelectCategoryEvent({required this.category});

  @override
  List<Object?> get props => [category];
}

class SelectSubEvent extends MainEvent {
  final String sub;

  const SelectSubEvent({required this.sub});

  @override
  List<Object?> get props => [sub];
}

class RemoveFromServiceTypeListEvent extends MainEvent {
  final ServiceTypeModel serviceType;

  const RemoveFromServiceTypeListEvent({
    required this.serviceType,
  });

  @override
  List<Object?> get props => [];
}

class RemoveFromSpareListEvent extends MainEvent {
  final String spareName;
  final int quantity;

  const RemoveFromSpareListEvent(
      {required this.quantity, required this.spareName});

  @override
  List<Object?> get props => [];
}

class SelectAmcPropertyEvent extends MainEvent {
  final String property;
  final int propertyIndex;

  const SelectAmcPropertyEvent(
      {required this.property, required this.propertyIndex});

  @override
  List<Object?> get props => [property, propertyIndex];
}

class SelectTypeOfServiceEvent extends MainEvent {
  final String typeOfService;

  const SelectTypeOfServiceEvent({required this.typeOfService});

  @override
  List<Object?> get props => [typeOfService];
}

class SelectAmcAcTypeEvent extends MainEvent {
  final String acType;

  const SelectAmcAcTypeEvent({required this.acType});

  @override
  List<Object?> get props => [acType];
}


class GetPDFEvent extends MainEvent {
  final int jobCardId;
  final String pdfType;

  const GetPDFEvent({required this.jobCardId, required this.pdfType, });

  @override
  List<Object?> get props => [jobCardId, pdfType];
}

class CheckIsAcBeforeEvent extends MainEvent {
  final bool isAcBefore;

  const CheckIsAcBeforeEvent({
    required this.isAcBefore,
  });

  @override
  List<Object?> get props => [];
}

class GetFaultEvent extends MainEvent {
  final JobCard jobCard;
  final bool isComplaint;
  final BuildContext context;

  const GetFaultEvent({
    required this.jobCard,
    required this.isComplaint,
    required this.context,
  });

  @override
  List<Object?> get props => [];
}

class NavComplaintDetailsScreenEvent extends MainEvent {
  final BuildContext context;
  final JobCard jobCard;

  const NavComplaintDetailsScreenEvent(
      {required this.jobCard, required this.context});

  @override
  List<Object?> get props => [];
}

class ClosePDFEvent extends MainEvent {
  const ClosePDFEvent();

  @override
  List<Object?> get props => [];
}

class SubmitAmcReportEvent extends MainEvent {
  final int id;
  final SpareCModel? spareCModel;
  final BuildContext context;
  final AmcFormModel amcFormModel;
  final JobCard jobCard;

  const SubmitAmcReportEvent({
    required this.id,
    required this.context,
    required this.jobCard,
    required this.spareCModel,
    required this.amcFormModel,
  });

  @override
  List<Object?> get props => [
        id,
      ];
}

class NavigationToFaultScreenEvent extends MainEvent {
  // final int id;
  final JobCard jobCard;
  final BuildContext context;

  const NavigationToFaultScreenEvent({
    // required this.id,
    required this.jobCard,
    required this.context,
  });

  @override
  List<Object?> get props => [context];
}

class SubmitFaultReportEvent extends MainEvent {
  final JobCard jobCard;

  const SubmitFaultReportEvent({
    required this.jobCard,
  });

  @override
  List<Object?> get props => [];
}

class SaveFaultDataEvent extends MainEvent {
  final FaultFormModel faultFormModel;
  // final int id;
  final JobCard jobCard;

  const SaveFaultDataEvent({
    // required this.id,
    required this.jobCard,
    required this.faultFormModel,
  });

  @override
  List<Object?> get props => [
        faultFormModel,
      ];
}

class UpdateFaultDataEvent extends MainEvent {
  final FaultFormModel faultFormModel;
  final int id;
  // final int index;

  const UpdateFaultDataEvent({
    required this.id,
    // required this.index,
    required this.faultFormModel,
  });

  @override
  List<Object?> get props => [faultFormModel, id];
}

class DeleteFaultDataEvent extends MainEvent {
  final FaultFormModel faultFormModel;
  final int id;

  const DeleteFaultDataEvent({
    required this.faultFormModel,
    required this.id,
  });

  @override
  List<Object?> get props => [
        faultFormModel,
      ];
}

class ReviewReportEvent extends MainEvent {
  final JobCard jobCard;

  const ReviewReportEvent({
    required this.jobCard,
  });

  @override
  List<Object?> get props => [jobCard];
}

class GetJobCardEvent extends MainEvent {
  final BuildContext context;

  const GetJobCardEvent({
    required this.context,
  });

  @override
  List<Object?> get props => [];
}

class GetProductsEvent extends MainEvent {
  const GetProductsEvent();

  @override
  List<Object?> get props => [];
}

class GetSparesEvent extends MainEvent {
  const GetSparesEvent();

  @override
  List<Object?> get props => [];
}

class RemoveMemoryImageEvent extends MainEvent {
  // final Uint8List image;
  // final List<Uint8List> memoryPhotos;
  final String image;
  final FaultFormModel faultFormModel;

  const RemoveMemoryImageEvent(
      {required this.faultFormModel, required this.image});

  @override
  List<Object?> get props => [];
}

class GetAmcCardsEvent extends MainEvent {
  final BuildContext context;

  const GetAmcCardsEvent({
    required this.context,
  });

  @override
  List<Object?> get props => [context];
}

class GetAmcBuildingsEvent extends MainEvent {
  final int amcCardId;

  const GetAmcBuildingsEvent({required this.amcCardId});

  @override
  List<Object?> get props => [amcCardId];
}

class SelectPhotoEvent extends MainEvent {
  final String type;

  const SelectPhotoEvent({required this.type});

  @override
  List<Object?> get props => [type];
}

class RemovePhotoEvent extends MainEvent {
  final String type;

  const RemovePhotoEvent({required this.type});

  @override
  List<Object?> get props => [];
}

class SelectReportTypeEvent extends MainEvent {
  final int index;
  int selectedReportType;
  FaultFormModel faultFormModel;

  SelectReportTypeEvent(
      {required this.index,
      required this.faultFormModel,
      required this.selectedReportType});

  @override
  List<Object?> get props => [];
}

class AcceptJobCardEvent extends MainEvent {
  final int id;

  const AcceptJobCardEvent({required this.id});

  @override
  List<Object?> get props => [];
}

class IgnoreJobCardEvent extends MainEvent {
  final int id;

  const IgnoreJobCardEvent({required this.id});

  @override
  List<Object?> get props => [];
}

class AddToAmcCardQuestionsListEvent extends MainEvent {
  final int index;

  const AddToAmcCardQuestionsListEvent({required this.index});

  @override
  List<Object?> get props => [index];
}


// Updated to AddSignatureEventto save Customer Signature Locally
class AddSignatureEvent extends MainEvent {
  BuildContext context;
  String type;

  AddSignatureEvent({
    required this.context,
    required this.type,
  });

  @override
  List<Object?> get props => [];
}

class GetAmcBuildingsDataEvent extends MainEvent {
  int id;

  GetAmcBuildingsDataEvent({required this.id});

  @override
  List<Object?> get props => [];
}

class AddServiceTypeBuilderToListEvent extends MainEvent {
  final ServiceTypeModel serviceTypeModel;

  const AddServiceTypeBuilderToListEvent(this.serviceTypeModel);

  @override
  List<Object?> get props => [];
}

class AddSparesBuilderToListEvent extends MainEvent {
  final SpareCModel spareCModel;

  const AddSparesBuilderToListEvent(this.spareCModel);

  @override
  List<Object?> get props => [];
}

class AddServiceTypeToListEvent extends MainEvent {
  final MainBloc bloc;
  final int index;

  const AddServiceTypeToListEvent({required this.bloc, required this.index});

  @override
  List<Object?> get props => [bloc];
}

class SubmitAmcCardReportEvent extends MainEvent {
  List<AmcAcCheckListModel> amcAcCheckListModels;
  int amcCardId;

  SubmitAmcCardReportEvent(
      {required this.amcCardId, required this.amcAcCheckListModels});

  @override
  List<Object?> get props => [amcAcCheckListModels];
}

class SearchJobCardEvent extends MainEvent {
  final String char;
  final List<JobCard> jobCards;
  const SearchJobCardEvent({required this.char, required this.jobCards});

  @override
  List<Object?> get props => [char];
}
