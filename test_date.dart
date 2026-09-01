import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

void main() {
  try {
    debugPrint(DateFormat('Today • d MMM').format(DateTime.now()));
  } catch (e) {
    debugPrint('Error: $e');
  }
}
