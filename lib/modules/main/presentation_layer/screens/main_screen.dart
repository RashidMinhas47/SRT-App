import 'dart:io';

import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/authentication/presentation_layer/screens/splash_screen.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/presentation_layer/components/components.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/history_screen.dart';
import 'package:bayanat/modules/petty_cash/presentation_layer/screens/hr_expense_screen.dart';
import 'package:bayanat/modules/job_card/presentation_layer/screens/job_card_form_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/local/shared_prefrences.dart';
import '../../../../core/services/dep_injection.dart';
import '../../../../core/utils/color_manager.dart';
import '../bloc/main_bloc.dart';
import 'all_amc_card_screen.dart';
import 'all_job_card_screen.dart';

import '../../../petty_cash/presentation_layer/screens/petty_cash_form_screen.dart';

class JobCardScreen extends StatefulWidget {
  const JobCardScreen({super.key});

  @override
  State<JobCardScreen> createState() => _JobCardScreenState();
}

class _JobCardScreenState extends State<JobCardScreen> {
  Future<bool> requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      int sdkInt = int.tryParse(RegExp(r'\d+')
                  .firstMatch(Platform.operatingSystemVersion)
                  ?.group(0) ??
              '0') ??
          0;

      if (sdkInt >= 33) {
        // Android 13+ → use mediaImages for photos/images
        return await Permission.photos.request().isGranted;
      } else {
        // Android 12 and below
        return await Permission.storage.request().isGranted;
      }
    } else {
      return await Permission.photos.request().isGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestStoragePermission(context);
    });

    MainBloc bloc = sl();
    DateTime now = DateTime.now();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    int currentHour = now.hour;
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        bloc.add(GetJobCardEvent(context: context));
        bloc.add(const GetProductsEvent());
        bloc.add(GetAmcCardsEvent(
          context: context,
        ));
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: BlocConsumer<MainBloc, MainState>(
          listener: (context, state) {
            if (state is GetJobCardErrorState) {
              context.pushAndRemove(const SplashScreen());
            }
          },
          builder: (context, state) {
            return SizedBox(
              width: 44.w,
              child: Drawer(
                surfaceTintColor: ColorManager.primary,
                child: Padding(
                  padding: EdgeInsets.all(8.0.sp),
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: () {
                          context.push(const HistoryScreen());
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 30.sp,
                            ),
                            Text(
                              'History',
                              style: TextStyle(
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      //TODO: Next job will be done here
                      // InkWell(
                      //   onTap: () {
                      //     context.push(const PettyCashFormScreen());
                      //   },
                      //   child: Column(
                      //     children: [
                      //       Icon(
                      //         Icons.receipt_long,
                      //         size: 30.sp,
                      //       ),
                      //       Text(
                      //         'Petty Cash',
                      //         style: TextStyle(
                      //           fontSize: 14.sp,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      SizedBox(height: 2.h),
                      InkWell(
                        onTap: () {
                          context.push(const JobCardFormScreen());
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.work,
                              size: 30.sp,
                            ),
                            Text(
                              'Job Card',
                              style: TextStyle(
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      InkWell(
                        onTap: () {
                          CacheHelper.removeData(key: "sessionId");
                          context.pushAndRemove(const SplashScreen());
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.logout,
                              size: 30.sp,
                            ),
                            Text(
                              'Sign out',
                              style: TextStyle(
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                          onPressed: () async {
                            await launchUrl(Uri.parse(ConstanceManager.amwal),
                                mode: LaunchMode.externalApplication);
                          },
                          child: Text(
                            "All rights reserved to Amwal FMSA",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                color: ColorManager.primary),
                          )),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        body: BlocBuilder<MainBloc, MainState>(
          builder: (context, state) {
            List<JobCard> jobCardsUnCompleted =
                jobCards(jobCards: bloc.jobCards);

            List<Widget> amcCardsWidgets = amcCardWidgets(
                bloc: bloc, context: context, amcCards: bloc.amcCards);
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment(0.w, 0.15.h),
                    children: [
                      Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                  height: 30.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: ColorManager.white,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(60.sp),
                                          bottomRight: Radius.circular(60.sp)),
                                      border: Border.all(
                                          color: ColorManager.primary,
                                          width: 2.w))),
                              Padding(
                                padding: EdgeInsetsDirectional.only(top: 5.h),
                                child: Image.asset(
                                  "assets/images/logo.png",
                                  height: 15.h,
                                  width: 40.w,
                                ),
                              ),
                            ],
                          ),
                          Builder(builder: (context) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 6.h),
                              child: IconButton(
                                  onPressed: () {
                                    scaffoldKey.currentState!.openDrawer();
                                  },
                                  icon: Icon(
                                    Icons.menu,
                                    size: 25.sp,
                                    color: ColorManager.primary,
                                  )),
                            );
                          }),
                        ],
                      ),
                      Card(
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.sp),
                            borderSide: BorderSide.none),
                        child: Container(
                          width: 90.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: ColorManager.white,
                            borderRadius: BorderRadius.circular(20.sp),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Card(
                                shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.sp),
                                    borderSide: BorderSide.none),
                                child: CircleAvatar(
                                  backgroundColor: ColorManager.white,
                                  radius: 28.sp,
                                  child: ConstanceManager.image != null
                                      ? Image.memory(stringToByteList(
                                          ConstanceManager.image!))
                                      : Image.asset(
                                          "assets/images/default_image.jpg"),
                                ),
                              ),
                              SizedBox(
                                width: 2.w,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.sp),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Good ${currentHour >= 0 && currentHour < 12 ? " Morning" : "Evening"}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 2.3.h),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          ConstanceManager.name ?? "",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 1.8.h),
                                        ),
                                        Text(
                                          ConstanceManager.workPhone ?? "",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 1.8.h),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  state is GetJobCardLoadingState
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Column(
                            children: [
                              const Center(child: CircularProgressIndicator()),
                              SizedBox(height: 2.h),
                              Text(
                                'Loading job cards...',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : bloc.jobCards.isNotEmpty
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 2.h,
                                ),
                                Text(
                                  "Job Card",
                                  style: TextStyle(
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.sp),
                                  child: Wrap(
                                    direction: Axis.horizontal,
                                    children: jobCardsUnCompleted
                                        .take(2)
                                        .map((jobCard) {
                                      return jobCardWidget(
                                        context: context,
                                        bloc: bloc,
                                        jobCard: jobCard,
                                      );
                                    }).toList(),
                                  ),
                                  // child: Wrap(
                                  //   direction: Axis.horizontal,
                                  //   children: jobCardsUnCompleted
                                  //       .map((jobCard) {
                                  //         return jobCardWidget(
                                  //           context: context,
                                  //           bloc: bloc,
                                  //           jobCard: jobCard,
                                  //         );
                                  //       })
                                  //       .toList()
                                  //       .reversed
                                  //       .take(2)
                                  //       .toList(),
                                  // ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.sp),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: TextButton(
                                      onPressed: () {
                                        context.push(AllJobCardScreen(
                                          jobCards: jobCardsUnCompleted,
                                        ));
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("See All",
                                              style: TextStyle(
                                                  fontSize: 15.sp,
                                                  color:
                                                      ColorManager.secondary)),
                                          Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            color: ColorManager.secondary,
                                            size: 18.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                bloc.amcCards.isNotEmpty
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.sp),
                                        child: Column(
                                          children: [
                                            Container(
                                              color: ColorManager.primary,
                                              width: double.infinity,
                                              height: 0.2.h,
                                            ),
                                            SizedBox(
                                              height: 2.h,
                                            )
                                          ],
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            )
                          : const SizedBox(),
                  state is GetAmcCardLoadingState
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child:
                              const Center(child: CircularProgressIndicator()),
                        )
                      : bloc.amcCards.isNotEmpty
                          ? Column(
                              children: [
                                Text(
                                  "Amc Card",
                                  style: TextStyle(
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: 2.h,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.sp),
                                  child: Wrap(
                                      direction: Axis.horizontal,
                                      children: amcCardsWidgets.reversed
                                          .toList()
                                          .take(2)
                                          .toList()),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.sp),
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: TextButton(
                                      onPressed: () {
                                        context.push(AllAmcCardScreen(
                                            amcCardsWidgets: amcCardsWidgets));
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("See All",
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color:
                                                      ColorManager.secondary)),
                                          Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            color: ColorManager.secondary,
                                            size: 18.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          (bloc.amcCards.isNotEmpty &&
                                  jobCardsUnCompleted.isNotEmpty
                              ? 0.1
                              : bloc.amcCards.isEmpty &&
                                      jobCardsUnCompleted.isEmpty
                                  ? 0.75
                                  : 0.45)),
                  //TODO: Expenses Navigation Button is here
                  // IconButton(
                  //   onPressed: () => Navigator.push(context,
                  //       MaterialPageRoute(builder: (_) => ExpenseFormScreen())),
                  //   icon: Icon(Icons.add),
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
