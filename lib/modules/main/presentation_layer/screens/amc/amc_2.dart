import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/amc/amc_3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/services/dep_injection.dart';
import '../../../../../core/utils/color_manager.dart';
import '../../bloc/main_bloc.dart';

class AmcScreen2 extends StatelessWidget {
  final JobCard jobCard;
  const AmcScreen2({super.key, required this.jobCard});

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl()..add(const GetSparesEvent());
    DateTime dateTime = DateTime.parse(jobCard.writeDate);
    dateTime = dateTime.add(const Duration(hours: 4));
    String date = DateFormat.yMd().format(dateTime);
    var formKey = GlobalKey<FormState>();
    String time = DateFormat.Hm().format(dateTime);
    return Scaffold(
      body: BlocBuilder<MainBloc, MainState>(
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
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Date  ",
                                          style: TextStyle(
                                              color: ColorManager.primary,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          date
                                              .toString()
                                              .replaceAll("00:00:00.000", ""),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Time  ",
                                          style: TextStyle(
                                              color: ColorManager.primary,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          time,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Property / Site   ",
                                    style: TextStyle(
                                        color: ColorManager.primary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      jobCard.buildingNumber,
                                      style: TextStyle(
                                          color: ColorManager.black,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600),
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
                                    "Customer name   ",
                                    style: TextStyle(
                                        color: ColorManager.primary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      jobCard.customerName[1],
                                      style: TextStyle(
                                          color: ColorManager.black,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600),
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
                                    "Flat number   ",
                                    style: TextStyle(
                                        color: ColorManager.primary,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      jobCard.flatNumber,
                                      style: TextStyle(
                                          color: ColorManager.black,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600),
                                    ),
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
                      context.push(AmcScreen3(
                        jobCard: jobCard,
                        dateTime:dateTime,
                      ));
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
