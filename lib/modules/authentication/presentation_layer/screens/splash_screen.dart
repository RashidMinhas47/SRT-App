import 'package:bayanat/core/utils/color_manager.dart';
import 'package:bayanat/core/utils/navigation_manager.dart';
import 'package:bayanat/modules/authentication/presentation_layer/components/components.dart';
import 'package:bayanat/modules/main/domain_layer/entities/job_card.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/fault/fault_2.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment(0.sp, -0.3.h),
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: ColorManager.primary,
                    height: 65.h,
                    width: double.infinity,
                  ),
                  Image.asset(
                    "assets/images/Subtraction.png",
                    height: 65.h,
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.sp),
                    child: defaultButton(
                      onPressed: () {
                        context.push(const LoginScreen());
                      },
                      buttonColor: ColorManager.white,
                      text: "Log in",
                      textColor: ColorManager.primary,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/images/Rectangle.png",
                    width: 70.w,
                    height: 45.h,
                    color: ColorManager.white,
                  ),
                  Image.asset(
                    "assets/images/logo.png",
                    width: 85.w,
                    height: 45.h,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
