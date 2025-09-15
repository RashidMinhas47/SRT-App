import 'package:bayanat/core/services/dep_injection.dart';
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(32.sp),
        padding: EdgeInsets.all(24.sp),
        decoration: BoxDecoration(
          color: ColorManager.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.sp),
          border: Border.all(
            color: ColorManager.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.sp,
              color: ColorManager.primary.withOpacity(0.6),
            ),
            SizedBox(height: 2.h),
            Text(
              "No Job Cards Found",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorManager.primary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              filteredJobCards.isNotEmpty
                  ? "Try adjusting your search criteria"
                  : "No job cards available at the moment",
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorManager.grey2,
              ),
              textAlign: TextAlign.center,
            ),
            if (filteredJobCards.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Container(
                decoration: BoxDecoration(
                  color: ColorManager.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      filteredJobCards.clear();
                      displayedJobCards =
                          allJobCards.take(currentItemCount).toList();
                    });
                  },
                  child: Text(
                    "Clear Search",
                    style: TextStyle(
                      color: ColorManager.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MainBloc bloc = sl();
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        backgroundColor: ColorManager.primary,
        elevation: 0,
        title: Text(
          "Job Cards",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: ColorManager.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: ColorManager.white,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          return Column(
            children: [
              // Enhanced Search Section
              Container(
                margin: EdgeInsets.all(16.sp),
                padding: EdgeInsets.all(16.sp),
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
                    // Search Field
                    TextField(
                      onChanged: (char) {
                        _filterJobCards(char);
                      },
                      decoration: InputDecoration(
                        prefixIcon: Container(
                          padding: EdgeInsets.all(8.sp),
                          child: Icon(
                            Icons.search_rounded,
                            color: ColorManager.primary,
                            size: 20.sp,
                          ),
                        ),
                        hintText:
                            'Search by job card number, location, or flat...',
                        hintStyle: TextStyle(
                          color: ColorManager.grey2,
                          fontSize: 14.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.sp),
                          borderSide: BorderSide(
                            color: ColorManager.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.sp),
                          borderSide: BorderSide(
                            color: ColorManager.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.sp),
                          borderSide: BorderSide(
                            color: ColorManager.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: ColorManager.primary.withOpacity(0.05),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.sp,
                          vertical: 12.sp,
                        ),
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Results Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Results: ${filteredJobCards.isNotEmpty ? filteredJobCards.length : allJobCards.length}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: ColorManager.grey2,
                          ),
                        ),
                        if (filteredJobCards.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.sp,
                              vertical: 4.sp,
                            ),
                            decoration: BoxDecoration(
                              color: ColorManager.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                            child: Text(
                              "Filtered",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.secondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Job Cards Grid
              Expanded(
                child: displayedJobCards.isEmpty
                    ? _buildEmptyState()
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.sp),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.sp,
                            mainAxisSpacing: 12.sp,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: displayedJobCards.length,
                          itemBuilder: (context, index) {
                            return jobCardWidget(
                              context: context,
                              bloc: bloc,
                              jobCard: displayedJobCards[index],
                            );
                          },
                        ),
                      ),
              ),

              // Load More Button
              if ((filteredJobCards.isNotEmpty
                      ? filteredJobCards.length
                      : allJobCards.length) >
                  currentItemCount)
                Container(
                  margin: EdgeInsets.all(16.sp),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorManager.primary,
                          ColorManager.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.sp),
                      boxShadow: [
                        BoxShadow(
                          color: ColorManager.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentItemCount += itemsPerPage;
                          if (filteredJobCards.isNotEmpty) {
                            displayedJobCards = filteredJobCards
                                .take(currentItemCount)
                                .toList();
                          } else {
                            displayedJobCards =
                                allJobCards.take(currentItemCount).toList();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.sp),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.expand_more_rounded,
                            color: ColorManager.white,
                            size: 18.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Load More',
                            style: TextStyle(
                              color: ColorManager.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
