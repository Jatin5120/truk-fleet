part of 'language_bloc.dart';

class Language extends Equatable {
  final Locale locale;
  const Language(this.locale) : assert(locale != null);

  @override
  List<Object> get props => [locale];
}
