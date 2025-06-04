import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/presentation_layer/bloc/main_bloc.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/services/dep_injection.dart';
import '../../../../../core/utils/color_manager.dart';


class FaultScreen1 extends StatelessWidget {
  final JobCard jobCard;

  const FaultScreen1({super.key, required this.jobCard, });

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    bool isAcBefore = true;
    return BlocConsumer<MainBloc, MainState>(
      listener: (context, state) {
        if (state is CheckIsAcBeforeState) {
          isAcBefore = state.isAcBefore;
        }
      },
      builder: (context, state) {
        return Scaffold(
            body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  screenCoverBuilder(
                    40,
                    title: "JOB CARD NAME",
                    width: 0.1 / 2,
                  ),
                  backIcon(context: context)
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 10.sp, vertical: 5.h),
                child: Container(
                  color: ColorManager.secondary,
                  child: Table(
                    border: TableBorder.all(color: ColorManager.primary),
                    children: [
                      TableRow(children: [
                        jobCardDataItemBuilder(
                            title: 'Name', value: jobCard.customerName[1]),
                        jobCardDataItemBuilder(
                            title: 'Phone Number', value: jobCard.phoneNumber)
                      ]),
                      TableRow(children: [
                        jobCardDataItemBuilder(
                            title: 'Location', value: jobCard.location),
                        jobCardDataItemBuilder(
                            title: 'Building Number',
                            value: jobCard.buildingNumber)
                      ]),
                      TableRow(children: [
                        jobCardDataItemBuilder(
                            title: 'House/Flat Number',
                            value: jobCard.flatNumber),
                        jobCardDataItemBuilder(
                            title: 'Complaint Number',
                            value: jobCard.complaintNumber)
                      ]),
                      TableRow(children: [
                        jobCardDataItemBuilder(
                            title: 'Job Card Number',
                            value: jobCard.jobCardNumber),
                        jobCardDataItemBuilder(
                            title: 'Description', value: jobCard.description)
                      ]),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(bottom: 35.sp, left: 10.sp, right: 10.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: defaultButton(
                            borderColor: ColorManager.secondary,
                            onPressed: () {
                              bloc.add(IgnoreJobCardEvent(id: jobCard.id));
                              context.pop();
                            },
                            text: 'IGNORE',
                            buttonColor: ColorManager.white,
                            textColor: ColorManager.secondary)),
                    SizedBox(
                      width: 10.sp,
                    ),
                    Expanded(
                        child: !isAcBefore
                            ? const Center(child: CircularProgressIndicator())
                            : defaultButton(
                                onPressed: () {
                                  bloc.add(const CheckIsAcBeforeEvent(
                                    isAcBefore: false,
                                  ));
                                  bloc.add(GetFaultEvent(
                                      isComplaint: false,
                                      context: context,
                                      jobCard: jobCard));
                                  warnToast(
                                      msg: "Checking if there are ac before");
                                  bloc.add(AcceptJobCardEvent(id: jobCard.id));
                                },
                                text: 'ACCEPT',
                                buttonColor: ColorManager.secondary,
                                textColor: ColorManager.white))
                  ],
                ),
              )
            ],
          ),
        ));
      },
    );
  }
}
