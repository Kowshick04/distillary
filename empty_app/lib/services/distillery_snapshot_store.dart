import 'package:flutter/foundation.dart';
import '../models/distillery_snapshot_model.dart';

/// Global singleton store that holds the last two distillery Excel snapshots per factory.
class DistillerySnapshotStore extends ChangeNotifier {
  // -- Singleton --
  static final DistillerySnapshotStore _instance =
      DistillerySnapshotStore._internal();
  factory DistillerySnapshotStore() => _instance;
  DistillerySnapshotStore._internal();

  // -- State per factoryCode --
  final Map<String, DistilleryExcelSnapshot?> _currentSnapshots = {};
  final Map<String, DistilleryExcelSnapshot?> _previousSnapshots = {};

  /// Shift: old current becomes previous, new snapshot becomes current.
  void pushSnapshot(String factoryCode, DistilleryExcelSnapshot snapshot) {
    _previousSnapshots[factoryCode] = _currentSnapshots[factoryCode];
    _currentSnapshots[factoryCode] = snapshot;
    notifyListeners();
  }

  DistilleryExcelSnapshot? getCurrentSnapshot(String factoryCode) {
    return _currentSnapshots[factoryCode];
  }

  DistilleryExcelSnapshot? getPreviousSnapshot(String factoryCode) {
    return _previousSnapshots[factoryCode];
  }

  /// Whether at least one Excel has been loaded this session for this factory.
  bool hasData(String factoryCode) => _currentSnapshots[factoryCode] != null;

  /// Whether a previous Excel is available for comparison.
  bool hasPreviousData(String factoryCode) => _previousSnapshots[factoryCode] != null;
}

/// Convenience global accessor.
final distillerySnapshotStore = DistillerySnapshotStore();
