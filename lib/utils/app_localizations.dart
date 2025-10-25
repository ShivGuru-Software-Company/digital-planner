import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Digital Planner',
      'home': 'Home',
      'calendar': 'Calendar',
      'settings': 'Settings',
      'search_templates': 'Search templates...',
      'choose_template': 'Choose your template',
      'create_entry': 'Create Entry',
      'new_entry': 'New Entry',
      'edit_entry': 'Edit Entry',
      'title': 'Title',
      'content': 'Content',
      'save': 'Save',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'draw': 'Draw',
      'image': 'Image',
      'reminder': 'Reminder',
      'about_us': 'About Us',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'appearance': 'Appearance',
      'language': 'Language',
      'theme_mode': 'Theme Mode',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'backup_data': 'Backup Data',
      'restore_data': 'Restore Data',
      'clear_all_data': 'Clear All Data',
      'no_entries': 'No entries for this day',
    },
    'hi': {
      'app_title': 'डिजिटल प्लानर',
      'home': 'होम',
      'calendar': 'कैलेंडर',
      'settings': 'सेटिंग्स',
      'search_templates': 'टेम्पलेट खोजें...',
      'choose_template': 'अपना टेम्पलेट चुनें',
      'create_entry': 'एंट्री बनाएं',
      'new_entry': 'नई एंट्री',
      'edit_entry': 'एंट्री संपादित करें',
      'title': 'शीर्षक',
      'content': 'सामग्री',
      'save': 'सहेजें',
      'delete': 'हटाएं',
      'cancel': 'रद्द करें',
      'draw': 'ड्रॉ करें',
      'image': 'चित्र',
      'reminder': 'रिमाइंडर',
      'about_us': 'हमारे बारे में',
      'privacy_policy': 'गोपनीयता नीति',
      'terms_of_service': 'सेवा की शर्तें',
      'appearance': 'दिखावट',
      'language': 'भाषा',
      'theme_mode': 'थीम मोड',
      'light': 'लाइट',
      'dark': 'डार्क',
      'system': 'सिस्टम',
      'backup_data': 'डेटा बैकअप',
      'restore_data': 'डेटा रिस्टोर',
      'clear_all_data': 'सभी डेटा साफ़ करें',
      'no_entries': 'इस दिन के लिए कोई एंट्री नहीं',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appTitle => translate('app_title');
  String get home => translate('home');
  String get calendar => translate('calendar');
  String get settings => translate('settings');
  String get searchTemplates => translate('search_templates');
  String get chooseTemplate => translate('choose_template');
  String get createEntry => translate('create_entry');
  String get newEntry => translate('new_entry');
  String get editEntry => translate('edit_entry');
  String get title => translate('title');
  String get content => translate('content');
  String get save => translate('save');
  String get delete => translate('delete');
  String get cancel => translate('cancel');
  String get draw => translate('draw');
  String get image => translate('image');
  String get reminder => translate('reminder');
  String get aboutUs => translate('about_us');
  String get privacyPolicy => translate('privacy_policy');
  String get termsOfService => translate('terms_of_service');
  String get appearance => translate('appearance');
  String get language => translate('language');
  String get themeMode => translate('theme_mode');
  String get light => translate('light');
  String get dark => translate('dark');
  String get system => translate('system');
  String get backupData => translate('backup_data');
  String get restoreData => translate('restore_data');
  String get clearAllData => translate('clear_all_data');
  String get noEntries => translate('no_entries');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
