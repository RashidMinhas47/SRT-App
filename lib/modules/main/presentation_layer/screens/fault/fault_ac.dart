import 'dart:io';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/data_layer/models/fault_model.dart';
import 'package:bayanat/modules/main/data_layer/models/service_type_model.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/presentation_layer/bloc/main_bloc.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/services/dep_injection.dart';
import '../../../../../core/utils/color_manager.dart';

class FaultAc extends StatelessWidget {
  final FaultFormModel faultFormModel;

  // final int id;
  final JobCard jobCard;

  const FaultAc({
    super.key,
    required this.faultFormModel,
    // required this.id,
    required this.jobCard,
  });

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    TextEditingController makeController = TextEditingController();
    TextEditingController categoryController = TextEditingController();
    TextEditingController subCategoryController = TextEditingController();
    TextEditingController modelController = TextEditingController();
    TextEditingController serialNumberController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController quantityTypeServiceController =
        TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    // List<FaultFormModel> getFaultModels = bloc.getFaultModels;
    makeController.text = faultFormModel.make;
    serialNumberController.text = faultFormModel.serialNumber;
    modelController.text = faultFormModel.model;
    locationController.text = faultFormModel.location;
    descriptionController.text = faultFormModel.description;
    categoryController.text = faultFormModel.category;
    subCategoryController.text = faultFormModel.subCategory;
    List<ServiceTypeModel> serviceTypes = faultFormModel.serviceTypes!;
    List<String> beforePhotosNetwork = faultFormModel.beforePhotos ?? [];
    // beforePhotosMemory = stringsListToByteList(faultFormModel.beforePhotos!);
    List<String> afterPhotosNetwork = faultFormModel.afterPhotos ?? [];
    // afterPhotosMemory = stringsListToByteList(faultFormModel.afterPhotos!);
    List<String> purchaseBillNetwork = faultFormModel.purchaseBillPhoto ?? [];
    // purchaseBillMemory =
    //     stringsListToByteList(faultFormModel.purchaseBillPhoto!);
    // List<Uint8List> originalBeforePhotosMemory = beforePhotosMemory + [];
    // List<Uint8List> originalAfterPhotosMemory = afterPhotosMemory + [];
    // List<Uint8List> originalPurchaseBillMemory = purchaseBillMemory + [];
    var formKey = GlobalKey<FormState>();
    String? sub = faultFormModel.subCategory;
    String? category = faultFormModel.category;
    String? serviceType;
    int productId = -1;
    return BlocConsumer(
        bloc: bloc,
        listener: (context, state) {
          if (state is SelectSubState) {
            sub = state.sub;
          }
          if (state is RemoveFromServiceTypeListState) {
            serviceTypes.remove(state.serviceType);
          }
          if (state is SelectCategoryState) {
            sub = null;
            category = state.category;
          }
          if (state is SelectServiceTypeState) {
            serviceType = state.serviceType;
            productId = state.serviceTypeId;
          }
          if (state is RemoveImageState) {
            if (beforePhotosNetwork.contains(state.image)) {
              beforePhotosNetwork.remove(state.image);
            } else if (afterPhotosNetwork.contains(state.image)) {
              afterPhotosNetwork.remove(state.image);
            } else if (purchaseBillNetwork.contains(state.image)) {
              purchaseBillNetwork.remove(state.image);
            }
          }
          if (state is AddServiceTypeToListState) {
            if (!serviceTypes.contains(state.serviceType)) {
              serviceTypes.add(state.serviceType);
            } else {
              warnToast(msg: "It has already been added");
            }
            serviceType = null;
            productId = -1;
            quantityTypeServiceController.clear();
          }
          if (state is DeleteFaultDataLoadingState) {
            showDialogLoading(context: context);
          } else if (state is DeleteFaultDataErrorState) {
            context.pop();
            errorToast(msg: state.error);
          } else if (state is DeleteFaultDataSuccessfullyState) {
            context.pop();
            bloc.getFaultModels.remove(faultFormModel);
            showDialogSuccess(
              context: context,
              text: "The data has been deleted",
              onPressed: () {
                bloc.add(GetJobCardEvent(context: context));
                context.pop();
                context.pop();
              },
            );
          }
          if (state is UpdateFaultDataLoadingState) {
            showDialogLoading(context: context);
          } else if (state is UpdateFaultDataErrorState) {
            context.pop();
            errorToast(msg: state.error);
          } else if (state is UpdateFaultDataSuccessfullyState) {
            context.pop();
            bloc.getFaultModels.remove(faultFormModel);
            bloc.getFaultModels.add(state.faultFormModel);
            showDialogSuccess(
              context: context,
              text: "The data has been updated",
              onPressed: () {
                bloc.add(GetJobCardEvent(context: context));
                context.pop();
                context.pop();
                // context.pushAndRemove(ComplaintDetailsScreen(
                //   jobCard: jobCard,
                // ));
              },
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        screenCoverBuilder(40, width: 0.2),
                        Padding(
                          padding:
                              EdgeInsetsDirectional.only(top: 10.h, end: 4.w),
                          child: Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: IconButton(
                                onPressed: () {
                                  bloc.add(
                                    DeleteFaultDataEvent(
                                      id: jobCard.id,
                                      faultFormModel: faultFormModel,
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28.sp,
                                )),
                          ),
                        ),
                        backIcon(
                            context: context,
                            onPressed: () async {
                              faultFormModel.afterPhotosFile =
                                  bloc.afterPhotosFile;
                              faultFormModel.purchaseBillPhotoFile =
                                  bloc.billPhotosFile;
                              await bloc
                                  .encodePhotos(photos: bloc.afterPhotosFile)
                                  .then((value) async {
                                faultFormModel.afterPhotos = value;
                                bloc.afterPhotosFile = [];
                                await bloc
                                    .encodePhotos(photos: bloc.billPhotosFile)
                                    .then((value) {
                                  faultFormModel.purchaseBillPhoto = value;
                                  bloc.billPhotosFile = [];
                                  context.pop();
                                });
                              });
                            })
                      ],
                    ),
                    SizedBox(
                      height: 20.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    
                                    "sub ",
                                    style: TextStyle(
                                        color: ColorManager.primary,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                      child: dropdownBuilder(
                                    value: sub,
                                    onChanged: (String? value) {
                                      bloc.add(SelectSubEvent(sub: value!));
                                    },
                                    items: category == "MEP"
                                        ? ConstanceManager.faultSubCategories1
                                        : category == "Air Condition"
                                            ? ConstanceManager
                                                .faultSubCategories2
                                            : [],
                                  ))
                                ],
                              ),
                              SizedBox(
                                height: 10.sp,
                              ),
                              //removed defaultFormField covered with SizedBox( height: 5.h)

                              defaultFormField(
                                  validatorText: '',
                                  controller: modelController,
                                  label: "Model",
                                  type: TextInputType.text,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'You must write a Model';
                                    }
                                    return null;
                                  }),
                              SizedBox(
                                height: 10.sp,
                              ),
                              //removed defaultFormField covered with SizedBox( height: 5.h)
                              defaultFormField(
                                  controller: locationController,
                                  label: "Location",
                                  type: TextInputType.text,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'You must write a Location';
                                    }
                                    return null;
                                  }),
                              SizedBox(
                                height: 10.sp,
                              ),
                            ],
                          )),
                          SizedBox(
                            width: 5.w,
                          ),
                          Expanded(
                              child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Category",
                                    style: TextStyle(
                                        color: ColorManager.primary,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                      child: dropdownBuilder(
                                    value: category,
                                    onChanged: (String? value) {
                                      bloc.add(SelectCategoryEvent(
                                          category: value!));
                                    },
                                    items: ConstanceManager.faultCategories,
                                  ))
                                ],
                              ),
                              SizedBox(
                                height: 10.sp,
                              ),
                              //removed defaultFormField covered with SizedBox( height: 5.h)
                              defaultFormField(
                                  controller: makeController,
                                  label: "Make",
                                  type: TextInputType.text,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'You must write a Make';
                                    }
                                    return null;
                                  }),
                              SizedBox(
                                height: 10.sp,
                              ),
                              //removed defaultFormField covered with SizedBox( height: 5.h)
                              defaultFormField(
                                  controller: serialNumberController,
                                  label: "Serial Number",
                                  type: TextInputType.text,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'You must write a Serial Number';
                                    }
                                    return null;
                                  }),
                              SizedBox(
                                height: 10.sp,
                              ),
                            ],
                          ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: defaultFormField(
                        controller: descriptionController,
                        label: "Description",
                        maxLength: 8,
                        type: TextInputType.text,
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: ColorManager.primary,
                            borderRadius:
                                BorderRadiusDirectional.circular(10.sp)),
                        child: TextButton(
                            onPressed: () {
                              if (serviceType != null &&
                                  productId != -1 &&
                                  quantityTypeServiceController.text != "") {
                                bloc.add(AddServiceTypeBuilderToListEvent(
                                    ServiceTypeModel(
                                        quantity: double.parse(
                                            quantityTypeServiceController.text),
                                        serviceTypeName: serviceType!,
                                        productId: productId)));
                              } else {
                                warnToast(
                                    msg:
                                        "You must select service type before add more ");
                              }
                            },
                            child: Text(
                              "Add more",
                              style: TextStyle(color: ColorManager.white),
                            ))),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 60.w,
                                      child: searchDropdownBuilder(
                                          text: "Type of Service",
                                          value: serviceType,
                                          onChanged: (value) {
                                            bloc.add(SelectServiceTypeEvent(
                                                serviceTypeId: productId,
                                                serviceType: value!));
                                          },
                                          items: bloc.products
                                              .map((e) => e.serviceName)
                                              .toList())),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  SizedBox(
                                    width: 28.w,
                                    child: defaultFormField(
                                        controller:
                                            quantityTypeServiceController,
                                        type: TextInputType.number,
                                        hint: "QTY"),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              Center(
                                child: ListView.separated(
                                    padding: EdgeInsetsDirectional.zero,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                serviceTypes[index]
                                                    .serviceTypeName,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10.sp),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                serviceTypes[index]
                                                    .quantity
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10.sp),
                                              ),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  bloc.add(
                                                      RemoveFromServiceTypeListEvent(
                                                          serviceType:
                                                              serviceTypes[
                                                                  index]));
                                                },
                                                icon: const Icon(
                                                  Icons.clear,
                                                )),
                                          ],
                                        ),
                                    separatorBuilder: (context, index) =>
                                        SizedBox(
                                          height: 1.h,
                                        ),
                                    itemCount: serviceTypes.length),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        SizedBox(
                          width: 60.w,
                          child: defaultButton(
                              borderColor: ColorManager.secondary,
                              textColor: ColorManager.secondary,
                              buttonColor: ColorManager.white,
                              onPressed: () {
                                bloc.add(
                                    const SelectPhotoEvent(type: "before"));
                              },
                              text: "Before photo"),
                        ),
                        bloc.beforePhotosFile.isNotEmpty
                            ? Wrap(
                                children: bloc.beforePhotosFile.map((image) {
                                  return Card(
                                    child: SizedBox(
                                      height: 100.sp,
                                      width: 100.sp,
                                      child: Image.file(File(image.path)),
                                    ),
                                  );
                                }).toList(),
                              )
                            : const SizedBox(),
                        beforePhotosNetwork.isNotEmpty
                            ? Wrap(
                                children: beforePhotosNetwork.map((image) {
                                  return Stack(
                                    children: [
                                      Card(
                                        child: SizedBox(
                                          height: 100.sp,
                                          width: 100.sp,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  image,
                                                  headers: {
                                                    "Cookie": ConstanceManager
                                                        .sessionId
                                                        .toString(),
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            bloc.add(
                                              RemoveMemoryImageEvent(
                                                  faultFormModel:
                                                      faultFormModel,
                                                  image: image),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            size: 20.sp,
                                          )),
                                    ],
                                  );
                                }).toList(),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: 10.sp,
                        ),
                        SizedBox(
                          width: 60.w,
                          child: defaultButton(
                              borderColor: ColorManager.secondary,
                              textColor: ColorManager.secondary,
                              buttonColor: ColorManager.white,
                              onPressed: () {
                                bloc.add(const SelectPhotoEvent(type: "after"));
                              },
                              text: "after photo"),
                        ),
                        bloc.afterPhotosFile.isNotEmpty
                            ? Wrap(
                                children: bloc.afterPhotosFile.map((image) {
                                  return Card(
                                    child: SizedBox(
                                      height: 100.sp,
                                      width: 100.sp,
                                      child: Image.file(File(image.path)),
                                    ),
                                  );
                                }).toList(),
                              )
                            : const SizedBox(),
                        afterPhotosNetwork.isNotEmpty
                            ? Wrap(
                                children: afterPhotosNetwork.map((image) {
                                  return Stack(
                                    children: [
                                      Card(
                                        child: SizedBox(
                                          height: 100.sp,
                                          width: 100.sp,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  image,
                                                  headers: {
                                                    "Cookie": ConstanceManager
                                                        .sessionId
                                                        .toString(),
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            bloc.add(
                                              RemoveMemoryImageEvent(
                                                  faultFormModel:
                                                      faultFormModel,
                                                  image: image),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            size: 20.sp,
                                          )),
                                    ],
                                  );
                                }).toList(),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: 10.sp,
                        ),
                        SizedBox(
                          width: 60.w,
                          child: defaultButton(
                              borderColor: ColorManager.secondary,
                              textColor: ColorManager.secondary,
                              buttonColor: ColorManager.white,
                              onPressed: () {
                                bloc.add(const SelectPhotoEvent(type: "bill"));
                              },
                              text: "Material Purchase Bill Photo"),
                        ),
                        bloc.billPhotosFile.isNotEmpty
                            ? Wrap(
                                children: bloc.billPhotosFile.map((image) {
                                  return Card(
                                    child: SizedBox(
                                      height: 100.sp,
                                      width: 100.sp,
                                      child: Image.file(File(image.path)),
                                    ),
                                  );
                                }).toList(),
                              )
                            : const SizedBox(),
                        purchaseBillNetwork.isNotEmpty
                            ? Wrap(
                                children: purchaseBillNetwork.map((image) {
                                  return Stack(
                                    children: [
                                      Card(
                                        child: SizedBox(
                                          height: 100.sp,
                                          width: 100.sp,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  image,
                                                  headers: {
                                                    "Cookie": ConstanceManager
                                                        .sessionId
                                                        .toString(),
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            bloc.add(
                                              RemoveMemoryImageEvent(
                                                  faultFormModel:
                                                      faultFormModel,
                                                  image: image),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            size: 20.sp,
                                          )),
                                    ],
                                  );
                                }).toList(),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: 2.h,
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: ColorManager.primary,
                                borderRadius:
                                    BorderRadiusDirectional.circular(10.sp)),
                            child: TextButton(
                                onPressed: () async {
                                  if (serviceType != null &&
                                      productId != -1 &&
                                      quantityTypeServiceController.text !=
                                          "") {
                                    bloc.add(AddServiceTypeBuilderToListEvent(
                                        ServiceTypeModel(
                                            quantity: double.parse(
                                                quantityTypeServiceController
                                                    .text),
                                            serviceTypeName: serviceType!,
                                            productId: productId)));
                                  }
                                  if (formKey.currentState!.validate()) {
                                    if (sub != null &&
                                        serviceTypes.isNotEmpty &&
                                        category != null &&
                                        (bloc.beforePhotosFile.isNotEmpty ||
                                            beforePhotosNetwork.isNotEmpty)) {
                                      print(
                                          "faultFormModel.beforePhotosIds, ${faultFormModel.beforePhotosIds}");

                                      bloc.add(UpdateFaultDataEvent(
                                        id: jobCard.id,
                                        faultFormModel: FaultFormModel(
                                          beforePhotosIds:
                                              faultFormModel.beforePhotosIds,
                                          afterPhotosIds:
                                              faultFormModel.afterPhotosIds,
                                          purchaseBillPhotoIds: faultFormModel
                                              .purchaseBillPhotoIds,
                                          beforePhotos:
                                              faultFormModel.beforePhotos,
                                          serviceTypesIds:
                                              faultFormModel.serviceTypesIds,
                                          technician1:
                                              faultFormModel.technician1,
                                          serviceTypes: serviceTypes,
                                          technician: faultFormModel.technician,
                                          technician2:
                                              faultFormModel.technician2,
                                          signaturePhoto:
                                              faultFormModel.signaturePhoto,
                                          afterPhotos:
                                              faultFormModel.afterPhotos,
                                          model: modelController.text,
                                          description:
                                              descriptionController.text,
                                          location: locationController.text,
                                          make: makeController.text,
                                          purchaseBillPhoto:
                                              faultFormModel.purchaseBillPhoto,
                                          serialNumber:
                                              serialNumberController.text,
                                          category: category!,
                                          subCategory: sub!,
                                          faultId: faultFormModel.faultId,
                                          comment: faultFormModel.comment,
                                        ),
                                      ));
                                      //Start Update Local PDF File
                                      bloc.add(GetPDFEvent(
                                        jobCardId: jobCard.id,
                                        pdfType: "fault",
                                      ));
                                      //End Update Local PDF File
                                      category = null;
                                      sub = null;
                                      modelController.clear();
                                      serviceTypes = [];
                                      beforePhotosNetwork.clear();
                                      afterPhotosNetwork.clear();
                                      purchaseBillNetwork.clear();
                                      descriptionController.clear();
                                      makeController.clear();
                                      serialNumberController.clear();
                                      locationController.clear();
                                    } else {
                                      warnToast(
                                          msg: "Please complete your data");
                                    }
                                  } else {
                                    warnToast(msg: "Please complete your data");
                                  }
                                },
                                child: Text(
                                  "Update",
                                  style: TextStyle(color: ColorManager.white),
                                ))),
                        SizedBox(
                          height: 4.h,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
