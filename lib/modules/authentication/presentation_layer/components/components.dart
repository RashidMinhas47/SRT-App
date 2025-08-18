import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/utils/color_manager.dart';

Widget defaultFormField(
        {String? label,
        IconData? prefix,
        String? hint,
        IconButton? suffix,
        bool? enabled = true,
        String? validatorText,
        TextInputType? type,
        void Function()? suffixFunction,
        FormFieldValidator? validator,
        bool obscureText = false,
        required TextEditingController controller}) =>
    TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      controller: controller,
      keyboardType: type,
      enabled: enabled,
      cursorColor: ColorManager.primary,
      obscureText: obscureText,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.sp),
              borderSide: BorderSide(
                color: ColorManager.black.withOpacity(0.6),
              )),
          isDense: true, // Added this
          contentPadding: EdgeInsets.all(15.sp),
          filled: true,
          fillColor: ColorManager.white,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(15.sp)),
          prefixIcon: Icon(
            prefix,
          ),
          suffixIcon: suffix,
          labelText: label,
          helperText: hint,
          labelStyle: TextStyle(
            color: ColorManager.black,
          )),
      validator: validator,
    );

defaultToast({
  required String msg,
}) {
  Fluttertoast.showToast(
    msg: msg,
    backgroundColor: ColorManager.primary,
    textColor: ColorManager.white,
    toastLength: Toast.LENGTH_SHORT,
  );
}

errorToast({
  required String msg,
}) {
  Fluttertoast.showToast(
    msg: msg,
    backgroundColor: ColorManager.error,
    textColor: ColorManager.white,
    toastLength: Toast.LENGTH_SHORT,
  );
}

Widget defaultButton({
  required VoidCallback onPressed,
  required String text,
  double? width = double.infinity,
  double? height,
  Color? textColor,
  Color? buttonColor,
  Color? borderColor,
  double? fontSize,
  FontWeight? fontWeight,
}) =>
    Container(
      decoration: BoxDecoration(
        color: buttonColor ?? ColorManager.primary,
        border: Border.all(
          color: borderColor ?? ColorManager.black.withOpacity(0),
        ),
        borderRadius: BorderRadius.circular(20.sp),
      ),
      width: width,
      height: height ?? 8.h,
      child: MaterialButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize ?? 15.sp,
            fontWeight: fontWeight,
            color: textColor ?? ColorManager.white,
          ),
        ),
      ),
    );

class CustomPositioned extends StatelessWidget {
  const CustomPositioned({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 100.sp,
            width: 100.sp,
            child: child,
          ),
        ],
      ),
    );
  }
}
