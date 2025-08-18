import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/services/dep_injection.dart';
import '../../../../../core/utils/color_manager.dart';
import '../../../../../core/utils/navigation_manager.dart';
import '../../bloc/main_bloc.dart';
import 'amc_4.dart';

//ignore: must_be_immutable
class AmcScreen3 extends StatelessWidget {
  final JobCard jobCard;
  final DateTime dateTime;

  const AmcScreen3(
      {super.key,
      required this.jobCard,
      required this.dateTime,
      });

  @override
  Widget build(BuildContext context) {
    TextEditingController tonnageController = TextEditingController();
    TextEditingController brandController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController modelNumberController = TextEditingController();
    TextEditingController acSerialNumberController = TextEditingController();
    TextEditingController compressorNumberController = TextEditingController();
    var formKey = GlobalKey<FormState>();
    String? workStatus;
    String? acType;
    MainBloc bloc = sl();
    return Scaffold(
      body: BlocConsumer<MainBloc, MainState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is SelectWorkStatusState) {
            workStatus = state.workStatus;
          }if (state is SelectAcTypeState) {
            acType = state.acType;
          }
        },
        builder: (context, state) {
          return Form(
            key: formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            screenCoverBuilder(40),
                            backIcon(context: context)
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Type of AC   ",
                                    style: TextStyle(
                                        color: ColorManager.primary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: dropdownBuilder(
                                        value: acType,
                                        onChanged: (String? value) {
                                          bloc.add(SelectAcTypeEvent(
                                              acType: value!));
                                        },
                                        items: ConstanceManager.acTypes),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Tonnage  ",
                                      style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 5.h,
                                      child: defaultFormField(
                                        controller: tonnageController,
                                        type: TextInputType.number,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'You must write a Tonnage';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Brand  ",
                                      style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 5.h,
                                      child: defaultFormField(
                                        controller: brandController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'You must write a Brand';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Location   ",
                                      style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 5.h,
                                      child: defaultFormField(
                                        controller: locationController,
                                        type: TextInputType.text,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'You must write a location';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Model number   ",
                                      style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 5.h,
                                      child: defaultFormField(
                                        controller: modelNumberController,
                                        type: TextInputType.text,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'You must write a Model number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "AC serial number   ",
                                      style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 5.h,
                                      child: defaultFormField(
                                        controller: acSerialNumberController,
                                        type: TextInputType.text,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'You must write a AC serial number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Compressor number",
                                      style: TextStyle(
                                          color: ColorManager.primary,
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 5.h,
                                      child: defaultFormField(
                                        controller: compressorNumberController,
                                        type: TextInputType.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Work Status  ",
                                    style: TextStyle(
                                        color: ColorManager.primary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: dropdownBuilder(
                                        value: workStatus,
                                        onChanged: (String? value) {
                                          bloc.add(SelectWorkStatusEvent(
                                              workStatus: value!));
                                        },
                                        items: ConstanceManager.workStatusList),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.sp,
                ),
                defaultButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (acType != null && workStatus != null) {
                          context.push(AmcScreen4(
                            location: locationController.text,
                            workStatus: workStatus!,
                            acType: acType!,
                            id: jobCard.id,
                            jobCard: jobCard,
                            dateTime: dateTime,
                            tonnage: double.parse(tonnageController.text),
                            brand: brandController.text,
                            acSerialNumber: acSerialNumberController.text,
                            compressorNumber: compressorNumberController.text,
                            modelNumber: modelNumberController.text,
                          ));
                        } else {
                          warnToast(msg: "Please select Type od AC");
                        }
                      }
                    },
                    text: "Next",
                    width: 40.w,
                    buttonColor: ColorManager.secondary,
                    fontSize: 22.sp,
                    textColor: ColorManager.white),
                SizedBox(
                  height: 20.sp,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
