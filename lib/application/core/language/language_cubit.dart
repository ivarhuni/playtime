import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:ut_ad_leika/application/core/base_cubit.dart';
import 'package:ut_ad_leika/infrastructure/core/prefs/shared_prefs_keys.dart';
import 'package:ut_ad_leika/presentation/core/localization/user_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'language_state.dart';

@injectable
class LanguageCubit extends BaseCubit<LanguageState> {
  LanguageCubit() : super(const LanguageState.initial());

  Future<void> setLanguage(Language language) async {
    emit(state.copyWith(language: language));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
      SharedPrefsKeys.preferredLocale,
      "${language.locale.languageCode}-${language.locale.countryCode}",
    );
  }
}
