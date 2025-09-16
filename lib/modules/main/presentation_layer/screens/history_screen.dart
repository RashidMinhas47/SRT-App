import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/services/dep_injection.dart';
import '../../../../core/utils/color_manager.dart';
import '../bloc/main_bloc.dart';
import '../components/components.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
// Converted widget from StatelessWidget to StatefulWidget to manage dynamic state changes.
// This was necessary to implement the "Load More" functionality, which updates the UI
// based on user interaction and additional data loading.
  final MainBloc bloc = sl();
  int _visibleRowCount = 20;

//=============================================

  List<JobCard> displayedHistoryJobCards = [];
  List<JobCard> allJobCards = [];
  List<JobCard> filteredJobCards = [];
  @override
  void initState() {
    super.initState();
    allJobCards = bloc.jobCards.toList();
    displayedHistoryJobCards = allJobCards.take(_visibleRowCount).toList();
  }

  void _filterJobCards(String query) {
    setState(() {
      _visibleRowCount = 20;
      if (query.isEmpty) {
        filteredJobCards = [];
      } else {
        filteredJobCards = allJobCards.where((jobCard) {
          return jobCard.id.toString().contains(query) ||
              jobCard.jobCardNumber
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              jobCard.location.toLowerCase().contains(query.toLowerCase()) ||
              jobCard.flatNumber.toString().contains(query);
        }).toList();
      }
      displayedHistoryJobCards =
          filteredJobCards.isNotEmpty ? filteredJobCards : allJobCards;
    });
  }

  Widget _enhancedColumnText({required String text}) {
    return Padding(
      padding: EdgeInsets.all(12.sp),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: ColorManager.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

//=============================================

  @override
  Widget build(BuildContext context) {
    // MainBloc bloc = sl();
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        final dataSource =
            filteredJobCards.isNotEmpty ? filteredJobCards : allJobCards;
        final rows =
            getHistoryRows(context: context, history: dataSource).toList();
        final visibleRows = rows.take(_visibleRowCount).toList();

        // final allRows =
        //     getHistoryRows(context: context, history: bloc.jobCards).toList();

        // final visibleRows = allRows.take(_visibleRowCount).toList();

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            context.pushAndRemove(const JobCardScreen());
          },
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Enhanced Header Section
                  Container(
                    height: 35.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ColorManager.primary,
                          ColorManager.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.sp),
                        bottomRight: Radius.circular(30.sp),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 2.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back Button and Title Row
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: ColorManager.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12.sp),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      context
                                          .pushAndRemove(const JobCardScreen());
                                    },
                                    icon: Icon(
                                      Icons.arrow_back_ios_rounded,
                                      size: 20.sp,
                                      color: ColorManager.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    "Job History",
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w700,
                                      color: ColorManager.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.sp, vertical: 6.sp),
                                  decoration: BoxDecoration(
                                    color: ColorManager.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20.sp),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.history_rounded,
                                        size: 16.sp,
                                        color: ColorManager.white,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        "${allJobCards.length}",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: ColorManager.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            // Subtitle
                            Text(
                              "View and search through all job cards",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: ColorManager.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.sp),
                    child: state is GetJobCardLoadingState
                        ? Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.sp),
                            padding: EdgeInsets.all(32.sp),
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
                                  'Loading job history...',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: ColorManager.grey2,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : bloc.jobCards.isNotEmpty && rows.isNotEmpty
                            ? Column(
                                children: [
                                  // Enhanced Search Section
                                  Container(
                                    margin: EdgeInsets.only(bottom: 2.h),
                                    decoration: BoxDecoration(
                                      color: ColorManager.white,
                                      borderRadius:
                                          BorderRadius.circular(16.sp),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColorManager.primary
                                              .withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      onChanged: (char) {
                                        _filterJobCards(char);
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Container(
                                          margin: EdgeInsets.all(12.sp),
                                          decoration: BoxDecoration(
                                            color: ColorManager.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8.sp),
                                          ),
                                          child: Icon(
                                            Icons.search_rounded,
                                            color: ColorManager.primary,
                                            size: 20.sp,
                                          ),
                                        ),
                                        hintText:
                                            'Search by job number, location, or flat number...',
                                        hintStyle: TextStyle(
                                          color: ColorManager.grey2,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.sp),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.sp),
                                          borderSide: BorderSide(
                                            color: ColorManager.primary
                                                .withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.sp),
                                          borderSide: BorderSide(
                                            color: ColorManager.primary,
                                            width: 2,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: ColorManager.white,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.sp,
                                          vertical: 16.sp,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: ColorManager.black,
                                      ),
                                    ),
                                  ),

                                  // Results Counter
                                  if (filteredJobCards.isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.only(bottom: 2.h),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp, vertical: 8.sp),
                                      decoration: BoxDecoration(
                                        color: ColorManager.secondary
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(20.sp),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.filter_list_rounded,
                                            size: 16.sp,
                                            color: ColorManager.secondary,
                                          ),
                                          SizedBox(width: 1.w),
                                          Text(
                                            "Found ${filteredJobCards.length} results",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: ColorManager.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Enhanced Table Container
                                  Container(
                                    decoration: BoxDecoration(
                                      color: ColorManager.white,
                                      borderRadius:
                                          BorderRadius.circular(16.sp),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColorManager.primary
                                              .withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(16.sp),
                                      child: Table(
                                        border: TableBorder.all(
                                          color: ColorManager.primary
                                              .withOpacity(0.2),
                                          width: 1,
                                        ),
                                        children: [
                                          TableRow(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  ColorManager.primary,
                                                  ColorManager.secondary,
                                                ],
                                              ),
                                            ),
                                            children: [
                                              _enhancedColumnText(
                                                  text: "Job Number"),
                                              _enhancedColumnText(
                                                  text: "User Name"),
                                              _enhancedColumnText(
                                                  text: "Customer Name"),
                                              _enhancedColumnText(
                                                  text: "Description"),
                                              _enhancedColumnText(
                                                  text: "Location"),
                                              _enhancedColumnText(
                                                  text: "Download"),
                                            ],
                                          ),
                                          ...visibleRows,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Enhanced Load More Button
                                  if (_visibleRowCount < rows.length)
                                    Padding(
                                      padding: EdgeInsets.only(top: 3.h),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              ColorManager.secondary,
                                              ColorManager.primary,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16.sp),
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorManager.primary
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _visibleRowCount += 20;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.sp),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16.sp),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.expand_more_rounded,
                                                color: ColorManager.white,
                                                size: 20.sp,
                                              ),
                                              SizedBox(width: 2.w),
                                              Text(
                                                "Load More (${rows.length - _visibleRowCount} remaining)",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: ColorManager.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : Container(
                                margin: EdgeInsets.symmetric(horizontal: 20.sp),
                                padding: EdgeInsets.all(32.sp),
                                decoration: BoxDecoration(
                                  color: ColorManager.white,
                                  borderRadius: BorderRadius.circular(16.sp),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          ColorManager.primary.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(20.sp),
                                      decoration: BoxDecoration(
                                        color:
                                            ColorManager.grey2.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(50.sp),
                                      ),
                                      child: Icon(
                                        Icons.history_rounded,
                                        size: 48.sp,
                                        color: ColorManager.grey2,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      "No Job History",
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: ColorManager.black,
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      "Your job history will appear here once you have completed job cards.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        color: ColorManager.grey2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),

                  // Bottom spacing
                  SizedBox(height: 4.h),

// Padding(
//                     padding: EdgeInsets.all(20.sp),
//                     child: state is GetJobCardLoadingState
//                         ? const Center(child: CircularProgressIndicator())
//                         : bloc.jobCards.isNotEmpty &&
//                                 getHistoryRows(
//                                         context: context,
//                                         history: bloc.jobCards)
//                                     .isNotEmpty
//                             ? Table(
//                                 border: TableBorder.all(
//                                     color: ColorManager.primary),
//                                 children: [
//                                   TableRow(
//                                       decoration: BoxDecoration(
//                                         color: ColorManager.secondary,
//                                       ),
//                                       children: [
//                                         columnText(text: "Job Number"),
//                                         columnText(text: "User Name"),
//                                         columnText(text: "Customer Name"),
//                                         columnText(text: "Description"),
//                                         columnText(text: "Location"),
//                                         columnText(text: "Download"),
//                                       ]),
//                                   ...getHistoryRows(
//                                       context: context, history: bloc.jobCards).reversed,
//                                 ],
//                               )
//                             : Text(
//                                 "History is empty",
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 14.sp),
//                               ),
//                   ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
