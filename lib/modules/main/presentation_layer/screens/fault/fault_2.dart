import 'dart:io';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/data_layer/models/fault_model.dart';
import 'package:bayanat/modules/main/data_layer/models/service_type_model.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/presentation_layer/bloc/main_bloc.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/fault/complaint_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/services/dep_injection.dart';
import '../../../../../core/utils/color_manager.dart';

class FaultScreen2 extends StatelessWidget {
  final JobCard jobCard;

  const FaultScreen2({
    super.key,
    required this.jobCard,
  });

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    TextEditingController makeController = TextEditingController();
    TextEditingController modelController = TextEditingController();
    TextEditingController serialNumberController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController quantityTypeServiceController =
        TextEditingController();
    var formKey = GlobalKey<FormState>();
    String? sub;
    String? category;
    String? serviceType;
    int productId = -1;
    List<ServiceTypeModel> serviceTypes = [];
    return BlocConsumer(
        bloc: bloc,
        listener: (context, state) {
          if (state is SelectSubState) {
            sub = state.sub;
          }
          if (state is SelectCategoryState) {
            sub = null;
            category = state.category;
          }
          if (state is SelectServiceTypeState) {
            serviceType = state.serviceType;
            productId = state.serviceTypeId;
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
          if (state is RemoveFromServiceTypeListState) {
            serviceTypes.remove(state.serviceType);
          }
          if (state is SaveFaultDataLoadingState) {
            showDialogLoading(context: context);
          } else if (state is SaveFaultDataErrorState) {
            context.pop();
            errorToast(msg: state.error);
          } else if (state is SaveFaultDataSuccessfullyState) {
            context.pop();
            bloc.getFaultModels.add(state.faultFormModel);
            showDialogSuccess(
              context: context,
              text: "The data has been saved",
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
                        backIcon(context: context)
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
                                        fontSize: 9.sp,
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
                              SizedBox(
                                height: 5.h,
                                child: defaultFormField(
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
                              ),
                              SizedBox(
                                height: 10.sp,
                              ),
                              SizedBox(
                                height: 5.h,
                                child: defaultFormField(
                                    controller: locationController,
                                    label: "Location",
                                    type: TextInputType.text,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'You must write a Location';
                                      }
                                      return null;
                                    }),
                              ),
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
                                        fontSize: 9.sp,
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
                              SizedBox(
                                height: 5.h,
                                child: defaultFormField(
                                    controller: makeController,
                                    label: "Make",
                                    type: TextInputType.text,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'You must write a Make';
                                      }
                                      return null;
                                    }),
                              ),
                              SizedBox(
                                height: 10.sp,
                              ),
                              SizedBox(
                                height: 5.h,
                                child: defaultFormField(
                                    controller: serialNumberController,
                                    label: "Serial Number",
                                    type: TextInputType.text,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'You must write a Serial Number';
                                      }
                                      return null;
                                    }),
                              ),

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
                        SizedBox(
                          height: 2.h,
                        ),
                        // Container(
                        //     decoration: BoxDecoration(
                        //         color: ColorManager.primary,
                        //         borderRadius:
                        //             BorderRadiusDirectional.circular(10.sp)),
                        //     child: TextButton(
                        //         onPressed: () {
                        //           if (serviceType != null &&
                        //               serviceTypeId != null &&
                        //               quantityTypeServiceController.text !=
                        //                   "") {
                        //             bloc.add(AddServiceTypeBuilderToListEvent(
                        //                 ServiceTypeModel(
                        //                     quantity: double.parse(
                        //                         quantityTypeServiceController
                        //                             .text),
                        //                     serviceTypeName: serviceType!,
                        //                     serviceTypeId: serviceTypeId!)));
                        //           }
                        //           if (formKey.currentState!.validate()) {
                        //             if (sub != null &&
                        //                 bloc.serviceTypes.isNotEmpty &&
                        //                 category != null &&
                        //                 bloc.beforePhotosFile.isNotEmpty) {
                        //               bloc.add(AddFaultReportEvent(
                        //                 id: id,
                        //                 faultFormModel: FaultFormModel(
                        //                   beforePhotos: const [],
                        //                   technician1: '',
                        //                   technician: '',
                        //                   technician2: '',
                        //                   signaturePhoto: '',
                        //                   afterPhotos: const [],
                        //                   model: modelController.text,
                        //                   description:
                        //                       descriptionController.text,
                        //                   location: locationController.text,
                        //                   make: makeController.text,
                        //                   purchaseBillPhoto: const [],
                        //                   serialNumber:
                        //                       serialNumberController.text,
                        //                   category: category!,
                        //                   subCategory: sub!,
                        //                   comment: "",
                        //                 ),
                        //               ));
                        //               modelController.clear();
                        //               locationController.clear();
                        //               makeController.clear();
                        //               descriptionController.clear();
                        //               serialNumberController.clear();
                        //             } else {
                        //               warnToast(
                        //                   msg: "Please complete your data");
                        //             }
                        //           } else {
                        //             warnToast(msg: "Please complete your data");
                        //           }
                        //         },
                        //         child: Text(
                        //           "Add New",
                        //           style: TextStyle(color: ColorManager.white),
                        //         ))),
                        Container(
                            decoration: BoxDecoration(
                                color: ColorManager.primary,
                                borderRadius:
                                    BorderRadiusDirectional.circular(10.sp)),
                            child: TextButton(
                                onPressed: () {
                                  if (serviceType != null &&
                                      productId != -1 &&
                                      quantityTypeServiceController.text !=
                                          "") {
                                    bloc.add(AddServiceTypeBuilderToListEvent(
                                        ServiceTypeModel(
                                          productId: productId,
                                            quantity: double.parse(
                                                quantityTypeServiceController
                                                    .text),
                                            serviceTypeName: serviceType!,
                                            serviceTypeId: productId)));
                                  }
                                  if (formKey.currentState!.validate()) {
                                    if (sub != null &&
                                        serviceTypes.isNotEmpty &&
                                        category != null &&
                                        bloc.beforePhotosFile.isNotEmpty) {
                                      bloc.add(SaveFaultDataEvent(
                                        jobCard: jobCard,
                                        faultFormModel: FaultFormModel(
                                          beforePhotos: const [],
                                          technician1: '',
                                          serviceTypes: serviceTypes,
                                          technician: '',
                                          technician2: '',
                                          signaturePhoto: '',
                                          afterPhotos: const [],
                                          model: modelController.text,
                                          description:
                                              descriptionController.text,
                                          location: locationController.text,
                                          make: makeController.text,
                                          purchaseBillPhoto: const [],
                                          serialNumber:
                                              serialNumberController.text,
                                          category: category!,
                                          subCategory: sub!,
                                          comment: "",
                                        ),
                                      ));
                                      category = null;
                                      sub = null;
                                      serviceTypes = [];
                                      modelController.clear();
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
                                  "Save",
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
