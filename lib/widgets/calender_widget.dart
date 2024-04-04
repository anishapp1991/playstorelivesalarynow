import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salarynow/form_helper/form_helper_cubit/form_helper_cubit.dart';
import 'package:salarynow/utils/color.dart';
import '../registration/cubit/registration_cubit.dart';

class MyCalenderWidget {
  static showCalender(BuildContext context) {
    var date = DateTime(
      DateTime.now().year - 18,
      DateTime.now().month,
      DateTime.now().day,
    );
    showDatePicker(
            context: context,
            initialDate: date, //get today's date
            firstDate: DateTime(1969), //DateTime.now() - not to allow to choose before today.
            lastDate: date)
        .then((value) => {
              context.read<RegistrationCubit>().setDate(value!),
              log(value.toString()),
            });
  }

  static showIOSCalender(BuildContext context) {
    var date = DateTime(
      DateTime.now().year - 18,
      DateTime.now().month,
      DateTime.now().day,
    );
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = date; // Initialize selectedDate with the initial date

        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 200,
                child: CupertinoDatePicker(
                  dateOrder: DatePickerDateOrder.dmy,
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: date,
                  minimumDate: DateTime(1969),
                  maximumDate: date,
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate; // Update selectedDate when date changes
                  },
                ),
              ),
              SizedBox(height: 10), // Add some spacing between the date picker and the button
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 17,
                          color: MyColor.redColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<RegistrationCubit>().setDate(selectedDate);
                        log(selectedDate.toString());
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 17,
                          color: MyColor.primaryBlueColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static showSalaryCalender(BuildContext context) {
    var date = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    var lastDate = DateTime(
      DateTime.now().year,
      DateTime.now().month + 2,
      DateTime.now().day,
    );

    // showDatePicker(
    //         context: context,
    //         initialDate: date, //get today's date
    //         firstDate: DateTime(1969), //DateTime.now() - not to allow to choose before today.
    //         lastDate: lastDate)
    //     .then((value) => {
    //           context.read<FormHelperApiCubit>().setDate(value!),
    //         });

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = date; // Initialize selectedDate with the initial date

        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 200,
                child: CupertinoDatePicker(
                  dateOrder: DatePickerDateOrder.dmy,
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: date,
                  minimumDate: DateTime(1969),
                  maximumDate: lastDate,
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate; // Update selectedDate when date changes
                  },
                ),
              ),
              SizedBox(height: 10), // Add some spacing between the date picker and the button
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 17,
                          color: MyColor.redColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<FormHelperApiCubit>().setDate(selectedDate);
                        log(selectedDate.toString());
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 17,
                          color: MyColor.primaryBlueColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static showPersonalDOBCalender(BuildContext context) {
    var date = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    showDatePicker(
            context: context,
            initialDate: date, //get today's date
            firstDate: DateTime(1969), //DateTime.now() - not to allow to choose before today.
            lastDate: date)
        .then((value) => {
              context.read<FormHelperApiCubit>().setDate(value!),
            });
  }
}
