import 'package:flutter/material.dart';
import 'package:soundtotext/core/Styles/colors.dart';

abstract class AppStyles {
  static TextStyle? textButton(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 16),
      fontWeight: FontWeight.w700,
      color: AppColors.kWhiteColor,
      fontStyle: FontStyle.normal,
      fontFamily: "Tajawal",
      decoration: TextDecoration.none,
    );
  }

  static TextStyle? semiBold25(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 25),
      fontWeight: FontWeight.w700,
      color: AppColors.kWhiteColor,
      fontStyle: FontStyle.normal,
      fontFamily: "Tajawal",
      decoration: TextDecoration.none,
    );
  }
   static TextStyle? semiBold20(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 20),
      fontWeight: FontWeight.w700,
      color: AppColors.kBlackColor,
      fontStyle: FontStyle.normal,
      fontFamily: "Tajawal",
      decoration: TextDecoration.none,
    );
  }

  static TextStyle? regular16(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 16),
      fontWeight: FontWeight.normal,
      color: AppColors.kWhiteColor,
      fontStyle: FontStyle.normal,
      fontFamily: "Tajawal",
      decoration: TextDecoration.none,
    );
  }

   static TextStyle? bold16(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 16),
      fontWeight: FontWeight.bold,
      color: AppColors.kWhiteColor,
      fontStyle: FontStyle.normal,
      fontFamily: "Tajawal",
      decoration: TextDecoration.none,
    );
  }

  static TextStyle? regular11(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 11),
      fontWeight: FontWeight.normal,
      color: AppColors.kRedColor,
      fontStyle: FontStyle.normal,      fontFamily: "Tajawal",

      decoration: TextDecoration.none,
    );
  }
 static TextStyle? regular14(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 14),
      fontWeight: FontWeight.normal,
      color: AppColors.kBlackColor,
      fontStyle: FontStyle.normal,      fontFamily: "Tajawal",

      decoration: TextDecoration.none,
    );
  }
  static TextStyle? bold14(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 14),
      fontWeight: FontWeight.bold,
      color: AppColors.kBlackColor,
      fontStyle: FontStyle.normal,      fontFamily: "Tajawal",

      decoration: TextDecoration.none,
    );
  }


    static TextStyle? regular13(BuildContext context) {
    return TextStyle(
      fontSize: getResponsiveFontSize(context, fontSize: 13),
      fontWeight: FontWeight.normal,
      color: AppColors.kBlackColor,
      fontStyle: FontStyle.normal,      fontFamily: "Tajawal",

      decoration: TextDecoration.none,
    );
  }
}

double getResponsiveFontSize(BuildContext context, {required double fontSize}) {
  double scaleFactor = getScaleFactor(context);
  double responsiveFontSize = fontSize * scaleFactor;

  double lowerLimit = fontSize * .7;
  double upperLimit = fontSize * 1.2;

  return responsiveFontSize.clamp(lowerLimit, upperLimit);
}

double getScaleFactor(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width < 600) {
    return width / 350;
  } else if (width < 1200) {
    return width / 750;
  } else {
    return width / 1920;
  }
}
