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

// removed unused petty cash imports; using hr_expense_screen.dart above

class JobCardScreen extends StatefulWidget {
  const JobCardScreen({super.key});

  @override
  State<JobCardScreen> createState() => _JobCardScreenState();
}

class _JobCardScreenState extends State<JobCardScreen> {
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        color: ColorManager.white,
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8.sp),
          decoration: BoxDecoration(
            color: isDestructive
                ? ColorManager.error.withOpacity(0.1)
                : ColorManager.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: isDestructive ? ColorManager.error : ColorManager.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDestructive ? ColorManager.error : ColorManager.primary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16.sp,
          color: ColorManager.grey2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.sp),
        ),
      ),
    );
  }

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
              width: 50.w,
              child: Drawer(
                surfaceTintColor: ColorManager.primary,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorManager.primary.withOpacity(0.1),
                        ColorManager.white,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0.sp),
                    child: Column(
                      children: [
                        SizedBox(height: 6.h),
                        // Header with user info
                        Container(
                          padding: EdgeInsets.all(12.sp),
                          decoration: BoxDecoration(
                            color: ColorManager.white,
                            borderRadius: BorderRadius.circular(12.sp),
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager.primary.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    ColorManager.primary.withOpacity(0.1),
                                radius: 25.sp,
                                child: ConstanceManager.image != null
                                    ? Image.memory(stringToByteList(
                                        ConstanceManager.image!))
                                    : Icon(
                                        Icons.person,
                                        size: 25.sp,
                                        color: ColorManager.primary,
                                      ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                ConstanceManager.name ?? "User",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: ColorManager.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                ConstanceManager.workPhone ?? "",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: ColorManager.grey2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 3.h),
                        // Menu items
                        _buildDrawerItem(
                          icon: Icons.history_rounded,
                          title: 'History',
                          onTap: () => context.push(const HistoryScreen()),
                        ),
                        SizedBox(height: 1.5.h),
                        _buildDrawerItem(
                          icon: Icons.receipt_long_rounded,
                          title: 'Petty Cash',
                          onTap: () => context.push(const ExpenseFormScreen()),
                        ),
                        SizedBox(height: 1.5.h),
                        _buildDrawerItem(
                          icon: Icons.work_rounded,
                          title: 'Job Card',
                          onTap: () => context.push(const JobCardFormScreen()),
                        ),
                        SizedBox(height: 1.5.h),
                        _buildDrawerItem(
                          icon: Icons.logout_rounded,
                          title: 'Sign out',
                          onTap: () {
                            CacheHelper.removeData(key: "sessionId");
                            context.pushAndRemove(const SplashScreen());
                          },
                          isDestructive: true,
                        ),
                        const Spacer(),
                        // Footer
                        Container(
                          padding: EdgeInsets.all(12.sp),
                          decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8.sp),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              await launchUrl(Uri.parse(ConstanceManager.amwal),
                                  mode: LaunchMode.externalApplication);
                            },
                            child: Text(
                              "All rights reserved to Amwal FMSA",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 10.sp,
                                color: ColorManager.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
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
                  // Enhanced Header Section
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
                                height: 32.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      ColorManager.primary.withOpacity(0.1),
                                      ColorManager.white,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(50.sp),
                                    bottomRight: Radius.circular(50.sp),
                                  ),
                                  border: Border.all(
                                    color:
                                        ColorManager.primary.withOpacity(0.3),
                                    width: 1.5.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          ColorManager.primary.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.only(top: 6.h),
                                child: Image.asset(
                                  "assets/images/logo.png",
                                  height: 16.h,
                                  width: 42.w,
                                ),
                              ),
                            ],
                          ),
                          Builder(builder: (context) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 7.h),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ColorManager.white,
                                  borderRadius: BorderRadius.circular(12.sp),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          ColorManager.primary.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    scaffoldKey.currentState!.openDrawer();
                                  },
                                  icon: Icon(
                                    Icons.menu_rounded,
                                    size: 24.sp,
                                    color: ColorManager.primary,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      // Enhanced User Card
                      Card(
                        elevation: 8,
                        shadowColor: ColorManager.primary.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.sp),
                        ),
                        child: Container(
                          width: 92.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ColorManager.white,
                                ColorManager.primary.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24.sp),
                            border: Border.all(
                              color: ColorManager.primary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.sp),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.sp),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ColorManager.primary
                                            .withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: ColorManager.white,
                                    radius: 32.sp,
                                    child: ConstanceManager.image != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(32.sp),
                                            child: Image.memory(
                                              stringToByteList(
                                                  ConstanceManager.image!),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person_rounded,
                                            size: 32.sp,
                                            color: ColorManager.primary,
                                          ),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Good ${currentHour >= 0 && currentHour < 12 ? "Morning" : "Evening"}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18.sp,
                                          color: ColorManager.primary,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        ConstanceManager.name ?? "User",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16.sp,
                                          color: ColorManager.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (ConstanceManager.workPhone != null &&
                                          ConstanceManager
                                              .workPhone!.isNotEmpty)
                                        Text(
                                          ConstanceManager.workPhone!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14.sp,
                                            color: ColorManager.grey2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Enhanced Loading State
                  state is GetJobCardLoadingState
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.sp),
                          padding: EdgeInsets.all(24.sp),
                          decoration: BoxDecoration(
                            color: ColorManager.white,
                            borderRadius: BorderRadius.circular(16.sp),
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager.primary.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    ColorManager.primary),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Loading job cards...',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: ColorManager.grey2,
                                ),
                              ),
                            ],
                          ),
                        )
                      : bloc.jobCards.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Header
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.sp),
                                        decoration: BoxDecoration(
                                          color: ColorManager.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        child: Icon(
                                          Icons.work_rounded,
                                          color: ColorManager.primary,
                                          size: 20.sp,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "Job Cards",
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.w700,
                                          color: ColorManager.primary,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (jobCardsUnCompleted.length > 2)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.sp,
                                            vertical: 6.sp,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ColorManager.secondary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12.sp),
                                          ),
                                          child: Text(
                                            "${jobCardsUnCompleted.length}",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: ColorManager.secondary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),

                                  // Job Cards Grid
                                  Wrap(
                                    spacing: 12.sp,
                                    runSpacing: 12.sp,
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

                                  // See All Button
                                  if (jobCardsUnCompleted.length > 2)
                                    Padding(
                                      padding: EdgeInsets.only(top: 2.h),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                ColorManager.secondary,
                                                ColorManager.primary,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20.sp),
                                            boxShadow: [
                                              BoxShadow(
                                                color: ColorManager.secondary
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              context.push(AllJobCardScreen(
                                                jobCards: jobCardsUnCompleted,
                                              ));
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.sp,
                                                vertical: 10.sp,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "See All",
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: ColorManager.white,
                                                  ),
                                                ),
                                                SizedBox(width: 1.w),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  color: ColorManager.white,
                                                  size: 16.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Divider for AMC Cards
                                  if (bloc.amcCards.isNotEmpty) ...[
                                    SizedBox(height: 3.h),
                                    Container(
                                      height: 1,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            ColorManager.primary
                                                .withOpacity(0.3),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                  ],
                                ],
                              ),
                            )
                          : const SizedBox(),
                  // Enhanced AMC Cards Section
                  state is GetAmcCardLoadingState
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.sp),
                          padding: EdgeInsets.all(24.sp),
                          decoration: BoxDecoration(
                            color: ColorManager.white,
                            borderRadius: BorderRadius.circular(16.sp),
                            boxShadow: [
                              BoxShadow(
                                color: ColorManager.primary.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    ColorManager.primary),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Loading AMC cards...',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: ColorManager.grey2,
                                ),
                              ),
                            ],
                          ),
                        )
                      : bloc.amcCards.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.symmetric(horizontal: 16.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // AMC Section Header
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8.sp),
                                        decoration: BoxDecoration(
                                          color: ColorManager.secondary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                        ),
                                        child: Icon(
                                          Icons.assignment_rounded,
                                          color: ColorManager.secondary,
                                          size: 20.sp,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        "AMC Cards",
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.w700,
                                          color: ColorManager.secondary,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (amcCardsWidgets.length > 2)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.sp,
                                            vertical: 6.sp,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ColorManager.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12.sp),
                                          ),
                                          child: Text(
                                            "${amcCardsWidgets.length}",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: ColorManager.primary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),

                                  // AMC Cards Grid
                                  Wrap(
                                    spacing: 12.sp,
                                    runSpacing: 12.sp,
                                    children: amcCardsWidgets.reversed
                                        .toList()
                                        .take(2)
                                        .toList(),
                                  ),

                                  // See All Button for AMC
                                  if (amcCardsWidgets.length > 2)
                                    Padding(
                                      padding: EdgeInsets.only(top: 2.h),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                ColorManager.primary,
                                                ColorManager.secondary,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20.sp),
                                            boxShadow: [
                                              BoxShadow(
                                                color: ColorManager.primary
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              context.push(AllAmcCardScreen(
                                                  amcCardsWidgets:
                                                      amcCardsWidgets));
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.sp,
                                                vertical: 10.sp,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "See All",
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: ColorManager.white,
                                                  ),
                                                ),
                                                SizedBox(width: 1.w),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  color: ColorManager.white,
                                                  size: 16.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                  // Enhanced Bottom Spacing
                  SizedBox(height: 4.h),

                  // Subtle Footer
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.sp),
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12.sp),
                      border: Border.all(
                        color: ColorManager.primary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16.sp,
                          color: ColorManager.primary.withOpacity(0.7),
                        ),
                        SizedBox(width: 2.w),
                        Flexible(
                          child: Text(
                            "Pull down to refresh your data",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: ColorManager.primary.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: MediaQuery.of(context).size.height *
                        (bloc.amcCards.isNotEmpty &&
                                jobCardsUnCompleted.isNotEmpty
                            ? 0.05
                            : bloc.amcCards.isEmpty &&
                                    jobCardsUnCompleted.isEmpty
                                ? 0.2
                                : 0.1),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
