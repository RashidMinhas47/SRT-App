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
import 'amc_5.dart';

class AmcScreen4 extends StatelessWidget {
  final String acType;
  final double tonnage;
  final String brand;
  final String location;
  final String modelNumber;
  final String workStatus;
  final JobCard jobCard;
  final int id;
  final DateTime dateTime;
  final String compressorNumber;
  final String acSerialNumber;

  const AmcScreen4({
    super.key,
    required this.acType,
    required this.tonnage,
    required this.jobCard,
    required this.brand,
    required this.location,
    required this.dateTime,
    required this.workStatus,
    required this.id,
    required this.acSerialNumber,
    required this.compressorNumber,
    required this.modelNumber,
  });

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    List<int> list = [];
    return Scaffold(
      body: BlocConsumer<MainBloc, MainState>(
        listener: (context, state) {
          if (state is AddToListAmcReportState) {
            list = state.list;
          }
          if (state is RemoveFromListAmcReportState) {
            list = state.list;
          }
        },
        builder: (context, state) {
          return BlocBuilder<MainBloc, MainState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            screenCoverBuilder(20),
                            backIcon(context: context)
                          ],
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Expanded(
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.sp),
                              child: Card(
                                child: Container(
                                  padding: EdgeInsetsDirectional.all(8.sp),
                                  child: ListView.separated(
                                    itemBuilder: (context, index) => listAmc(
                                        bloc: bloc,
                                        text: ConstanceManager.checkList[index],
                                        index: index + 1),
                                    separatorBuilder: (context, index) =>
                                        SizedBox(
                                      height: 4.h,
                                    ),
                                    itemCount:
                                        ConstanceManager.checkList.length,
                                  ),
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.sp,
                  ),
                  defaultButton(
                      onPressed: () {
                        context.push(AmcScreen5(
                            list: list,
                            workStatus: workStatus,
                            id: id,
                            location: location,
                            jobCard: jobCard,
                            acSerialNumber: acSerialNumber,
                            acType: acType,
                            brand: brand,
                            compressorNumber: compressorNumber,
                            tonnage: tonnage,
                            modelNumber: modelNumber,
                            dateTime: dateTime));
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
              );
            },
          );
        },
      ),
    );
  }
}
