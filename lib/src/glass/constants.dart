import 'package:flutter/material.dart';

import 'colors.dart';
import 'int_extensions.dart';

enum PageRouteAnimation { Fade, Scale, Rotate, Slide, SlideBottomTop }

const double defaultRadius = 10;
const THEME_MODE_INDEX = 'theme_mode_index';
double tabletBreakpointGlobal = 600.0;
double desktopBreakpointGlobal = 720.0;
double? defaultInkWellRadius;
Color? defaultInkWellSplashColor;
Color? defaultInkWellHoverColor;
Color? defaultInkWellHighlightColor;
Color textPrimaryColorGlobal = textPrimaryColor;
Color textSecondaryColorGlobal = textSecondaryColor;
double defaultAppButtonElevation = 4.0;
double defaultAppBarElevation = 1.0;
int passwordLengthGlobal = 6;
PageRouteAnimation? pageRouteAnimationGlobal;
bool enableAppButtonScaleAnimationGlobal = true;
int? appButtonScaleAnimationDurationGlobal;
Duration pageRouteTransitionDurationGlobal = 400.milliseconds;
int defaultElevation = 4;
var customDialogHeight = 140.0;
var customDialogWidth = 220.0;
double defaultAppButtonRadius = 10.0;
double defaultBlurRadius = 4.0;
double defaultSpreadRadius = 0.5;
Color defaultLoaderBgColorGlobal = Colors.white;
Color? defaultLoaderAccentColorGlobal;
bool forceEnableDebug = false;
double textBoldSizeGlobal = 16;
double textPrimarySizeGlobal = 16;
double textSecondarySizeGlobal = 14;
String? fontFamilyBoldGlobal;
String? fontFamilyPrimaryGlobal;
String? fontFamilySecondaryGlobal;
FontWeight fontWeightBoldGlobal = FontWeight.bold;
FontWeight fontWeightPrimaryGlobal = FontWeight.normal;
FontWeight fontWeightSecondaryGlobal = FontWeight.normal;
ShapeBorder? defaultDialogShape;
//region contact num lenghth
const minContactLength = 8;
const maxContactLength = 15;
const digitAfterDecimal = 2;
//endregion

String generateUsername(String email) {
  return email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
}
