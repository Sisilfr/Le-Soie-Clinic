import 'package:flutter/foundation.dart';
import '../models/routine_item.dart';

class RoutineProvider extends ChangeNotifier {
  bool _isAM = true;

  final List<RoutineItem> _amItems = [
    RoutineItem(id: 'am1', name: 'Gentle Foam Cleanser', duration: '60s', isDone: true),
    RoutineItem(id: 'am2', name: 'Brightening Essence', duration: '30s', isDone: true),
    RoutineItem(id: 'am3', name: 'Hydra-Glow Serum', duration: '60s', isDone: true),
    RoutineItem(id: 'am4', name: 'Barrier Repair Cream', duration: '30s', isDone: false),
    RoutineItem(id: 'am5', name: 'UV Tint SPF50', duration: '30s', isDone: false),
  ];

  final List<RoutineItem> _pmItems = [
    RoutineItem(id: 'pm1', name: 'Oil Cleanser', duration: '60s', isDone: false),
    RoutineItem(id: 'pm2', name: 'Foam Cleanser', duration: '60s', isDone: false),
    RoutineItem(id: 'pm3', name: 'Retinol Serum', duration: '30s', isDone: false),
    RoutineItem(id: 'pm4', name: 'Night Cream', duration: '60s', isDone: false),
  ];

  bool get isAM => _isAM;
  List<RoutineItem> get amItems => _amItems;
  List<RoutineItem> get pmItems => _pmItems;
  List<RoutineItem> get currentItems => _isAM ? _amItems : _pmItems;

  int get doneCount => currentItems.where((e) => e.isDone).length;
  int get totalCount => currentItems.length;

  void toggleTab(bool isAM) {
    _isAM = isAM;
    notifyListeners();
  }

  void toggleDone(RoutineItem item) {
    item.isDone = !item.isDone;
    notifyListeners();
  }

  void addRoutineItem(String name, String duration, bool isAM) {
    final newItem = RoutineItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      duration: duration.isEmpty ? '30s' : duration,
      isDone: false,
    );
    if (isAM) {
      _amItems.add(newItem);
    } else {
      _pmItems.add(newItem);
    }
    notifyListeners();
  }
}
