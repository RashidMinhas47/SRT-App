import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/data_layer/models/amc_ac_checklsit_model.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/services/dep_injection.dart';
import '../../../../../core/utils/color_manager.dart';
import '../../bloc/main_bloc.dart';
import 'amc_card_2.dart';

// ignore: must_be_immutable
class AddAcScreen extends StatelessWidget {
  final int amcCardId;
  final String property;

  final int flatNumber;

  const AddAcScreen(
      {super.key,
      required this.amcCardId,
      required this.property,
      required this.flatNumber});

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    TextEditingController locationController = TextEditingController();
    TextEditingController modelController = TextEditingController();
    TextEditingController acSerialNumberController = TextEditingController();
    String? selectedTypeOfService;
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) {
        if (state is SelectTypeOfServiceState) {
          selectedTypeOfService = state.selectedTypeOfService;
        }
      },
      bloc: bloc,
      builder: (context, state) {
        return Scaffold(
            body: SingleChildScrollView(
          child: Column(
            children: [
              screenCoverBuilder(40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.sp),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40.sp,
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Type of Ac",
                              style: TextStyle(
                                  color: ColorManager.primary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: dropdownBuilder(
                                value: bloc.selectedAmcCardAcType,
                                onChanged: (String? value) {
                                  bloc.add(
                                      SelectAmcAcTypeEvent(acType: value!));
                                },
                                items: bloc.amcCardAcTypes[bloc.propertyIndex]),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Location",
                              style: TextStyle(
                                  color: ColorManager.primary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: defaultFormField(
                                controller: locationController,
                                type: TextInputType.text,
                                validator: (value) {
                                  if (value.isNull) {
                                    return "This field is required";
                                  }
                                  return null;
                                }),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Model number",
                              style: TextStyle(
                                  color: ColorManager.primary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: defaultFormField(
                                controller: modelController,
                                type: TextInputType.text,
                                validator: (value) {
                                  if (value.isNull) {
                                    return "This field is required";
                                  }
                                  return null;
                                }),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Ac serial number",
                              style: TextStyle(
                                  color: ColorManager.primary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: defaultFormField(
                                controller: acSerialNumberController,
                                type: TextInputType.text,
                                validator: (value) {
                                  if (value.isNull) {
                                    return "This field is required";
                                  }
                                  return null;
                                }),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "Type of Service",
                              style: TextStyle(
                                  color: ColorManager.primary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: dropdownBuilder(
                                value: selectedTypeOfService,
                                onChanged: (String? value) {
                                  bloc.add(SelectTypeOfServiceEvent(
                                      typeOfService: value!));
                                },
                                items: ConstanceManager.typeOfServiceList),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              defaultButton(
                  width: 40.w,
                  onPressed: () {
                    if (bloc.selectedAmcCardAcType != null &&
                        selectedTypeOfService != null) {
                      AmcAcCheckListModel checkList = AmcAcCheckListModel(
                          acSerialNumber: acSerialNumberController.text,
                          acType: bloc.selectedAmcCardAcType!,
                          writeDate: DateTime.now().toString(),
                          attendingTechnician: "",
                          property: property,
                          comments: "",
                          flatNumber: flatNumber.toString(),
                          id: amcCardId,
                          list: bloc.amcCardQuestionsAnswers,
                          location: locationController.text,
                          modelNumber: modelController.text,
                          signature: '',
                          tenantRepresentative: '',
                          numServices: selectedTypeOfService!);
                      bloc.amcAcCheckLists.add(checkList);
                      context.push(AmcCardScreen2(
                        flatNumber: flatNumber,
                        modelNumber: modelController.text,
                        location: locationController.text,
                        acType: bloc.selectedAmcCardAcType!,
                        acSerialNumber: acSerialNumberController.text,
                        typeOfService: selectedTypeOfService!,
                        property: property,
                        amcCardId: amcCardId,
                      ));
                    } else {
                      warnToast(msg: "Please complete your data");
                    }
                  },
                  text: 'Next',
                  buttonColor: ColorManager.secondary,
                  textColor: ColorManager.white),
              SizedBox(
                height: 30.sp,
              )
            ],
          ),
        ));
      },
    );
  }
}
