import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('en')
  ];

  /// No description provided for @no_runs.
  ///
  /// In bg, this message translates to:
  /// **'Все още не сте направили първото си бягане'**
  String get no_runs;

  /// No description provided for @km.
  ///
  /// In bg, this message translates to:
  /// **'км'**
  String get km;

  /// No description provided for @min.
  ///
  /// In bg, this message translates to:
  /// **'мин'**
  String get min;

  /// No description provided for @km_per_h.
  ///
  /// In bg, this message translates to:
  /// **'км/ч'**
  String get km_per_h;

  /// No description provided for @min_km.
  ///
  /// In bg, this message translates to:
  /// **'мин/км'**
  String get min_km;

  /// No description provided for @m.
  ///
  /// In bg, this message translates to:
  /// **'m'**
  String get m;

  /// No description provided for @sofia.
  ///
  /// In bg, this message translates to:
  /// **'София'**
  String get sofia;

  /// No description provided for @next.
  ///
  /// In bg, this message translates to:
  /// **'Напред'**
  String get next;

  /// No description provided for @settings_page_notifications.
  ///
  /// In bg, this message translates to:
  /// **'Известия'**
  String get settings_page_notifications;

  /// No description provided for @settings_page_settings.
  ///
  /// In bg, this message translates to:
  /// **'Настройки'**
  String get settings_page_settings;

  /// No description provided for @settings_page_strava.
  ///
  /// In bg, this message translates to:
  /// **'Strava интеграция'**
  String get settings_page_strava;

  /// No description provided for @settings_page_language.
  ///
  /// In bg, this message translates to:
  /// **'Език'**
  String get settings_page_language;

  /// No description provided for @settings_page_exit.
  ///
  /// In bg, this message translates to:
  /// **'Изход'**
  String get settings_page_exit;

  /// No description provided for @profile_page_last_run.
  ///
  /// In bg, this message translates to:
  /// **'Последно '**
  String get profile_page_last_run;

  /// No description provided for @profile_page_best_run.
  ///
  /// In bg, this message translates to:
  /// **'Най-добро '**
  String get profile_page_best_run;

  /// No description provided for @profile_page_legionary_selfie.
  ///
  /// In bg, this message translates to:
  /// **'Легионер\nselfie'**
  String get profile_page_legionary_selfie;

  /// No description provided for @profile_page_legionary_official.
  ///
  /// In bg, this message translates to:
  /// **'Легионер\nсъщинско'**
  String get profile_page_legionary_official;

  /// No description provided for @profile_page_official.
  ///
  /// In bg, this message translates to:
  /// **'същинско'**
  String get profile_page_official;

  /// No description provided for @home_label_profile.
  ///
  /// In bg, this message translates to:
  /// **'Профил'**
  String get home_label_profile;

  /// No description provided for @home_label_runs.
  ///
  /// In bg, this message translates to:
  /// **'Бягания'**
  String get home_label_runs;

  /// No description provided for @home_label_events.
  ///
  /// In bg, this message translates to:
  /// **'Събития'**
  String get home_label_events;

  /// No description provided for @home_label_support.
  ///
  /// In bg, this message translates to:
  /// **'Подкрепи'**
  String get home_label_support;

  /// No description provided for @barcode_page_barcode.
  ///
  /// In bg, this message translates to:
  /// **'Баркод'**
  String get barcode_page_barcode;

  /// No description provided for @barcode_page_patron.
  ///
  /// In bg, this message translates to:
  /// **'Патрон'**
  String get barcode_page_patron;

  /// No description provided for @barcode_page_runner.
  ///
  /// In bg, this message translates to:
  /// **'Бегач'**
  String get barcode_page_runner;

  /// No description provided for @user_runs_page_title.
  ///
  /// In bg, this message translates to:
  /// **'Твоите Бягания'**
  String get user_runs_page_title;

  /// No description provided for @events_page_events.
  ///
  /// In bg, this message translates to:
  /// **'Събития'**
  String get events_page_events;

  /// No description provided for @events_page_past_events.
  ///
  /// In bg, this message translates to:
  /// **'Минали събития'**
  String get events_page_past_events;

  /// No description provided for @events_page_upcoming_events.
  ///
  /// In bg, this message translates to:
  /// **'Предстоящи събития'**
  String get events_page_upcoming_events;

  /// No description provided for @events_results_page_results.
  ///
  /// In bg, this message translates to:
  /// **'Резултати'**
  String get events_results_page_results;

  /// No description provided for @login_widget_login_with_password.
  ///
  /// In bg, this message translates to:
  /// **'влез с парола'**
  String get login_widget_login_with_password;

  /// No description provided for @login_widget_login_with_id.
  ///
  /// In bg, this message translates to:
  /// **'влез с номер'**
  String get login_widget_login_with_id;

  /// No description provided for @login_widget_no_registration.
  ///
  /// In bg, this message translates to:
  /// **'Нямате регистрация?'**
  String get login_widget_no_registration;

  /// No description provided for @login_widget_register.
  ///
  /// In bg, this message translates to:
  /// **'Регистрирай се сега'**
  String get login_widget_register;

  /// No description provided for @donate_page_title.
  ///
  /// In bg, this message translates to:
  /// **'Подкрепи ни'**
  String get donate_page_title;

  /// No description provided for @donate_page_description.
  ///
  /// In bg, this message translates to:
  /// **'Това приложение и цялата дейност на 5kmRun се издържа изцяло от дарения и доброволен труд. Можете да подкрепите нашите усилия, чрез някой от изброените по-долу начини.'**
  String get donate_page_description;

  /// No description provided for @donate_page_become_a_patron.
  ///
  /// In bg, this message translates to:
  /// **'Стани Патрон'**
  String get donate_page_become_a_patron;

  /// No description provided for @donate_page_patreon_description.
  ///
  /// In bg, this message translates to:
  /// **'Можете да направите годишно дарение на стойност 24лв., което ще ви отреди званието \'Патрон\' за следващите 12 месеца. Сумата можете да дарите на място при същинските бягания или по банков път.'**
  String get donate_page_patreon_description;

  /// No description provided for @donate_page_pay_pal.
  ///
  /// In bg, this message translates to:
  /// **' PayPal'**
  String get donate_page_pay_pal;

  /// No description provided for @donate_page_pay_pal_description.
  ///
  /// In bg, this message translates to:
  /// **'Можете да направите еднократно или регулярно дарение на сума по ваш избор.'**
  String get donate_page_pay_pal_description;

  /// No description provided for @donate_page_fan_store.
  ///
  /// In bg, this message translates to:
  /// **' Фен магазин'**
  String get donate_page_fan_store;

  /// No description provided for @donate_page_fan_store_description.
  ///
  /// In bg, this message translates to:
  /// **'Всяка покупка на артикул на нашия фен магазин подпомага дейностите на 5kmrun и ни помага да стигнем безплатно до хиляди хора в България.'**
  String get donate_page_fan_store_description;

  /// No description provided for @donate_page_xl_run.
  ///
  /// In bg, this message translates to:
  /// **' XL бягане'**
  String get donate_page_xl_run;

  /// No description provided for @donate_page_xl_run_description.
  ///
  /// In bg, this message translates to:
  /// **'Всеки месец в района на София организираме предизвикателства в различни дължини, терени и натоварвания. Таксата за участие изцяло подпомага дейностите на 5kmrun.'**
  String get donate_page_xl_run_description;

  /// No description provided for @offline_chart_page_join.
  ///
  /// In bg, this message translates to:
  /// **'Участвай'**
  String get offline_chart_page_join;

  /// No description provided for @offline_chart_page_results.
  ///
  /// In bg, this message translates to:
  /// **'Подробни\nрезултати'**
  String get offline_chart_page_results;

  /// No description provided for @offline_chart_page_no_results.
  ///
  /// In bg, this message translates to:
  /// **'Няма резултати'**
  String get offline_chart_page_no_results;

  /// No description provided for @offline_chart_page_login.
  ///
  /// In bg, this message translates to:
  /// **'Вход с парола'**
  String get offline_chart_page_login;

  /// No description provided for @offline_chart_page_participation_in.
  ///
  /// In bg, this message translates to:
  /// **'Участието в '**
  String get offline_chart_page_participation_in;

  /// No description provided for @offline_chart_page_leaderboard_access.
  ///
  /// In bg, this message translates to:
  /// **' класацията е достъпно вход с парола!'**
  String get offline_chart_page_leaderboard_access;

  /// No description provided for @offline_chart_page_cancel.
  ///
  /// In bg, this message translates to:
  /// **'Откажи'**
  String get offline_chart_page_cancel;

  /// No description provided for @offline_chart_page_weekly.
  ///
  /// In bg, this message translates to:
  /// **'Седмична '**
  String get offline_chart_page_weekly;

  /// No description provided for @offline_chart_page_leaderboard.
  ///
  /// In bg, this message translates to:
  /// **' класация'**
  String get offline_chart_page_leaderboard;

  /// No description provided for @offline_chart_page_previous_week.
  ///
  /// In bg, this message translates to:
  /// **'Предходна седмица'**
  String get offline_chart_page_previous_week;

  /// No description provided for @offline_chart_page_current_week.
  ///
  /// In bg, this message translates to:
  /// **'Текуща седмица'**
  String get offline_chart_page_current_week;

  /// No description provided for @add_offline_entry_page_server_error.
  ///
  /// In bg, this message translates to:
  /// **'Сървърна грешка'**
  String get add_offline_entry_page_server_error;

  /// No description provided for @add_offline_entry_page_data_error.
  ///
  /// In bg, this message translates to:
  /// **'Грешка при изпращане на данните. Моля, опитайте по-късно.'**
  String get add_offline_entry_page_data_error;

  /// No description provided for @add_offline_entry_page_ok.
  ///
  /// In bg, this message translates to:
  /// **'OK'**
  String get add_offline_entry_page_ok;

  /// No description provided for @add_offline_entry_page_authentication_error.
  ///
  /// In bg, this message translates to:
  /// **'Невалидно потребителско име и парола'**
  String get add_offline_entry_page_authentication_error;

  /// No description provided for @add_offline_entry_page_login_again.
  ///
  /// In bg, this message translates to:
  /// **'Влезте отново с вашите 5kmRun потребителско име и парола.'**
  String get add_offline_entry_page_login_again;

  /// No description provided for @add_offline_entry_page_login.
  ///
  /// In bg, this message translates to:
  /// **'Вход'**
  String get add_offline_entry_page_login;

  /// No description provided for @add_offline_entry_page_cancel.
  ///
  /// In bg, this message translates to:
  /// **'Откажи'**
  String get add_offline_entry_page_cancel;

  /// No description provided for @add_offline_entry_page_server_sending_error.
  ///
  /// In bg, this message translates to:
  /// **'Грешка при изпращане на сървъра'**
  String get add_offline_entry_page_server_sending_error;

  /// No description provided for @add_offline_entry_page_join_leaderboard.
  ///
  /// In bg, this message translates to:
  /// **'Участвай в класацията'**
  String get add_offline_entry_page_join_leaderboard;

  /// No description provided for @add_offline_entry_page_join_leaderboard_instructions.
  ///
  /// In bg, this message translates to:
  /// **'За да продължите - следвайте инструкциите и свържете 5kmRun приложението с вашия Strava профил.\n\nМоля, използвайте Google Chrome при свързването и въведете директно Strava потребителско име и парола. В момента, свързване с други браузъри не сработва успешно.\n\nСистемата на селфи отчита  „Elapsed time“, т.е. вашето общо (цялостно) време на бягането, което включва и времето при включена пауза или просто спрял на място! Много хора се заблуждават, че селфи ще им приеме тяхното „Moving Time“, което представлява само времето на движение без включените паузи и спиранията, т.е. случаите, при които се прекъсва бягането с използването на бутона „пауза“ или спиране на място!'**
  String get add_offline_entry_page_join_leaderboard_instructions;

  /// No description provided for @add_offline_entry_page_join_with_current_run.
  ///
  /// In bg, this message translates to:
  /// **'Участвай с избраното бягане'**
  String get add_offline_entry_page_join_with_current_run;

  /// No description provided for @add_offline_entry_page_sending.
  ///
  /// In bg, this message translates to:
  /// **'Изпращане'**
  String get add_offline_entry_page_sending;

  /// No description provided for @add_offline_entry_page_uploading_error.
  ///
  /// In bg, this message translates to:
  /// **'Грешка при качване'**
  String get add_offline_entry_page_uploading_error;

  /// No description provided for @run_details_page_position.
  ///
  /// In bg, this message translates to:
  /// **'Позиция'**
  String get run_details_page_position;

  /// No description provided for @run_details_page_pace.
  ///
  /// In bg, this message translates to:
  /// **'Темпо'**
  String get run_details_page_pace;

  /// No description provided for @run_details_page_time.
  ///
  /// In bg, this message translates to:
  /// **'Време'**
  String get run_details_page_time;

  /// No description provided for @run_details_page_speed.
  ///
  /// In bg, this message translates to:
  /// **'Скорост'**
  String get run_details_page_speed;

  /// No description provided for @offline_chart_details_page_date.
  ///
  /// In bg, this message translates to:
  /// **'дата'**
  String get offline_chart_details_page_date;

  /// No description provided for @offline_chart_details_page_position.
  ///
  /// In bg, this message translates to:
  /// **'позиция'**
  String get offline_chart_details_page_position;

  /// No description provided for @offline_chart_details_page_time.
  ///
  /// In bg, this message translates to:
  /// **'време'**
  String get offline_chart_details_page_time;

  /// No description provided for @offline_chart_details_page_total_time.
  ///
  /// In bg, this message translates to:
  /// **'общо време'**
  String get offline_chart_details_page_total_time;

  /// No description provided for @offline_chart_details_page_pace.
  ///
  /// In bg, this message translates to:
  /// **'темпо'**
  String get offline_chart_details_page_pace;

  /// No description provided for @offline_chart_details_page_total_elevation_gained.
  ///
  /// In bg, this message translates to:
  /// **'общо изкачване'**
  String get offline_chart_details_page_total_elevation_gained;

  /// No description provided for @offline_chart_details_page_hour.
  ///
  /// In bg, this message translates to:
  /// **'час'**
  String get offline_chart_details_page_hour;

  /// No description provided for @offline_chart_details_page_location.
  ///
  /// In bg, this message translates to:
  /// **'локация'**
  String get offline_chart_details_page_location;

  /// No description provided for @offline_chart_details_page_distance.
  ///
  /// In bg, this message translates to:
  /// **'дистанция'**
  String get offline_chart_details_page_distance;

  /// No description provided for @offline_chart_details_page_total_distance.
  ///
  /// In bg, this message translates to:
  /// **'обща дистанция'**
  String get offline_chart_details_page_total_distance;

  /// No description provided for @offline_chart_details_page_elevation.
  ///
  /// In bg, this message translates to:
  /// **'денивелация'**
  String get offline_chart_details_page_elevation;

  /// No description provided for @offline_chart_details_page_status.
  ///
  /// In bg, this message translates to:
  /// **'статус'**
  String get offline_chart_details_page_status;

  /// No description provided for @offline_chart_details_page_confirmed.
  ///
  /// In bg, this message translates to:
  /// **'доказан'**
  String get offline_chart_details_page_confirmed;

  /// No description provided for @offline_chart_details_page_independent.
  ///
  /// In bg, this message translates to:
  /// **'самостоятелен'**
  String get offline_chart_details_page_independent;

  /// No description provided for @offline_chart_details_page_disqualified.
  ///
  /// In bg, this message translates to:
  /// **'дисквалифициран'**
  String get offline_chart_details_page_disqualified;

  /// No description provided for @results_list_no_results.
  ///
  /// In bg, this message translates to:
  /// **'Няма резултати'**
  String get results_list_no_results;

  /// No description provided for @results_list_anonymous.
  ///
  /// In bg, this message translates to:
  /// **'Анонимен'**
  String get results_list_anonymous;

  /// No description provided for @results_list_search_bar.
  ///
  /// In bg, this message translates to:
  /// **'Търси по име или номер'**
  String get results_list_search_bar;

  /// No description provided for @no_results_component_no_suitable_runs.
  ///
  /// In bg, this message translates to:
  /// **'Няма подходящи бягания!'**
  String get no_results_component_no_suitable_runs;

  /// No description provided for @no_results_component_participation_requirements.
  ///
  /// In bg, this message translates to:
  /// **'Участието в класацията е възможно с бягания отговарящи на следните условия:'**
  String get no_results_component_participation_requirements;

  /// No description provided for @no_results_component_requirements.
  ///
  /// In bg, this message translates to:
  /// **'1. Бягането е качено в Strava и е направено в текущата седмица\n\n2. Бягането е от тип Run и не е на пътека\n\n3. Дължината на бягането е поне 5км\n\n4. Към бягането има карта, която е видима за всички потребители'**
  String get no_results_component_requirements;

  /// No description provided for @login_with_id_widget_personal_id.
  ///
  /// In bg, this message translates to:
  /// **'личен номер'**
  String get login_with_id_widget_personal_id;

  /// No description provided for @login_with_id_widget_participation.
  ///
  /// In bg, this message translates to:
  /// **'Участието в '**
  String get login_with_id_widget_participation;

  /// No description provided for @login_with_id_widget_authentication.
  ///
  /// In bg, this message translates to:
  /// **' класацията е достъпно само с парола!'**
  String get login_with_id_widget_authentication;

  /// No description provided for @login_with_username_widget_wrong_auth.
  ///
  /// In bg, this message translates to:
  /// **'Грешно потребителско име или парола'**
  String get login_with_username_widget_wrong_auth;

  /// No description provided for @login_with_username_widget_password.
  ///
  /// In bg, this message translates to:
  /// **'парола'**
  String get login_with_username_widget_password;

  /// No description provided for @login_preview_widget_year.
  ///
  /// In bg, this message translates to:
  /// **'г.'**
  String get login_preview_widget_year;

  /// No description provided for @login_preview_widget_loading.
  ///
  /// In bg, this message translates to:
  /// **'зареждане ...'**
  String get login_preview_widget_loading;

  /// No description provided for @login_preview_widget_login_as.
  ///
  /// In bg, this message translates to:
  /// **'Влез като'**
  String get login_preview_widget_login_as;

  /// No description provided for @best_time_by_route_chart_widget_records.
  ///
  /// In bg, this message translates to:
  /// **'Рекорди по същински трасета'**
  String get best_time_by_route_chart_widget_records;

  /// No description provided for @run_card_widget_place.
  ///
  /// In bg, this message translates to:
  /// **'място'**
  String get run_card_widget_place;

  /// No description provided for @app_rating_manager_title.
  ///
  /// In bg, this message translates to:
  /// **'Харесвате ли приложението?'**
  String get app_rating_manager_title;

  /// No description provided for @app_rating_manager_message.
  ///
  /// In bg, this message translates to:
  /// **'Помогнете ни да го направим още по-добро, като оставите вашето мнение'**
  String get app_rating_manager_message;

  /// No description provided for @app_rating_manager_rate_button.
  ///
  /// In bg, this message translates to:
  /// **'Да, разбира се'**
  String get app_rating_manager_rate_button;

  /// No description provided for @app_rating_manager_no_button.
  ///
  /// In bg, this message translates to:
  /// **'Не, благодаря'**
  String get app_rating_manager_no_button;

  /// No description provided for @app_rating_manager_later_button.
  ///
  /// In bg, this message translates to:
  /// **'По-късно'**
  String get app_rating_manager_later_button;

  /// No description provided for @runs_by_route_chart_title.
  ///
  /// In bg, this message translates to:
  /// **'Бягания по същински трасета'**
  String get runs_by_route_chart_title;

  /// No description provided for @runs_chart_date.
  ///
  /// In bg, this message translates to:
  /// **'Дата: '**
  String get runs_chart_date;

  /// No description provided for @runs_chart_time.
  ///
  /// In bg, this message translates to:
  /// **'\nВреме: '**
  String get runs_chart_time;

  /// No description provided for @runs_chart_trend.
  ///
  /// In bg, this message translates to:
  /// **'Тенденция от последните '**
  String get runs_chart_trend;

  /// No description provided for @runs_chart_runs.
  ///
  /// In bg, this message translates to:
  /// **' бягания'**
  String get runs_chart_runs;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bg', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
