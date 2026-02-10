import 'package:bedtime_stories/styles/app_colour_codes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';



class AppTheme{
  static final appThemeConfig = ThemeData(
      // primarySwatch: Color(0xFF4E598D),
      fontFamily: "inter",
      scaffoldBackgroundColor: whiteColor,
      iconTheme: const IconThemeData(
        color: Colors.black,
        size: 18,
        shadows: <Shadow>[Shadow(color: Colors.black, blurRadius: 0.5)],
      ),
      // Text input decoration
     textTheme: GoogleFonts.poppinsTextTheme(
        ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: textFormFieldColor,
        filled: true,
        labelStyle: const TextStyle(fontFamily: "inter"),
        // prefixIconColor: AppColors.appPrimaryColor,
        suffixIconColor: appPrimaryColor,
        iconColor: appPrimaryColor,

        hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
            color: greyColor),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14.0, horizontal: 21.0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              width: 1.0,
              color: borderColor,
            )),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(
              width: 1.0,
              color: borderColor,
            )),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(width: 1.0, color: borderColor)),
      ),
      appBarTheme: AppBarTheme(
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: whiteColor,
          //shadowColor: AppColors.appBarShadowColor,
          iconTheme: IconThemeData(color: whiteColor, size: 18),
          actionsIconTheme: IconThemeData(color: appBarIconColor, size: 24),
          titleTextStyle: TextStyle(
              fontSize: 18.0, fontWeight: FontWeight.w600, color: headTextColor)),
      dividerTheme: DividerThemeData(color: HexColor("#E4E9F5")),
      actionIconTheme: ActionIconThemeData(backButtonIconBuilder: (context) {
        return IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ));
      }),
      radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.all(HexColor("#09486C"))));

  static   showSnackBar ({required String? msg, Color? color}){
    return SnackBar(
      backgroundColor: color ?? Colors.black,
      content: Text(msg!),
      duration: const Duration(seconds: 3),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(5.0), right: Radius.circular(5.0))
      ),
      dismissDirection: DismissDirection.horizontal,
    );
  }

}

