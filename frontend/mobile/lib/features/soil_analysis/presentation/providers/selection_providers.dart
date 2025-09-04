import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/champ.dart';
import '../../domain/entities/parcelle.dart';

final selectedChampProvider = StateProvider<Champ?>((ref) => null);
final selectedParcelleProvider = StateProvider<Parcelle?>((ref) => null);
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
