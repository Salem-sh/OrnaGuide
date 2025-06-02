import 'package:flutter/material.dart';

// List of texts used in the app in English and Arabic
String getText(String key, {bool isArabic = false}) {
  final Map<String, Map<String, String>> texts = {
    // Existing app texts
    'welcome': {
      'en': 'Hello, ',
      'ar': 'مرحباً، ',
    },
    'welcomeBack': {
      'en': 'welcome back',
      'ar': 'مرحباً بعودتك',
    },
    'searchHint': {
      'en': 'Search your plant',
      'ar': 'ابحث عن نباتك',
    },
    'capturePlant': {
      'en': 'Camera',
      'ar': 'الكاميرا',
    },
    'captureSub': {
      'en': 'Capture Your Plant',
      'ar': 'التقط صورة لنباتك',
    },
    'uploadPhoto': {
      'en': 'Album',
      'ar': 'الصور',
    },
    'uploadSub': {
      'en': 'Upload a Picture',
      'ar': 'تحميل صورة',
    },
    'identify': {
      'en': 'Identify',
      'ar': 'تحديد',
    },
    'identifySub': {
      'en': 'Plant Identification',
      'ar': 'تحديد النبات',
    },
    'watering': {
      'en': 'Watering',
      'ar': 'الري',
    },
    'wateringSub': {
      'en': 'Plant Watering Schedule',
      'ar': 'جدول ري النبات',
    },
    'recentlyView': {
      'en': 'Recently View',
      'ar': 'شوهدت مؤخراً',
    },
    'recentlyViewSub': {
      'en': 'Cactus',
      'ar': 'الصبار',
    },
    'signOut': {
      'en': 'Sign Out',
      'ar': 'تسجيل الخروج',
    },
    'emptySearch': {
      'en': 'Please enter a plant name to search',
      'ar': 'يرجى إدخال اسم النبات للبحث',
    },
    'searchError': {
      'en': 'Error searching for plant. Please try again.',
      'ar': 'خطأ في البحث عن النبات. يرجى المحاولة مرة أخرى.',
    },
    'recentlyViewed': {
      'en': 'Recently Viewed',
      'ar': 'شوهدت مؤخراً',
    },
    'noHistory': {
      'en': 'No plants viewed yet',
      'ar': 'لم تتم مشاهدة أي نباتات بعد',
    },

    // Settings page texts
    'settings': {
      'en': 'Settings',
      'ar': 'الإعدادات',
    },
    'profile': {
      'en': 'Profile Information',
      'ar': 'معلومات الملف الشخصي',
    },
    'fullName': {
      'en': 'Full Name',
      'ar': 'الاسم الكامل',
    },
    'email': {
      'en': 'Email',
      'ar': 'البريد الإلكتروني',
    },
    'password': {
      'en': 'Password',
      'ar': 'كلمة المرور',
    },
    'updateName': {
      'en': 'Update Name',
      'ar': 'تحديث الاسم',
    },
    'updateEmail': {
      'en': 'Update Email',
      'ar': 'تحديث البريد الإلكتروني',
    },
    'changePassword': {
      'en': 'Change Password',
      'ar': 'تغيير كلمة المرور',
    },
    'currentPassword': {
      'en': 'Current Password',
      'ar': 'كلمة المرور الحالية',
    },
    'newPassword': {
      'en': 'New Password',
      'ar': 'كلمة المرور الجديدة',
    },
    'confirmPassword': {
      'en': 'Confirm Password',
      'ar': 'تأكيد كلمة المرور',
    },
    'update': {
      'en': 'Update',
      'ar': 'تحديث',
    },
    'cancel': {
      'en': 'Cancel',
      'ar': 'إلغاء',
    },
    'nameRequired': {
      'en': 'Name is required',
      'ar': 'الاسم مطلوب',
    },
    'emailRequired': {
      'en': 'Email is required',
      'ar': 'البريد الإلكتروني مطلوب',
    },
    'invalidEmail': {
      'en': 'Please enter a valid email address',
      'ar': 'يرجى إدخال عنوان بريد إلكتروني صالح',
    },
    'currentPasswordRequired': {
      'en': 'Current password is required',
      'ar': 'كلمة المرور الحالية مطلوبة',
    },
    'newPasswordRequired': {
      'en': 'New password is required',
      'ar': 'كلمة المرور الجديدة مطلوبة',
    },
    'passwordTooShort': {
      'en': 'Password must be at least 6 characters',
      'ar': 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل',
    },
    'confirmPasswordRequired': {
      'en': 'Please confirm your password',
      'ar': 'يرجى تأكيد كلمة المرور الخاصة بك',
    },
    'passwordsDoNotMatch': {
      'en': 'Passwords do not match',
      'ar': 'كلمات المرور غير متطابقة',
    },
    'userNotFound': {
      'en': 'User not found',
      'ar': 'المستخدم غير موجود',
    },
    'wrongPassword': {
      'en': 'Wrong password',
      'ar': 'كلمة مرور خاطئة',
    },
    'emailInUse': {
      'en': 'Email is already in use',
      'ar': 'البريد الإلكتروني قيد الاستخدام بالفعل',
    },
    'authError': {
      'en': 'Authentication error',
      'ar': 'خطأ في المصادقة',
    },
    'recentLoginRequired': {
      'en': 'This operation requires recent authentication. Please log in again.',
      'ar': 'تتطلب هذه العملية مصادقة حديثة. يرجى تسجيل الدخول مرة أخرى.',
    },
    'nameUpdated': {
      'en': 'Name updated successfully',
      'ar': 'تم تحديث الاسم بنجاح',
    },
    'emailUpdated': {
      'en': 'Email updated successfully',
      'ar': 'تم تحديث البريد الإلكتروني بنجاح',
    },
    'passwordUpdated': {
      'en': 'Password updated successfully',
      'ar': 'تم تحديث كلمة المرور بنجاح',
    },
  };

  return texts[key]?[isArabic ? 'ar' : 'en'] ?? key;
}