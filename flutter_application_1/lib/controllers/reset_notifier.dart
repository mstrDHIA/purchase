import 'package:flutter/foundation.dart';

class ResetNotifier extends ChangeNotifier {
  String? lastTarget;
  int? lastAt;

  /// Trigger a reset for a specific target label (e.g. 'Supplier', 'Product', '/dashboard')
  void trigger(String target) {
    lastTarget = target;
    lastAt = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  /// Clear the last trigger after it has been handled
  void clear() {
    lastTarget = null;
    lastAt = null;
  }
}
