import 'package:flutter/material.dart';

/// A helper class to manage screen size, orientation, and device type for responsive UI.
class SizeConfig {
  /// The BuildContext required to get screen data.
  final BuildContext context;

  /// Holds the screen's media query data.
  late final MediaQueryData _mediaQueryData;
  
  /// The horizontal extent of this screen.
  late final double screenWidth;
  
  /// The vertical extent of this screen.
  late final double screenHeight;
  
  /// The orientation of the screen (portrait or landscape).
  late final Orientation orientation;

  /// Private constructor to prevent direct instantiation without context.
  SizeConfig._(this.context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }

  /// Static factory method to create an instance of SizeConfig.
  /// This is the intended way to get a SizeConfig object.
  static SizeConfig of(BuildContext context) {
    return SizeConfig._(context);
  }

  // --- Device Type Breakpoints ---
  // These are common breakpoints for different screen sizes.
  // You can adjust these values to better suit your project's needs.

  /// Returns `true` if the device's width is less than 650.
  /// Typically represents a mobile phone.
  bool get isMobile => screenWidth < 650;

  /// Returns `true` if the device's width is between 650 and 1100.
  /// Typically represents a tablet.
  bool get isTablet => screenWidth >= 650 && screenWidth < 1100;

  /// Returns `true` if the device's width is 1100 or greater.
  /// Typically represents a desktop or a large tablet in landscape mode.
  bool get isDesktop => screenWidth >= 1100;
}
