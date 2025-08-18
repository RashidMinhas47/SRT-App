import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/fault/fault_3.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/services/dep_injection.dart';
import '../../../../../core/utils/color_manager.dart';
import '../../../domain_layer/entities/job_card.dart';
import '../../bloc/main_bloc.dart';
import '../../components/components.dart';
import 'fault_2.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final JobCard jobCard;

  const ComplaintDetailsScreen({
    super.key,
    required this.jobCard,
  });

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    // 
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            context.pushAndRemove(const JobCardScreen());
          },
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      screenCoverBuilder(35, width: 0.2),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.only(top: 10.h, start: 4.w),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                              onPressed: () {
                                context.pushAndRemove(const JobCardScreen());
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                size: 25.sp,
                                color: ColorManager.white,
                              )),
                        ),
                      )
                    ],
                  ),
                  state is GetFaultLoadingState
                      ? Column(
                          children: [
                            SizedBox(
                              height: 5.h,
                            ),
                            const CircularProgressIndicator(),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.all(20.sp),
                          child: Container(
                            padding: EdgeInsets.all(5.sp),
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorManager.primary),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Complaint Details",
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline),
                                ),
                                SizedBox(height: 2.h),
                                if (bloc.getFaultModels.isNotEmpty)
                                  Table(
                                    border: TableBorder.all(
                                        color: ColorManager.primary),
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: ColorManager.white,
                                        ),
                                        children: [
                                          columnText(
                                              text: "Sub",
                                              textColor: ColorManager.black,
                                              containerColor:
                                                  ColorManager.white),
                                          columnText(
                                              text: "Location",
                                              textColor: ColorManager.black,
                                              containerColor:
                                                  ColorManager.white),
                                          columnText(
                                              text: "Description",
                                              textColor: ColorManager.black,
                                              containerColor:
                                                  ColorManager.white),
                                          columnText(
                                              text: "Type of Service",
                                              textColor: ColorManager.black,
                                              containerColor:
                                                  ColorManager.white),
                                        ],
                                      ),
                                      ...getSavedFaultRows(
                                          jobCard: jobCard,
                                          faultForms: bloc.getFaultModels,
                                          context: context),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                          onPressed: () {
                                            context.push(FaultScreen2(
                                              jobCard: jobCard,
                                            ));
                                          },
                                          child: Text(
                                            "Add New Data",
                                            style: TextStyle(
                                                color: ColorManager.black),
                                          )),
                                    ),
                                    Expanded(
                                      child: TextButton(
                                          onPressed: () {
                                            if (bloc
                                                .getFaultModels.isNotEmpty) {
                                              context.push(FaultScreen3(
                                                jobCard: jobCard,
                                              ));
                                            } else {
                                              warnToast(
                                                  msg:
                                                      "You must add at least one data");
                                            }
                                          },
                                          child: Text("Confirm",
                                              style: TextStyle(
                                                  color: ColorManager.black))),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
