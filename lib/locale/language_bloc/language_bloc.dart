import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truk_fleet/sessionmanagement/session_manager.dart';
part 'language_event.dart';

part 'language.dart';

class LanguageBloc extends Bloc<LanguageEvent, Language> {
  LanguageBloc() : super(Language(Locale('en', 'US')));

  @override
  Stream<Language> mapEventToState(LanguageEvent event) async* {
    if (event is LanguageLoadStarted) {
      yield* _mapLanguageLoadStartedToState();
    } else if (event is LanguageSelected) {
      yield* _mapLanguageSelectedToState(event.languageCode);
    }
  }

  Stream<Language> _mapLanguageLoadStartedToState() async* {
    final sharedPrefService = SharedPref();
    final defaultLanguage = SharedPref.en;
    Locale locale = await sharedPrefService.getLocale() ?? defaultLanguage;

    yield Language(locale);
  }

  Stream<Language> _mapLanguageSelectedToState(Language selectedLanguage) async* {
    final sharedPrefService = SharedPref();
    final defaultLanguage = await sharedPrefService.getLocale() ?? SharedPref.en;

    if (selectedLanguage.locale == SharedPref.hi && defaultLanguage != SharedPref.hi) {
      yield* _loadLanguage(sharedPrefService, 'hi', 'IN');
    } else if (selectedLanguage.locale == SharedPref.en && defaultLanguage != SharedPref.en) {
      yield* _loadLanguage(sharedPrefService, 'en', 'US');
    } else if (selectedLanguage.locale == SharedPref.te && defaultLanguage != SharedPref.te) {
      yield* _loadLanguage(sharedPrefService, 'te', 'IN');
    }
  }

  /// This method is added to reduce code repetition.
  Stream<Language> _loadLanguage(SharedPref sharedPref, String languageCode, String countryCode) async* {
    final locale = Locale(languageCode, countryCode);
    await sharedPref.setLocale(locale.languageCode);
    yield Language(locale);
  }
}
