import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../bloc/main_bloc.dart';

class AllAmcCardScreen extends StatelessWidget {
  final List<Widget> amcCardsWidgets;
  const AllAmcCardScreen({super.key, required this.amcCardsWidgets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  top: 10.h, end: 2.w, bottom: 5.h, start: 2.w),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "Amc Card",
                      style:
                          TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.sp),
                    child: Wrap(
                        direction: Axis.horizontal,
                        children: amcCardsWidgets.reversed.toList()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
