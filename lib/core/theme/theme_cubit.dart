import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/constants.dart';
import '../../core/storage/hive_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final box = HiveStorage.getBox(HiveStorage.appSettingsBoxName);
    final isDark =
        box.get(AppConstants.themeModeKey, defaultValue: false) as bool;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    final box = HiveStorage.getBox(HiveStorage.appSettingsBoxName);
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
      box.put(AppConstants.themeModeKey, true);
    } else {
      emit(ThemeMode.light);
      box.put(AppConstants.themeModeKey, false);
    }
  }
}
