import 'dart:convert';
import 'dart:io';
import 'package:bayanat/core/remote/api_helper/api_models.dart';
import 'package:bayanat/core/remote/api_helper/methods.dart';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/data_layer/models/amc_ac_checklsit_model.dart';
import 'package:bayanat/modules/main/data_layer/models/amc_model.dart';
import 'package:bayanat/modules/main/data_layer/models/spare_c_model.dart';
import 'package:bayanat/modules/main/domain_layer/entities/amc_building.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/domain_layer/entities/spare.dart';
import 'package:bayanat/modules/main/domain_layer/use_cases/accept_job_cards_usecase.dart';
import 'package:bayanat/modules/main/domain_layer/use_cases/delete_fault_data_usecase.dart';
import 'package:bayanat/modules/main/domain_layer/use_cases/get_job_cards_usecase.dart';
import 'package:bayanat/modules/main/domain_layer/use_cases/ignore_job_cards_usecase.dart';
import 'package:bayanat/modules/main/domain_layer/use_cases/save_fault_data_usecase.dart';
import 'package:bayanat/modules/main/domain_layer/use_cases/submit_amc_card_report_usecase.dart';
import 'package:bayanat/modules/main/domain_layer/use_cases/update_fault_data_usecase.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/fault/complaint_details_screen.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/signature/signature.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file_safe_plus/open_file_safe_plus.dart';

// import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:http/http.dart' as http;
// import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/remote/api_helper/api_constance.dart';
import '../../../../core/remote/api_helper/end_points.dart';
import '../../../../core/services/dep_injection.dart';
import '../../../../core/utils/constance_manager.dart';
import '../../data_layer/models/fault_model.dart';
import '../../data_layer/models/service_type_model.dart';
import '../../domain_layer/entities/amc_card.dart';
import '../../domain_layer/entities/product.dart';
import '../../domain_layer/use_cases/amc_form_report_usecase.dart';
import '../../domain_layer/use_cases/fault_report_usecase.dart';
import '../../domain_layer/use_cases/get_amc_buildings_usecase.dart';
import '../../domain_layer/use_cases/get_amc_cards_usecase.dart';
import '../../domain_layer/use_cases/get_fault_usecase.dart';
import '../../domain_layer/use_cases/get_pdf_usecase.dart';
import '../../domain_layer/use_cases/get_products_usecase.dart';
import '../../domain_layer/use_cases/get_spares_usecase.dart';
import '../screens/fault/fault_1.dart';
import '../screens/pdfs/amc_card_pdf.dart';
import '../screens/pdfs/amc_pdf.dart';
import '../screens/pdfs/fault_pdf.dart';

part 'main_event.dart';

