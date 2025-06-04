import 'dart:io';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/data_layer/models/amc_ac_checklsit_model.dart';
import 'package:bayanat/modules/main/presentation_layer/bloc/main_bloc.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/amc_card/add_ac.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/services/dep_injection.dart';
import '../../../../../core/utils/color_manager.dart';

//ignore: must_be_immutable
class AmcCardScreen2 extends StatelessWidget {
  int? amcCardId;
  String? property;
  int? flatNumber;
  String? acType;
  String? location;
  String? acSerialNumber;
  String? modelNumber;
  String? typeOfService;

  AmcCardScreen2(
      {super.key,
      this.amcCardId,
      this.property,
      this.typeOfService,
      this.flatNumber,
      this.acType,
      this.location,
      this.acSerialNumber,
      this.modelNumber});

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    TextEditingController attendingTechnicianController =
        TextEditingController();
    TextEditingController commentController = TextEditingController();
    return BlocConsumer(
        bloc: bloc,
        listener: (context, state) {
          if (state is SubmitAmcCardReportSuccessfullyState) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.sp),
                  ),
                  title: Text(
                    "The report has been sent",
                    style: TextStyle(
                      color: ColorManager.primary,
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          bloc.add(GetJobCardEvent(context: context));
                          context.pushAndRemove(const JobCardScreen());
                        },
                        child: Text(
                          "Okay",
                          style: TextStyle(color: ColorManager.secondary),
                        )),
                  ],
                );
              },
            );
          } else if (state is SubmitAmcCardReportLoadingState) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.sp),
                  ),
                  title: const Center(child: CircularProgressIndicator()),
                );
              },
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: 60.sp,
                      bottom: 20.sp,
                      end: 20.sp,
                      start: 20.sp,
                    ),
                    child: SizedBox(
                      height: 50.h,
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: EdgeInsets.all(5.sp),
                          child: SingleChildScrollView(
                            child: Column(
                              children: List.generate(
                                  ConstanceManager.amcCardQuestions.length,
                                  (index) => listAmcCard(
                                      text: ConstanceManager
                                          .amcCardQuestions[index],
                                      bloc: bloc,
                                      index: index + 1)).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(
                          color: ColorManager.primary,
                          borderRadius:
                              BorderRadiusDirectional.circular(10.sp)),
                      child: TextButton(
                          onPressed: () {
                            bloc.amcCardQuestionsAnswers = [];
                            bloc.selectedAmcCardAcType = null;
                            context.push(AddAcScreen(
                              flatNumber: flatNumber!,
                              property: property!,
                              amcCardId: amcCardId!,
                            ));
                          },
                          child: Text(
                            "Add AC",
                            style: TextStyle(color: ColorManager.white),
                          ))),
                  SizedBox(
                    height: 1.5.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.sp),
                    child: SizedBox(
                      width: 60.w,
                      child: defaultFormField(
                          controller: attendingTechnicianController,
                          label: 'Attending Technician',
                          validator: (value) {
                            if (value.isNull) {
                              return "This Field is required";
                            }
                            return null;
                          }),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.sp),
                    child: SizedBox(
                      width: 60.w,
                      child: defaultFormField(
                        controller: commentController,
                        label: 'Comment',
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.sp),
                    child: SizedBox(
                      width: 60.w,
                      child: signatureButtonBuilder(
                          bloc: bloc,
                          text: "Customer Signture",
                          type: "tenant",
                          context: context),
                    ),
                  ),
                  bloc.tenantSignature != null
                      ? Card(
                          child: SizedBox(
                            height: 100.sp,
                            width: 100.sp,
                            child: Image.file(File(bloc.tenantSignature!.path)),
                          ),
                        )
                      : const SizedBox(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.sp),
                    child: SizedBox(
                      width: 60.w,
                      child: signatureButtonBuilder(
                          bloc: bloc, context: context, type: "signture"),
                    ),
                  ),
                  bloc.signaturePhoto != null
                      ? Card(
                          child: SizedBox(
                            height: 100.sp,
                            width: 100.sp,
                            child: Image.file(File(bloc.signaturePhoto!.path)),
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(
                    height: 10.sp,
                  ),
                  defaultButton(
                      width: 40.w,
                      onPressed: () async {
                        if (bloc.signaturePhoto != null &&
                            bloc.tenantSignature != null) {
                          AmcAcCheckListModel checkList = AmcAcCheckListModel(
                              acSerialNumber: acSerialNumber!,
                              acType: acType!,
                              property: bloc.selectedAmcCardProperty!,
                              writeDate: DateTime.now().toString(),
                              attendingTechnician:
                                  attendingTechnicianController.text,
                              comments: commentController.text,
                              numServices: typeOfService!,
                              flatNumber: flatNumber.toString(),
                              id: amcCardId!,
                              list: bloc.amcCardQuestionsAnswers,
                              location: location!,
                              modelNumber: modelNumber!,
                              signature: bloc.signtureEncoded!,
                              tenantRepresentative: bloc.tenantEncoded!);
                          bloc.amcAcCheckLists.add(checkList);
                          bloc.flatNumbers[bloc.propertyIndex - 1]
                              .add(flatNumber!);
                          bloc.add(SubmitAmcCardReportEvent(
                              amcCardId: amcCardId!,
                              amcAcCheckListModels: bloc.amcAcCheckLists));
                        } else {
                          warnToast(msg: "You must sign");
                        }
                      },
                      text: 'Submit',
                      buttonColor: ColorManager.secondary,
                      textColor: ColorManager.white),
                  SizedBox(
                    height: 30.sp,
                  )
                ],
              ),
            ),
          );
        });
  }
}
