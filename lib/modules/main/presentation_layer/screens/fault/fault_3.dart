import 'dart:io';
import 'package:bayanat/core/services/dep_injection.dart';
import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/presentation_layer/bloc/main_bloc.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/history_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';

//ignore: must_be_immutable
class FaultScreen3 extends StatelessWidget {
  final JobCard jobCard;

  const FaultScreen3({super.key, required this.jobCard});

  @override
  Widget build(BuildContext context) {
    int selectedReportType = 0;
    MainBloc bloc = sl();
    bloc.add(SelectReportTypeEvent(
        index: 0,
        faultFormModel: bloc.getFaultModels.last,
        selectedReportType: selectedReportType));
    TextEditingController commentController = TextEditingController();
    TextEditingController technician1Controller = TextEditingController();
    TextEditingController technician2Controller = TextEditingController();
    return BlocConsumer(
        listener: (context, state) {
          if (state is SubmitFaultReportSuccessfullyState) {
            showDialogSuccess(
              context: context,
              text: "The report has been sent",
              onPressed: () {
                bloc.add(GetJobCardEvent(context: context));
                context.pushAndRemove(const HistoryScreen());
              },
            );
          } else if (state is SubmitFaultReportLoadingState) {
            showDialogLoading(context: context);
          } else if (state is ReviewReportLoadingState) {
            showDialogLoading(context: context);
          } else if (state is ReviewReportState) {
            context.pop();
          } else if (state is SubmitFaultReportErrorState) {
            context.pop();
          }
          if (state is SelectReportTypeState) {
            selectedReportType = state.selectedReportType;
          }
        },
        bloc: bloc,
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      screenCoverBuilder(40,
                          title: "SELECT STAGE TWO",
                          width: 0.1 / 8,
                          fontSize: 20.sp),
                      backIcon(context: context)
                    ],
                  ),
                  SizedBox(
                    height: 20.sp,
                  ),
                  SizedBox(
                    width: 80.w,
                    child: defaultFormField(
                      controller: commentController,
                      label: "Comment",
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SizedBox(
                    width: 80.w,
                    child: defaultFormField(
                      controller: technician1Controller,
                      label: "Technician 1",
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SizedBox(
                    width: 80.w,
                    child: defaultFormField(
                      controller: technician2Controller,
                      label: "Technician 2",
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SizedBox(
                    width: 60.w,
                    child: signatureButtonBuilder(
                        bloc: bloc,
                        text: "Customer Signture",
                        context: context,
                        type: "signture"),
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
                    height: 20.sp,
                  ),
                  defaultButton(
                      buttonColor: ColorManager.primary,
                      fontSize: 10.sp,
                      height: 8.h,
                      width: 40.w,
                      onPressed: () {
                        bloc.getFaultModels.last.comment =
                            commentController.text;
                        bloc.getFaultModels.last.technician1 =
                            technician1Controller.text;
                        bloc.getFaultModels.last.technician2 =
                            technician2Controller.text;
                        if (bloc.getFaultModels.isNotEmpty) {
                          bloc.add(ReviewReportEvent(
                            jobCard: jobCard,
                          ));
                        }
                      },
                      text: "Review Report"),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.sp),
                    child: Text(
                      "Just choose one",
                      style: TextStyle(color: ColorManager.secondary),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      defaultButton(
                          buttonColor: selectedReportType != 0
                              ? ColorManager.primary
                              : ColorManager.secondary,
                          fontSize: 10.sp,
                          height: 8.h,
                          width: 40.w,
                          onPressed: () {
                            bloc.add(SelectReportTypeEvent(
                                index: 0,
                                faultFormModel: bloc.getFaultModels.last,
                                selectedReportType: selectedReportType));
                          },
                          text: "FAULT REPORT"),
                      SizedBox(
                        width: 10.sp,
                      ),
                      defaultButton(
                          buttonColor: selectedReportType != 1
                              ? ColorManager.primary
                              : ColorManager.secondary,
                          fontSize: 10.sp,
                          height: 8.h,
                          width: 40.w,
                          onPressed: () {
                            bloc.add(SelectReportTypeEvent(
                                index: 1,
                                faultFormModel: bloc.getFaultModels.last,
                                selectedReportType: selectedReportType));
                          },
                          text: "COMPLETION REPORT")
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: Row(
                      children: [
                        Expanded(
                            child: defaultButton(
                                borderColor: ColorManager.secondary,
                                buttonColor: ColorManager.white,
                                textColor: ColorManager.secondary,
                                onPressed: () {
                                  context.pop();
                                },
                                text: "Edit")),
                        SizedBox(
                          width: 10.sp,
                        ),
                        Expanded(
                            child: defaultButton(
                                buttonColor: ColorManager.secondary,
                                onPressed: () async {
                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  final filePath =
                                      "${directory.path}/jobcard_${jobCard.id}_fault.pdf";
                                  final pdfFile = File(filePath);
                                  if (await pdfFile.exists()) {
                                    await pdfFile.delete();
                                    print("File Deleted");
                                  }
                                  final connectivityResults =
                                      await Connectivity().checkConnectivity();
                                  final hasInternet = connectivityResults
                                      .any((r) => r != ConnectivityResult.none);

                                  if (!hasInternet) {
                                    final signaturePath =
                                        bloc.signaturePhoto?.path;
                                    final cachedReport = {
                                      'jobCardId': jobCard.id,
                                      'formModel': bloc.getFaultModels.last
                                          .toJson(id: jobCard.id),
                                      'signaturePath': signaturePath,
                                    };
                                    await Hive.box('offlineReports').put(
                                        jobCard.id.toString(), cachedReport);

                                    defaultToast(
                                        msg:
                                            "You're offline. We'll send it when back online.");

                                    return;
                                  }

                                  // if (bloc.signaturePhoto != null) {
                                  //   bloc.getFaultModels.last.comment =
                                  //       commentController.text;
                                  //   bloc.getFaultModels.last.technician1 =
                                  //       technician1Controller.text;
                                  //   bloc.getFaultModels.last.technician2 =
                                  //       technician2Controller.text;
                                  bloc.add(SubmitFaultReportEvent(
                                    jobCard: jobCard,
                                  ));
                                  // } else {
                                  //   warnToast(msg: "Please complete your data");
                                  // }
                                },
                                text: "Confirm")),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