part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  /// AMC VARIABLES
  List<Spare> spares = [];
  List<SpareCModel> sparesC = [];

  /// FAULT VARIABLES
  List<FaultFormModel> getFaultModels = [];

  // List<FaultFormModel> faultFormModels = [];
  List<String> faultServiceType = [];
  List<File> afterPhotosFile = [];
  List<File> beforePhotosFile = [];
  List<File> billPhotosFile = [];

  // List<Uint8List> beforePhotosMemory = [];
  List<Product> products = [];
  File? signaturePhoto;
  File? tenantSignature;

  //Save Signature Path
  String? signaturePath;
  String? tenantSignaturePath;

  /// AMC CARD VARIABLES
  List<JobCard> allJobCards = []; //remove this when update code
  List<AmcCard> amcCards = [];
  List<List<int>> flatNumbers = [];
  List<int> numDryServices = [];
  List<int> buildingId = [];
  List<int> numWetServices = [];
  List<Map<String, int>> acTypesValues = [];
  List<Map<String, int>> acTypesIndex = [];
  List<int> amcCardQuestionsAnswers = [];
  List<AmcBuilding> allBuildings = [];
  List<String> amcCardProperties = [];
  List<List<String>> amcCardAcTypes = [[]];
  int propertyIndex = 0;
  String? selectedAmcCardProperty;
  String? selectedAmcCardAcType;
  String? signtureEncoded;
  String? tenantEncoded;
  List<AmcAcCheckListModel> amcAcCheckLists = [];

  /// JOB CARD VARIABLES
  List<JobCard> jobCards = [];

  /// bool is fetching
  bool isFetching = false;

  static MainBloc get(BuildContext context) =>
      BlocProvider.of<MainBloc>(context);

  MainBloc(MainInitial mainInitial) : super(MainInitial()) {
    on<MainEvent>((event, emit) async {
      /// AMC EVENTS
      if (event is SubmitAmcReportEvent) {
        emit(const SubmitAmcReportLoadingState());
        if (event.spareCModel != null) {
          sparesC.add(event.spareCModel!);
        }
        event.amcFormModel.sparesC = sparesC;
        event.amcFormModel.signature = await encodePhoto(
          photo: signaturePhoto!,
        );
        String download = await AmcPdf.createPdf(
          amcFormModel: event.amcFormModel,
          flatNumber: event.jobCard.flatNumber,
        );
        final bytes = File(download).readAsBytesSync();
        String encodedFile = base64Encode(bytes);
        event.amcFormModel.download = encodedFile;
        var result = await AmcFormReportUseCase(
          sl(),
        ).post(amcFormModel: event.amcFormModel, id: event.id);
        result.fold((l) {}, (r) async {
          if (r) {
            signaturePhoto = null;
            tenantSignature = null;
            sparesC.clear();
            emit(const SubmitAmcReportSuccessfullyState());
            add(GetJobCardEvent(context: event.context));
          }
        });
      } else if (event is SelectAcTypeEvent) {
        emit(SelectAcTypeState(acType: event.acType));
      } else if (event is SelectWorkStatusEvent) {
        emit(SelectWorkStatusState(workStatus: event.workStatus));
      } else if (event is AddToListAmcReport) {
        List<int> list = event.list;
        if (list.contains(event.index)) {
          list.remove(event.index);
          emit(RemoveFromListAmcReportState(index: event.index, list: list));
        } else {
          list.add(event.index);
          emit(AddToListAmcReportState(index: event.index, list: list));
        }
      } else if (event is GetSparesEvent) {
        var result = await GetSparesUseCase(sl()).get();
        result.fold((l) {}, (r) {
          spares = r;
          emit(const GetProductsState());
        });
      } else if (event is SelectSpareEvent) {
        emit(SelectSpareState(spare: event.spare));
      } else if (event is AddSparesBuilderToListEvent) {
        SpareCModel spareCModel = event.spareCModel;
        if (!sparesC.contains(spareCModel)) {
          sparesC.add(spareCModel);
        } else {
          warnToast(msg: "It has already been added");
        }
        emit(const AddSparesBuilderToListState());
      } else if (event is RemoveFromSpareListEvent) {
        SpareCModel spareCModel = SpareCModel(
          quantity: event.quantity,
          spareName: event.spareName,
        );
        sparesC.remove(spareCModel);
        emit(const AddSparesBuilderToListState());
      }

      /// FAULT EVENTS
      else if (event is SelectSubEvent) {
        emit(SelectSubState(sub: event.sub));
      } else if (event is GetFaultEvent) {
        emit(const GetFaultLoadingState());
        var result = await GetFaultUseCase(
          sl(),
        ).get(isComplaint: event.isComplaint, jobCardId: event.jobCard.id);
        result.fold(
          (l) {
            emit(const GetFaultErrorState());
          },
          (r) {
            getFaultModels = r;
            add(const CheckIsAcBeforeEvent(isAcBefore: true));
            add(
              NavComplaintDetailsScreenEvent(
                context: event.context,
                jobCard: event.jobCard,
              ),
            );
            emit(GetFaultSuccessfullyState(getFaultModels));
          },
        );
      } else if (event is CheckIsAcBeforeEvent) {
        emit(CheckIsAcBeforeState(event.isAcBefore));
      } else if (event is NavComplaintDetailsScreenEvent) {
        event.context.push(ComplaintDetailsScreen(jobCard: event.jobCard));
      } else if (event is GetProductsEvent) {
        var result = await GetProductsUseCase(sl()).get();
        result.fold(
          (l) {
            emit(const GetProductsErrorState());
          },
          (r) {
            products = r;
            emit(const GetProductsState());
          },
        );
      } else if (event is AddServiceTypeBuilderToListEvent) {
        emit(AddServiceTypeToListState(event.serviceTypeModel));
      } else if (event is SelectServiceTypeEvent) {
        event.serviceTypeId = products
            .firstWhere((product) => product.serviceName == event.serviceType)
            .id;
        emit(
          SelectServiceTypeState(
            serviceType: event.serviceType,
            serviceTypeId: event.serviceTypeId!,
          ),
        );
      } else if (event is RemoveFromServiceTypeListEvent) {
        emit(RemoveFromServiceTypeListState(event.serviceType));
        // emit(RemoveFromServiceTypeListState2(event.serviceType));
      } else if (event is SelectCategoryEvent) {
        emit(SelectCategoryState(category: event.category));
      } else if (event is SaveFaultDataEvent) {
        emit(SaveFaultDataLoadingState());
        await _addFaultForm(event.faultFormModel);
        var result = await SaveFaultDataUseCase(
          sl(),
        ).save(formModel: event.faultFormModel, id: event.jobCard.id);
        result.fold(
          (l) {
            emit(SaveFaultDataErrorState(l.toString()));
          },
          (r) {
            event.faultFormModel.faultId = r;
            _clearDataAfterAddFaultForm();
            _updateImages(event.faultFormModel);
            emit(SaveFaultDataSuccessfullyState(event.faultFormModel));
          },
        );
      } else if (event is UpdateFaultDataEvent) {
        emit(UpdateFaultDataLoadingState());
        await _addFaultForm(event.faultFormModel);
        var result = await UpdateFaultDataUseCase(
          sl(),
        ).update(formModel: event.faultFormModel, id: event.id);
        result.fold(
          (l) {
            emit(UpdateFaultDataErrorState(l.toString()));
          },
          (r) {
            _clearDataAfterAddFaultForm();
            _updateImages(event.faultFormModel);
            emit(UpdateFaultDataSuccessfullyState(event.faultFormModel));
          },
        );
      } else if (event is DeleteFaultDataEvent) {
        emit(DeleteFaultDataLoadingState());
        var result = await DeleteFaultDataUseCase(
          sl(),
        ).delete(formModel: event.faultFormModel, id: event.id);
        result.fold(
          (l) {
            emit(DeleteFaultDataErrorState(l.toString()));
          },
          (r) {
            emit(DeleteFaultDataSuccessfullyState(event.faultFormModel));
          },
        );
      } else if (event is RemoveMemoryImageEvent) {
        int id = int.parse(getLastSegment(event.image));
        await http.delete(
          Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
            'Cookie': ConstanceManager.sessionId.toString(),
          },
          body: jsonEncode({
            "params": {
              "model": ApiModels.attachment,
              "method": ApiMethods.unlink,
              "kwargs": {},
              "args": [id],
            },
          }),
        );
        if (event.faultFormModel.beforePhotosIds!.contains(id)) {
          event.faultFormModel.beforePhotos!.remove(event.image);
          event.faultFormModel.beforePhotosIds!.remove(id);
        } else if (event.faultFormModel.afterPhotosIds!.contains(id)) {
          event.faultFormModel.afterPhotos!.remove(event.image);
          event.faultFormModel.afterPhotosIds!.remove(id);
        } else if (event.faultFormModel.purchaseBillPhotoIds!.contains(id)) {
          event.faultFormModel.purchaseBillPhoto!.remove(event.image);
          event.faultFormModel.purchaseBillPhotoIds!.remove(id);
        }
        emit(RemoveImageState(event.image));
      } else if (event is SubmitFaultReportEvent) {
        emit(const SubmitFaultReportLoadingState());
        await _submitFaultForm(getFaultModels.last);
        String encodedFile = await _downloadFaultPdf(
          getFaultModels,
          event.jobCard,
        );
        getFaultModels.last.faultFile = encodedFile;
        var result = await FaultReportUseCase(
          sl(),
        ).post(formModel: getFaultModels.last, id: event.jobCard.id);
        result.fold(
          (l) {
            emit(const SubmitFaultReportErrorState());
            errorToast(msg: l.toString());
          },
          (r) {
            _clearDataAfterAddFaultForm();
            emit(const SubmitFaultReportSuccessfullyState());
          },
        );
      } else if (event is NavigationToFaultScreenEvent) {
        getFaultModels = [];
        event.context.push(FaultScreen1(jobCard: event.jobCard));
        emit(NavigationToFaultScreenState(context: event.context));
      } else if (event is SelectPhotoEvent) {
        ImagePicker picker = ImagePicker();
        if (event.type == "before") {
          await picker.pickMultiImage(imageQuality: 50).then((value) {
            beforePhotosFile.clear();
            emit(RemoveBeforePhotoState(beforePhotos: beforePhotosFile));
            for (var element in value) {
              beforePhotosFile.add(File(element.path));
            }
          });
          emit(SelectBeforePhotoState(beforePhotos: beforePhotosFile));
        } else if (event.type == "after") {
          await picker.pickMultiImage(imageQuality: 50).then((value) {
            afterPhotosFile.clear();
            emit(RemoveAfterPhotoState(afterPhotos: afterPhotosFile));
            for (var element in value) {
              afterPhotosFile.add(File(element.path));
            }
          });
          emit(SelectAfterPhotoState(afterPhotos: afterPhotosFile));
        } else if (event.type == "signature") {
          await picker
              .pickImage(source: ImageSource.gallery, imageQuality: 50)
              .then((value) async {
            if (value == null) {
              errorToast(msg: 'please add your signature');
            } else {
              signaturePhoto = File(value.path);
            }
          });
          emit(SelectSignaturePhotoState(signaturePhoto: signaturePhoto!));
        } else if (event.type == "bill") {
          emit(RemoveBillPhotoState(billPhotos: billPhotosFile));
          await picker
              .pickImage(source: ImageSource.camera, imageQuality: 50)
              .then((value) {
            if (value != null) {
              billPhotosFile.add(File(value.path));
              emit(SelectBillPhotoState(billPhotos: billPhotosFile));
            }
          });
        }
      } else if (event is SelectReportTypeEvent) {
        if (event.index == 0) {
          event.selectedReportType = 0;
          event.faultFormModel.reportType = "FAULT REPORT";
        } else {
          event.selectedReportType = 1;
          event.faultFormModel.reportType = "COMPLETION REPORT";
        }
        emit(SelectReportTypeState(event.selectedReportType));
      } else if (event is AddSigntureEvent) {
        if (event.type == "signture") {
          signaturePhoto = event.signturePhoto;
          signtureEncoded = await encodePhoto(photo: signaturePhoto!);
          emit(SelectSignaturePhotoState(signaturePhoto: signaturePhoto!));
        } else {
          tenantSignature = event.signturePhoto;
          tenantEncoded = await encodePhoto(photo: tenantSignature!);
          emit(SelectSignaturePhotoState(signaturePhoto: tenantSignature!));
        }
      }

      /// JOB CARD EVENTS
      else if (event is GetJobCardEvent) {
        print("🔄 GetJobCardEvent triggered");
        print("📊 Current isFetching: $isFetching");
        if (isFetching) {
          print("⏳ Already fetching, skipping...");
          return; // Prevent concurrent fetches
        }
        isFetching = true;
        emit(const GetJobCardLoadingState());

        jobCards.clear();
        int offset = 0;
        const int batchSize = 100;
        int batchCount = 0;

        print("🚀 Starting job card fetch with batch size: $batchSize");

        while (true) {
          batchCount++;
          print("📦 Fetching batch $batchCount with offset: $offset");

          final result = await GetJobCardsUseCase(
            sl(),
          ).call(offset: offset, limit: batchSize);

          if (result.isLeft()) {
            print(
                '❌ Error in batch $batchCount: ${result.fold((l) => l.toString(), (r) => 'Unknown error')}');
            emit(const GetJobCardErrorState());
            break;
          } else {
            final newJobCards = result.getOrElse(() => []);
            print(
                '✅ Batch $batchCount: ${newJobCards.length} job cards received');

            if (newJobCards.isEmpty) {
              print('🏁 No more job cards, finishing fetch');
              print('🎯 Total job cards fetched: ${jobCards.length}');
              emit(GetJobCardSuccessfullyState(jobCards));
              break;
            }

            // Debug: Print details of each job card in this batch
            for (int i = 0; i < newJobCards.length; i++) {
              final jobCard = newJobCards[i];
              print(
                  '📋 Job Card ${i + 1} in batch $batchCount: ID=${jobCard.id}, Number=${jobCard.jobCardNumber}, Customer=${jobCard.customerName}');
            }

            jobCards.addAll(newJobCards);
            print('📈 Total job cards so far: ${jobCards.length}');
            emit(JobCardsBatchLoadingState(List.from(jobCards)));
            offset += batchSize;
          }
        }
        isFetching = false;
        print(
            "🏁 GetJobCardEvent completed. Total job cards: ${jobCards.length}");
      }
      // else if (event is GetJobCardEvent) {
      //   emit(const GetJobCardLoadingState());
      //   var result = await GetJobCardsUseCase(sl()).call();
      //   result.fold((l) {
      //     emit(const GetJobCardErrorState());
      //   }, (r) {
      //     jobCards = r;
      //     emit(GetJobCardSuccessfullyState(event.context));
      //   });
      // }

      else if (event is GetPDFEvent) {
        var result = await GetPDFUseCase(
          sl(),
        ).get(jobCardId: event.jobCardId, pdfType: event.pdfType);
        result.fold(
          (l) {
            print("GetPDFEvent 1:");
            emit(const GetPDFErrorState());
          },
          (r) {
            print("GetPDFEvent 2: $r");
            emit(GetPDFSuccessfullyState(r));
          },
        );
      } else if (event is ClosePDFEvent) {
        emit(const ClosePDFState());
      } else if (event is AcceptJobCardEvent) {
        var result = await AcceptJobCardsUseCase(sl()).write(id: event.id);
        result.fold((l) {}, (r) {
          emit(const AcceptJobCardSuccessfullyState());
        });
      } else if (event is IgnoreJobCardEvent) {
        var result = await IgnoreJobCardsUseCase(sl()).write(id: event.id);
        result.fold((l) {}, (r) {
          emit(const IgnoreJobCardSuccessfullyState());
        });
      } else if (event is ReviewReportEvent) {
        emit(const ReviewReportLoadingState());
        await _submitFaultForm(getFaultModels.last);
        await _downloadFaultPdf(getFaultModels, event.jobCard).then((
          encodedFile,
        ) async {
          List<int> pdfBytes = base64Decode(encodedFile);
          String filePath = await savePdfToFile(pdfBytes);
          //TODO  Defined OpenFilePlus
          OpenFileSafePlus.open(filePath);
        });
        emit(const ReviewReportState());
      }

      /// AMC CARD EVENTS
      else if (event is SubmitAmcCardReportEvent) {
        emit(SubmitAmcCardReportLoadingState());
        GetAmcBuildingsDataEvent(id: event.amcCardId);
        String encodedFile = await _downloadAmcCardPdf(
          event.amcAcCheckListModels,
        );
        for (var element in event.amcAcCheckListModels) {
          element.amcFile = encodedFile;
        }
        var result = await SubmitAmcCardReportUseCase(sl()).call(
          amcAcCheckListModels: event.amcAcCheckListModels,
          acTypesValues: acTypesValues[propertyIndex - 1],
          acTypesIndex: acTypesIndex[propertyIndex - 1],
          numWetServices: numWetServices[propertyIndex - 1],
          numDryServices: numDryServices[propertyIndex - 1],
          flatsNumbers: flatNumbers[propertyIndex - 1],
          buildingId: buildingId[propertyIndex - 1],
          amcCardId: event.amcCardId,
        );
        result.fold(
          (l) {
            errorToast(msg: l.toString());
          },
          (r) {
            _clearDataAfterSubmitAmcCard();
            emit(SubmitAmcCardReportSuccessfullyState());
          },
        );
      } else if (event is SelectAmcPropertyEvent) {
        selectedAmcCardProperty = event.property;
        selectedAmcCardAcType = null;
        propertyIndex = event.propertyIndex;
        emit(
          SelectAmcCardPropertyState(
            property: event.property,
            propertyIndex: event.propertyIndex,
          ),
        );
      } else if (event is SelectTypeOfServiceEvent) {
        emit(
          SelectTypeOfServiceState(selectedTypeOfService: event.typeOfService),
        );
      } else if (event is GetAmcBuildingsDataEvent) {
        emit(const GetAmcBuildingsDataLoadingState());
        amcCardAcTypes = [[]];
        amcCardProperties = [];
        selectedAmcCardProperty = null;
        selectedAmcCardAcType = null;
        for (var element in allBuildings) {
          if (element.amcCardId == event.id) {
            amcCardProperties.add(element.property);
            amcCardAcTypes.add(element.acTypes);
            acTypesValues.add(element.acTotals);
            acTypesIndex.add(element.acTypeId);
            numDryServices.add(element.numDryServices);
            buildingId.add(element.id);
            flatNumbers.add(element.flatNumbers);
            numWetServices.add(element.numWetServices);
            amcCardAcTypes = amcCardAcTypes.toSet().toList();
            amcCardProperties = amcCardProperties.toSet().toList();
          }
        }
        emit(const GetAmcBuildingsDataSuccessfullyState());
      } else if (event is SelectAmcAcTypeEvent) {
        selectedAmcCardAcType = event.acType;
        emit(SelectAmcCardAcTypeState(acType: event.acType));
      } else if (event is AddToAmcCardQuestionsListEvent) {
        if (amcCardQuestionsAnswers.contains(event.index)) {
          amcCardQuestionsAnswers.remove(event.index);
          emit(RemoveFromAmcCardQuestionListState(index: event.index));
        } else {
          amcCardQuestionsAnswers.add(event.index);
          emit(AddToAmcCardQuestionListState(index: event.index));
        }
      } else if (event is GetAmcCardsEvent) {
        emit(const GetAmcCardLoadingState());
        var result = await GetAmcCardsUseCase(sl()).call();
        result.fold((l) {}, (r) {
          amcCards = r;
          emit(const GetAmcCardSuccessfullyState());
        });
      } else if (event is GetAmcBuildingsEvent) {
        allBuildings = [];
        var result = await GetAmcBuildingsUseCase(
          sl(),
        ).call(amcCardId: event.amcCardId);
        result.fold(
          (l) {
            errorToast(msg: 'an error occurred');
          },
          (r) {
            allBuildings = r;
            emit(const GetAmcBuildingState());
          },
        );
        add(GetAmcBuildingsDataEvent(id: event.amcCardId));
      } else if (event is AddSignatureEvent) {
        showDialog(
          context: event.context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.sp),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  onTap: () {
                    event.context.push(SignatureScreen(type: event.type));
                  },
                  title: const Text("Add Signature"),
                ),
              ],
            );
          },
        );
      } else if (event is SearchJobCardEvent) {
        List<JobCard> jobCardsFiltered = event.jobCards.where((jobCard) {
          return jobCard.id.toString() == event.char ||
              jobCard.location == event.char ||
              jobCard.flatNumber == event.char;
        }).toList();
        emit(SearchJobCardState(jobCardsFiltered: jobCardsFiltered));
      }
    });
  }

  Future<void> _addFaultForm(FaultFormModel faultFormModel) async {
    List<File> beforePhotos1 = beforePhotosFile;
    List<File> afterPhotos1 = afterPhotosFile;
    List<File> billPhotos1 = billPhotosFile;
    beforePhotosFile = [];
    afterPhotosFile = [];
    billPhotosFile = [];
    await encodePhotos(photos: beforePhotos1).then((value) {
      List<String> beforePhotos = value;
      faultFormModel.beforePhotos =
          (faultFormModel.beforePhotos ?? []) + beforePhotos;
    });
    await encodePhotos(photos: afterPhotos1).then((value) {
      List<String> afterPhotos = value;
      faultFormModel.afterPhotos =
          (faultFormModel.afterPhotos ?? []) + afterPhotos;
    });
    await encodePhotos(photos: billPhotos1).then((value) {
      List<String> purchaseBillPhoto = value;
      faultFormModel.purchaseBillPhoto =
          (faultFormModel.purchaseBillPhoto ?? []) + purchaseBillPhoto;
    });
  }

  Future<void> _submitFaultForm(FaultFormModel faultFormModel) async {
    if (signaturePhoto != null) {
      await encodePhoto(photo: signaturePhoto!).then((value) {
        faultFormModel.signaturePhoto = value.toString();
      });
    }
    if (beforePhotosFile.isNotEmpty) {
      await encodePhotos(photos: beforePhotosFile).then((value) {
        faultFormModel.beforePhotos = value;
      });
    }
    if (afterPhotosFile.isNotEmpty) {
      await encodePhotos(photos: afterPhotosFile).then((value) {
        faultFormModel.afterPhotos = value;
      });
    }
    if (billPhotosFile.isNotEmpty) {
      await encodePhotos(photos: billPhotosFile).then((value) {
        faultFormModel.purchaseBillPhoto = value;
      });
    }
  }

  Future<String> _downloadFaultPdf(
    List<FaultFormModel> faultFormModels,
    JobCard jobCard,
  ) async {
    List<String> beforePhotosMemory = [];
    List<String> afterPhotosMemory = [];
    for (var faultFormModel in faultFormModels) {
      if (faultFormModel.beforePhotosMemory == null) {
        beforePhotosMemory = [];
        for (int id in faultFormModel.beforePhotosIds ?? []) {
          beforePhotosMemory.add(await _convertImageToMemory(id));
        }
        faultFormModel.beforePhotosMemory = beforePhotosMemory;
      }
      if (faultFormModel.afterPhotosMemory == null) {
        afterPhotosMemory = [];
        for (int id in faultFormModel.afterPhotosIds ?? []) {
          afterPhotosMemory.add(await _convertImageToMemory(id));
        }
        faultFormModel.afterPhotosMemory = afterPhotosMemory;
      }
    }
    String download = await FaultPdf.pdf(
      faultFormModels: faultFormModels,
      jobCardModel: jobCard,
    );
    final bytes = File(download).readAsBytesSync();
    return base64Encode(bytes);
  }

  Future<String> _downloadAmcCardPdf(
    List<AmcAcCheckListModel> amcAcCheckListModels,
  ) async {
    String download = await AmcCardPdf.createPdf(
      amcAcCheckList: amcAcCheckListModels,
      propertySite: selectedAmcCardProperty!,
    );
    final bytes = File(download).readAsBytesSync();
    return base64Encode(bytes);
  }

  _clearDataAfterAddFaultForm() {
    beforePhotosFile.clear();
    afterPhotosFile.clear();
    billPhotosFile.clear();
    signaturePhoto = null;
    tenantSignature = null;
  }

  Future<String> _convertImageToMemory(
    int id, {
    int maxRetries = 15, // Number of retries
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final res = await http
            .post(
              Uri.parse(ApiConsts.baseUrl + ApiEndPoints.callKw),
              headers: {
                'Content-Type': 'application/json',
                'Connection': 'keep-alive',
                'Cookie': ConstanceManager.sessionId.toString(),
              },
              body: jsonEncode({
                "params": {
                  "model": ApiModels.attachment,
                  "method": ApiMethods.searchRead,
                  "kwargs": {},
                  "args": [
                    [
                      ["id", "=", id],
                    ],
                  ],
                },
              }),
            )
            .timeout(const Duration(minutes: 1));

        if (res.statusCode == 200) {
          var value = jsonDecode(res.body)["result"];
          return value[0]["datas"];
        } else {}
      } on Exception {}

      attempt++;
    }

    throw Exception(
      "Failed to convert image to memory after $maxRetries attempts",
    );
  }

  _clearDataAfterSubmitAmcCard() {
    signaturePhoto = null;
    signtureEncoded = null;
    tenantEncoded = null;
    tenantSignature = null;
    amcAcCheckLists = [];
    flatNumbers = [];
    acTypesValues = [];
    numWetServices = [];
    numDryServices = [];
    buildingId = [];
    acTypesIndex = [];
    amcCardQuestionsAnswers = [];
    selectedAmcCardAcType = null;
    selectedAmcCardProperty = null;
  }

  Future<String> encodeFileToBase64(String filePath) async {
    List<int> fileBytes = await File(filePath).readAsBytes();
    String base64Encoded = base64Encode(fileBytes);
    return base64Encoded;
  }

  Future<List<String>> encodePhotos({required List<File> photos}) async {
    List<String> encodedPhotos = [];
    for (var element in photos) {
      String encodedPhoto = await encodeFileToBase64(element.path);
      encodedPhotos.add(encodedPhoto);
    }
    return encodedPhotos;
  }

  Future<String> encodePhoto({required File photo}) async {
    String encodedPhoto = await encodeFileToBase64(photo.path);
    return encodedPhoto;
  }

  void _updateImages(FaultFormModel faultFormModel) {
    if (faultFormModel.beforePhotosIds != null) {
      faultFormModel.beforePhotos = [];
      for (int id in faultFormModel.beforePhotosIds ?? []) {
        faultFormModel.beforePhotos!.add(ApiConsts.imageUrl + id.toString());
      }
    }
    if (faultFormModel.purchaseBillPhotoIds != null) {
      faultFormModel.purchaseBillPhoto = [];
      for (int id in faultFormModel.purchaseBillPhotoIds ?? []) {
        faultFormModel.purchaseBillPhoto!.add(
          ApiConsts.imageUrl + id.toString(),
        );
      }
    }
    if (faultFormModel.afterPhotosIds != null) {
      faultFormModel.afterPhotos = [];
      for (int id in faultFormModel.afterPhotosIds ?? []) {
        faultFormModel.afterPhotos!.add(ApiConsts.imageUrl + id.toString());
      }
    }
  }
}

Future<String> savePdfToFile(List<int> pdfBytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}.pdf';
  final file = File(filePath);
  await file.writeAsBytes(pdfBytes);
  return filePath;
}
