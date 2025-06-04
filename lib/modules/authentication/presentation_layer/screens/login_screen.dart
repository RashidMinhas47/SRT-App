import 'package:bayanat/modules/authentication/presentation_layer/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/services/dep_injection.dart';
import '../../../../core/utils/color_manager.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController userNameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    var formKey = GlobalKey<FormState>();
    AuthBloc bloc = sl();
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          current is LoginLoadingAuthState ||
          current is LoginSuccessfulAuthState,
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.sp),
                    child: Column(
                      children: [
                        defaultFormField(
                          hint: "Username",
                          controller: userNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'You must write a Username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 20.sp,
                        ),
                        defaultFormField(
                          hint: "Password",
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'You must write a Password';
                            }
                            return null;
                          },
                          controller: passwordController,
                        ),
                        SizedBox(
                          height: 20.sp,
                        ),
                        state is! LoginLoadingAuthState
                            ? defaultButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    bloc.add(LoginEvent(
                                        context: context,
                                        password: passwordController.text,
                                        userName: userNameController.text));
                                  }
                                },
                                buttonColor: ColorManager.primary,
                                text: "Log in",
                                textColor: ColorManager.white,
                                fontSize: 20.sp,
                                height: 8.h,
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
