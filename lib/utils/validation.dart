import 'package:email_validator/email_validator.dart';
import 'package:salarynow/information/cubit/residential_cubit/aadhaar_card_verification/aadhaar_card_verification_cubit.dart';
import 'package:salarynow/utils/written_text.dart';
import 'package:flutter/src/widgets/framework.dart';

class InputValidation {
  static final RegExp notNameRegExp = RegExp('[a-zA-Z]');
  static final RegExp nameRegExp = RegExp('[0-9]');
  static final RegExp noSpecialChar = RegExp("!^[`~!@#%^&*()-_=]+\$");

  static String? validatePanCard(String value) {
    String pattern = r'^[A-Z]{3}[P]{1}[A-Z]{1}[0-9]{4}[A-Z]{1}$';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return 'Please Enter Pancard Number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please Enter Valid Pancard Number';
    }
    return null;
  }

  static String? validateName(String value) {
    if (value.isEmpty) {
      return 'Enter Your Name';
    } else if (!notNameRegExp.hasMatch(value)) {
      return 'Enter a Valid Name';
    } else if (nameRegExp.hasMatch(value)) {
      return 'Enter a Valid Name';
    } else if (noSpecialChar.hasMatch(value)) {
      return 'Enter a Valid Name';
    }
    return null;
  }

  static String? validateNumber(String number) {
    final regex = RegExp(r'^\d+$');

    if (number.isEmpty) {
      return 'Please enter your number.';
    } else if (!regex.hasMatch(number)) {
      return 'Please enter a valid number (digits only).';
    }  else if (number.startsWith("0") ||
        number.startsWith("1") ||
        number.startsWith("2") ||
        number.startsWith("3") ||
        number.startsWith("4") ||
        number.startsWith("5")) {
      return 'The first digit cannot be 0-5.';
    } else if (number.length < 10) {
      return 'Please enter a valid 10-digit number.';
    } else if (number.contains(RegExp(r'[^0-9]'))) {
      return 'Please enter a valid number (digits only).';
    } else {
      return null; // Indicates a valid input
    }
  }


  static String? loginNumber(String number) {
    final regex = RegExp(r'^\d+$');

    if (number.isEmpty) {
      return MyWrittenText.enterMobileNoText;
    } else if (number.startsWith("0") ||
        number.startsWith("1") ||
        number.startsWith("2") ||
        number.startsWith("3") ||
        number.startsWith("3") ||
        number.startsWith("5")) {
      return 'Please Enter Correct Mobile No.';
    } else if (number.length < 10) {
      return MyWrittenText.enterMobileNoText;
    } else if (!regex.hasMatch(number)) {
      return 'Please Enter Correct Mobile No.';
    } else {
      int firstCharacter = int.parse(number);

      if (firstCharacter <= 5) {
        return 'Please Enter Correct Mobile No.';
      } else {
        return null;
      }
    }
  }

  static String? addressValidation(String value) {
    if (value.isEmpty) {
      return 'Please enter address detail';
    } else if (value.trim().isEmpty) {
      return 'Only whitespace not allowed';
    }else if (value.startsWith("0")) {
      return 'Please enter correct address';
    } else if (value.trimLeft() != value || value.trimRight() != value) {
      return 'First and last characters should not be whitespace';
    } else if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Address must contain letters / words.';
    } else if (value.trim() == ".") {
      return 'Address Name should not start with dot';
    }else if (value.contains('..')) {
      return 'Address Name should contain only one dot';
    } else if (!RegExp(r'\b\w(?:\.\s\w)?').hasMatch(value!)) {
      return 'Dot should only appear after a character';
    }else if (value.length <= 5) {
      return 'Enter at least 6 characters for the address';
    }else{
      List<String> words = value.split(' ');
      bool containsWordWithoutDot = words.any((word) => word.startsWith('.') || RegExp(r'\b\w*\.\w*\w*\b').hasMatch(word));
      if (containsWordWithoutDot) {
        return 'Dot should only appear after a character';
      }
    }

    return null;
  }

  static String? landmarkValidation(String value) {
    if (value.isEmpty) {
      return 'Please enter nearest landmark detail';
    } else if (value.trim().isEmpty) {
      return 'Only whitespace not allowed';
    }else if (value.startsWith("0")) {
      return 'Please enter correct nearest landmark details';
    } else if (value.trimLeft() != value || value.trimRight() != value) {
      return 'First and last characters should not be whitespace';
    }else if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Nearest landmark must contain letters / words.';
    } else if (value.trim() == ".") {
      return 'Nearest landmark details should not start with dot';
    }else if (value.contains('..')) {
      return 'Nearest landmark details should contain only one dot';
    } else if (!RegExp(r'\b\w(?:\.\s\w)?').hasMatch(value!)) {
      return 'Dot should only appear after a character';
    } else if (value.length <= 5) {
      return 'Enter at least 6 characters for the landmark details';
    }else{
      List<String> words = value.split(' ');
      bool containsWordWithoutDot = words.any((word) => word.startsWith('.') || RegExp(r'\b\w*\.\w*\w*\b').hasMatch(word));
      if (containsWordWithoutDot) {
        return 'Dot should only appear after a character';
      }
    }
    return null;
  }

  static String? salaryChecked(String value) {
    if (value.isEmpty) {
      return 'Please enter your Income';
    } else if (value.startsWith("0")) {
      return 'Please enter correct Income';
    }
    return null;
  }

  static String? emailValidation(String value) {
    if (value.isEmpty) {
      return 'Please enter email';
    } else if (value.trim().isEmpty) {
      return 'Only whitespace not allowed';
    }else if (value.startsWith("0")) {
      return 'Please enter correct email';
    } else if (value.trimLeft() != value || value.trimRight() != value) {
      return 'First and last characters should not be whitespace';
    }else if (!EmailValidator.validate(value)) {
      return "Enter correct email";
    }
    return null;
  }

  static String? notEmpty(String value) {
    if (value.isEmpty) {
      return "Please Fill This Field";
    }
    return null;
  }
}
