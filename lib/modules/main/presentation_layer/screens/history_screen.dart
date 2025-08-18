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
            jobCard.jobCardNumber.toLowerCase().contains(query.toLowerCase()) ||
            jobCard.location.toLowerCase().contains(query.toLowerCase()) ||
            jobCard.flatNumber.toString().contains(query);
      }).toList();
    }
    displayedHistoryJobCards =
        filteredJobCards.isNotEmpty ? filteredJobCards : allJobCards;
  });
}

//=============================================


  @override
  Widget build(BuildContext context) {
    // MainBloc bloc = sl();
    return BlocBuilder<MainBloc, MainState>(
      builder: (context, state) {
        final dataSource = filteredJobCards.isNotEmpty ? filteredJobCards : allJobCards;
final rows = getHistoryRows(context: context, history: dataSource).toList();
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
                  Stack(
                    children: [
                      screenCoverBuilder(30, title: "HISTORY", width: 0.2),
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
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.sp),
                    child: state is GetJobCardLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : bloc.jobCards.isNotEmpty && rows.isNotEmpty
                            ? Column(
                                children: [
                                  TextField(
                    onChanged: (char) {
                      _filterJobCards(char);
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(
                        color: ColorManager.primary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 5.w),
                    ),
                  ),
                   SizedBox(height: 1.h),
                                  Table(
                                    border: TableBorder.all(
                                        color: ColorManager.primary),
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: ColorManager.secondary,
                                        ),
                                        children: [
                                          columnText(text: "Job Number"),
                                          columnText(text: "User Name"),
                                          columnText(text: "Customer Name"),
                                          columnText(text: "Description"),
                                          columnText(text: "Location"),
                                          columnText(text: "Download"),
                                        ],
                                      ),
                                      ...visibleRows,
                                    ],
                                  ),
                                  if (_visibleRowCount < rows.length)
                                    Padding(
                                      padding: EdgeInsets.only(top: 2.h),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _visibleRowCount += 20;
                                          });
                                        },
                                        child: const Text("Load More"),
                                      ),
                                    ),
                                ],
                              )
                            : Text(
                                "History is empty",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                  ),

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
