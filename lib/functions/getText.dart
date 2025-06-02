final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'welcome': 'مرحباً، ',
      'welcomeBack': 'أهلاً بعودتك',
      'searchPlant': 'أورناجايد',
      'capturePlant': 'التقط صورة للنبتة',
      'uploadPhoto': 'اختر صورة من المعرض',
      'nextIdentification': 'التعرف التالي',
      'wateringSchedule': 'مواعيد الري',
      'signOut': 'تسجيل الخروج',
      'recentlyViewed': 'آخر ما شاهدته',
      'cabbage': 'ملفوف',
      'name': 'الاسم',
      'description': 'الوصف',
      'type': 'النوع',
      'fact': 'معلومة',
      'searchHint': 'ابحث عن نبتة...',
      'emptySearch': 'الرجاء إدخال اسم نبتة',
      'searchError': 'خطأ في البحث',
    },
    'en': {
      'welcome': 'Hello, ',
      'welcomeBack': 'Welcome back',
      'searchPlant': 'OrnaGuide',
      'capturePlant': 'Capture Your Plant',
      'uploadPhoto': 'Upload a Picture',
      'signOut': 'Sign Out',
      'recentlyViewed': 'Recently Viewed',
      'cabbage': 'Cabbage',
      'name': 'Name',
      'description': 'Description',
      'type': 'Type',
      'fact': 'Fact',
      'searchHint': 'Search for a plant...',
      'emptySearch': 'Please enter a plant name',
      'searchError': 'Search failed',
    },
  };

String getText(String key, {required bool isArabic}) {
    return _localizedValues[isArabic ? 'ar' : 'en']![key] ?? key;
  }