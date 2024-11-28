import 'package:flutter/material.dart';

class SkipStatusProvider with ChangeNotifier {
  bool _skipClicked = false;

  bool get skipClicked => _skipClicked;

  void setSkipStatus(bool status) {
    _skipClicked = status;
    notifyListeners(); // Notify listeners to rebuild widgets using this state
  }
}
