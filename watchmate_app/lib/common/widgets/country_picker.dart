import 'package:watchmate_app/common/widgets/text_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

void buildCountryPicker(BuildContext context, Function(Country) onSelect) {
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

  final cardColor = theme.cardColor;
  final fillColor = cardColor.withValues(alpha: 0.2);

  showCountryPicker(
    showPhoneCode: true,
    context: context,
    countryListTheme: CountryListThemeData(
      searchTextStyle: TextStyle(fontSize: 16, color: textColor),
      textStyle: TextStyle(fontSize: 16, color: textColor),
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomSheetHeight: 500,
      flagSize: 20,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20.0),
        topLeft: Radius.circular(20.0),
      ),
      inputDecoration: customInputDecoration(
        prefixIcon: Icon(Icons.search, color: textColor),
        hint: "Search...",
        context: context,
      ).copyWith(fillColor: fillColor),
    ),
    onSelect: onSelect,
  );
}
