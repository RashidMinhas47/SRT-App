import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/presentation_layer/bloc/main_bloc.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/amc_card/amc_card_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/services/dep_injection.dart';
import '../../../../../core/utils/color_manager.dart';
import '../../../domain_layer/entities/amc_card.dart';

class AmcCardScreen1 extends StatelessWidget {
  final AmcCard amcCard;
  final int amcCardId;

  const AmcCardScreen1(
      {super.key, required this.amcCard, required this.amcCardId});

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl()..add(GetAmcBuildingsEvent(amcCardId: amcCardId));
    TextEditingController flatNumberController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController modelController = TextEditingController();
    TextEditingController acSerialNumberController = TextEditingController();
    String? selectedTypeOfService;
    var formKey = GlobalKey<FormState>();
    return BlocConsumer(
        listener: (context, state) {
          if (state is SelectTypeOfServiceState) {
            selectedTypeOfService = state.selectedTypeOfService;
          }
        },
        bloc: bloc,
        builder: (context, state) {
          return Scaffold(
              body: state is GetAmcBuildingsDataLoadingState
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: Form(
                        key: formKey,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Property",
                                            style: TextStyle(
                                                color: ColorManager.primary,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: dropdownBuilder(
                                              value:
                                                  bloc.selectedAmcCardProperty,
                                              onChanged: (String? value) {
                                                bloc.add(SelectAmcPropertyEvent(
                                                    property: value!,
                                                    propertyIndex: bloc
                                                            .amcCardProperties
                                                            .indexOf(value) +
                                                        1));
                                              },
                                              items: bloc.amcCardProperties),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 10.sp),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Flat number",
                                            style: TextStyle(
                                                color: ColorManager.primary,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: defaultFormField(
                                              controller: flatNumberController,
                                              type: TextInputType.number,
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'You must write a Tonnage';
                                                }
                                                return null;
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 10.sp),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                                bloc.add(SelectAmcAcTypeEvent(
                                                  acType: value!,
                                                ));
                                              },
                                              items: bloc.amcCardAcTypes[
                                                  bloc.propertyIndex]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 10.sp),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                                if (value!.isEmpty) {
                                                  return 'You must write a Tonnage';
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                                if (value!.isEmpty) {
                                                  return 'You must write a Tonnage';
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                              controller:
                                                  acSerialNumberController,
                                              type: TextInputType.text,
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'You must write a Tonnage';
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                                bloc.add(
                                                    SelectTypeOfServiceEvent(
                                                        typeOfService: value!));
                                              },
                                              items: ConstanceManager
                                                  .typeOfServiceList),
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
                                  if (formKey.currentState!.validate()) {
                                    if (bloc.selectedAmcCardAcType != null &&
                                        selectedTypeOfService != null &&
                                        bloc.selectedAmcCardProperty != null) {
                                      if (bloc
                                          .flatNumbers[bloc.propertyIndex - 1]
                                          .contains(int.parse(
                                              flatNumberController.text))) {
                                        warnToast(
                                            msg:
                                                "This flat number is already used");
                                      } else {
                                        context.push(AmcCardScreen2(
                                          amcCardId: amcCardId,
                                          property:
                                              bloc.selectedAmcCardProperty!,
                                          acType: bloc.selectedAmcCardAcType!,
                                          typeOfService: selectedTypeOfService!,
                                          acSerialNumber:
                                              acSerialNumberController.text,
                                          flatNumber: int.parse(
                                              flatNumberController.text),
                                          location: locationController.text,
                                          modelNumber: modelController.text,
                                        ));
                                      }
                                    } else {
                                      errorToast(
                                          msg: "Please complete required data");
                                    }
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
                      ),
                    ));
        });
  }
}
