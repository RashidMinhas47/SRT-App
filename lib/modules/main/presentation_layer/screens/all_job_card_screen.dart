import 'package:bayanat/core/services/dep_injection.dart';
import 'package:bayanat/modules/authentication/presentation_layer/components/components.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/utils/color_manager.dart';
import '../bloc/main_bloc.dart';
import '../components/components.dart';

class AllJobCardScreen extends StatefulWidget {
  final List<JobCard> jobCards;
  final List<JobCard> filteredJobCards = [];

  AllJobCardScreen({super.key, required this.jobCards});

  @override
  State<AllJobCardScreen> createState() => _AllJobCardScreenState();
}

class _AllJobCardScreenState extends State<AllJobCardScreen> {
  // StartImprove Lagging/Performance Issues
  int itemsPerPage = 20;
  int currentItemCount = 20;
  List<JobCard> displayedJobCards = [];
  List<JobCard> allJobCards = [];
  List<JobCard> filteredJobCards = [];
  @override
  void initState() {
    super.initState();
    allJobCards = widget.jobCards.toList();
    filteredJobCards = [];
    displayedJobCards = allJobCards.take(currentItemCount).toList();
  }

  void _filterJobCards(String query) {
    setState(() {
      
      currentItemCount = itemsPerPage;
      filteredJobCards = allJobCards.where((jobCard) {

        return jobCard.id.toString().contains(query) ||
        jobCard.jobCardNumber.toLowerCase().contains(query) ||
            jobCard.location.toLowerCase().contains(query.toLowerCase()) ||
            jobCard.flatNumber.toString().contains(query);
      }).toList();
      displayedJobCards = filteredJobCards.take(currentItemCount).toList();
    });
  }

//Ends Improve Lagging/Performance Issues

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    return Scaffold(
     
      body: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  top: 10.h, end: 2.w, bottom: 5.h, start: 2.w),
              child: Column(
                children: [
                  TextField(
                    onChanged: (char) {
                      _filterJobCards(char);
                      // setState(() {
                      //   widget.filteredJobCards =
                      //       widget.jobCards.where((jobCard) {
                      //     return jobCard.id.toString().contains(char) ||
                      //         jobCard.location
                      //             .toLowerCase()
                      //             .contains(char.toLowerCase()) ||
                      //         jobCard.flatNumber.toString().contains(char);
                      //   }).toList();
                      //   currentItemCount = itemsPerPage;
                      //   final allJobCards =
                      //       widget.filteredJobCards.reversed.toList();
                      //   displayedJobCards =
                      //       allJobCards.take(currentItemCount).toList();
                      // });
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
                  Center(
                    child: Text(
                      "Job Card",
                      style: TextStyle(
                          fontSize: 25.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.sp),
                    child: Column(
                      children: [
                        Wrap( 
                          direction: Axis.horizontal,
                          children: displayedJobCards.map((jobCard) {
                            return jobCardWidget(
                              context: context,
                              bloc: bloc,
                              jobCard: jobCard,
                            );
                          }).toList(),
                        ),
                        if ((filteredJobCards.isNotEmpty
                                ? filteredJobCards.length
                                : allJobCards.length) >
                            currentItemCount)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                currentItemCount += itemsPerPage;
                                if (filteredJobCards.isNotEmpty) {
                                  displayedJobCards = filteredJobCards
                                      .take(currentItemCount)
                                      .toList();
                                } else {
                                  displayedJobCards = allJobCards
                                      .take(currentItemCount)
                                      .toList();
                                }
                              });
                            },
                            child: const Text('Load More'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

// child: Column(
//                 children: [
//                   TextField(
//                     onChanged: (char) {
//                       setState(() {
//                         widget.filteredJobCards = widget.jobCards.where((jobCard) {
//                           return jobCard.id.toString().contains(char) ||
//                               jobCard.location.toLowerCase().contains(char.toLowerCase()) ||
//                               jobCard.flatNumber.toString().contains(char);
//                         }).toList();
//                         print(widget.filteredJobCards);
//                       });
//                     },
//                     decoration: InputDecoration(
//                       prefixIcon: const Icon(Icons.search),
//                       hintText: 'Search...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12.0),
//                         borderSide: BorderSide.none,
//                       ),
//                       hintStyle: TextStyle(
//                         color: ColorManager.primary,
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                       contentPadding: EdgeInsets.symmetric(vertical: 5.w),
//                     ),
//                   ),
//                   SizedBox(height: 1.h),
//                   Center(
//                     child: Text(
//                       "Job Card",
//                       style: TextStyle(
//                           fontSize: 25.sp, fontWeight: FontWeight.w700),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20.sp),
//                     child: Wrap(
//                       direction: Axis.horizontal,
//                       children: (widget.filteredJobCards.isNotEmpty
//                               ? widget.filteredJobCards
//                               : widget.jobCards)
//                           .map((jobCard) {
//                             return jobCardWidget(
//                               context: context,
//                               bloc: bloc,
//                               jobCard: jobCard,
//                             );
//                           })
//                           .toList()
//                           .reversed
//                           .toList(), // تطبيق reversed و take(2)
//                     ),
//                   ),
//                 ],
//               ),
            ),
          );
        },
      ),
    );
  }
}
