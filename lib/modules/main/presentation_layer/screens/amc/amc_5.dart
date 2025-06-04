import 'dart:io';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/data_layer/models/amc_model.dart';
import 'package:bayanat/modules/main/data_layer/models/spare_c_model.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/services/dep_injection.dart';
import '../../../../../core/utils/color_manager.dart';
import '../../bloc/main_bloc.dart';
import '../history_screen.dart';

class AmcScreen5 extends StatelessWidget {
  final String acType;
  final double tonnage;
  final String brand;
  final String workStatus;
  final String modelNumber;
  final String acSerialNumber;
  final String compressorNumber;
  final String location;
  final DateTime dateTime;
  final JobCard jobCard;
  final int id;
  final List<int> list;

  const AmcScreen5({
    super.key,
    required this.list,
    required this.id,
    required this.jobCard,
    required this.acSerialNumber,
    required this.acType,
    required this.brand,
    required this.workStatus,
    required this.location,
    required this.compressorNumber,
    required this.tonnage,
    required this.modelNumber,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    TextEditingController commentsController = TextEditingController();
    TextEditingController quantitySpareController = TextEditingController();
    TextEditingController attendingTechnicianController =
        TextEditingController();
    String? spare;
    return Scaffold(
      body: BlocConsumer<MainBloc, MainState>(
        listener: (context, state) {
          if (state is SelectSpareState) {
            spare = state.spare;
          }
          if (state is SubmitAmcReportSuccessfullyState) {
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
                          context.pushAndRemove(const HistoryScreen());
                        },
                        child: Text(
                          "Okay",
                          style: TextStyle(color: ColorManager.secondary),
                        )),
                  ],
                );
              },
            );
          } else if (state is SubmitAmcReportLoadingState) {
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
          return Column(
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
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Column(
                          children: [
                            // Text(
                            //   "Spares and Consumables",
                            //   style: TextStyle(
                            //       color: ColorManager.primary,
                            //       fontSize: 12.sp,
                            //       fontWeight: FontWeight.w600),
                            // ),
                            // SizedBox(
                            //   height: 2.h,
                            // ),
                            Container(
                                decoration: BoxDecoration(
                                    color: ColorManager.primary,
                                    borderRadius:
                                        BorderRadiusDirectional.circular(
                                            10.sp)),
                                child: TextButton(
                                    onPressed: () {
                                      if (spare != null &&
                                          quantitySpareController.text != "") {
                                        bloc.add(
                                          AddSparesBuilderToListEvent(
                                            SpareCModel(
                                              quantity: int.parse(
                                                quantitySpareController.text,
                                              ),
                                              spareName: spare!,
                                            ),
                                          ),
                                        );
                                      } else {
                                        warnToast(
                                            msg:
                                                "You must select Spares and Consumables before add more ");
                                      }
                                    },
                                    child: Text(
                                      "Add More",
                                      style:
                                          TextStyle(color: ColorManager.white),
                                    ))),
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
                                    value: spare,
                                    onChanged: (String? value) {
                                      bloc.add(SelectSpareEvent(spare: value!));
                                    },
                                    items: bloc.spares
                                        .map((e) => e.spareName)
                                        .toList(),
                                    text: "Spares and Consumables",
                                  ),
                                ),
                                SizedBox(
                                  width: 2.w,
                                ),
                                SizedBox(
                                  width: 28.w,
                                  child: defaultFormField(
                                      controller: quantitySpareController,
                                      type: TextInputType.number,
                                      hint: "QTY"),
                                )
                              ],
                            ),
                            ListView.separated(
                                padding: EdgeInsetsDirectional.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) => Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            bloc.sparesC[index].spareName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.sp),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            bloc.sparesC[index].quantity
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.sp),
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              bloc.add(RemoveFromSpareListEvent(
                                                  quantity: bloc
                                                      .sparesC[index].quantity,
                                                  spareName: bloc.sparesC[index]
                                                      .spareName));
                                            },
                                            icon: const Icon(
                                              Icons.clear,
                                            )),
                                      ],
                                    ),
                                separatorBuilder: (context, index) => SizedBox(
                                      height: 1.h,
                                    ),
                                itemCount: bloc.sparesC.length),

                            SizedBox(
                              height: 5.h,
                            ),
                            defaultFormField(
                                controller: commentsController,
                                hint: "Comments"),
                            SizedBox(
                              height: 2.h,
                            ),
                            defaultFormField(
                                controller: attendingTechnicianController,
                                hint: "Attending Technician"),
                            SizedBox(
                              height: 2.h,
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
                                      child: Image.file(
                                          File(bloc.tenantSignature!.path)),
                                    ),
                                  )
                                : const SizedBox(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 7.sp),
                              child: SizedBox(
                                width: 60.w,
                                child: signatureButtonBuilder(
                                    bloc: bloc,
                                    context: context,
                                    type: "signture"),
                              ),
                            ),
                            bloc.signaturePhoto != null
                                ? Card(
                                    child: SizedBox(
                                      height: 100.sp,
                                      width: 100.sp,
                                      child: Image.file(
                                          File(bloc.signaturePhoto!.path)),
                                    ),
                                  )
                                : const SizedBox(),
                            SizedBox(
                              height: 4.h,
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
                  onPressed: () async {
                    if (bloc.signaturePhoto != null &&
                        bloc.tenantSignature != null) {
                      AmcFormModel amcFormModel = AmcFormModel(
                          list: list,
                          acSerialNumber: acSerialNumber,
                          workStatus: workStatus,
                          signature: '',
                          propertySite: jobCard.buildingNumber,
                          comments: commentsController.text,
                          acType: acType,
                          brand: brand,
                          flatNumber: jobCard.flatNumber,
                          compressorNumber: compressorNumber,
                          tonnage: tonnage,
                          writeDate: dateTime.toString(),
                          modelNumber: modelNumber,
                          completeDate: DateTime.now().toString(),
                          attendingTechnician:
                              attendingTechnicianController.text,
                          tenantRepresentative: bloc.tenantEncoded!,
                          location: location);
                      bloc.add(SubmitAmcReportEvent(
                        spareCModel: SpareCModel(
                          quantity: int.parse(
                            quantitySpareController.text,
                          ),
                          spareName: spare!,
                        ),
                        jobCard: jobCard,
                        amcFormModel: amcFormModel,
                        context: context,
                        id: id,
                      ));
                    } else {
                      warnToast(msg: "You must sign");
                    }
                  },
                  text: "Submit",
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
      ),
    );
  }
}
