# 🗂️ تقرير الملفات غير المستخدمة في المشروع

## 📁 ملفات التوثيق الزائدة (يمكن حذفها)

### ملفات التوثيق المكررة:
- `BACKUP_INFO.md`
- `CART_ICON_COMPLETION_SUMMARY.md`
- `CART_ICON_UPDATE.md`
- `CATEGORIES_FINAL_UPDATE.md`
- `CATEGORIES_UPDATE_COMPLETE.md`
- `CATEGORY_IMAGES_IN_RESULTS_COMPLETE.md`
- `CATEGORY_IMAGES_IN_RESULTS_UPDATE.md`
- `CATEGORY_IMAGES_OPTIMIZATION_GUIDE.md`
- `CATEGORY_SIZE_FINAL_UPDATE.md`
- `CATEGORY_SIZE_UPDATE.md`
- `CATEGORY_TESTING_GUIDE.md`
- `CATEGORY_UPDATES.md`
- `COMPLETE_CATEGORIES_PROJECT_FINAL.md`
- `COUPONS_TAB_OVERFLOW_FIX.md`
- `ENHANCED_CATEGORIES_UPDATE.md`
- `FILTER_MODAL_COMPLETE.md`
- `FINAL_CATEGORIES_ENHANCEMENT.md`
- `FINAL_POINTS_SYSTEM_REPORT.md`
- `IMPLEMENTATION_COMPLETE.md`
- `OVERFLOW_ISSUE_RESOLUTION_SUMMARY.md`
- `POINTS_TESTING_GUIDE.md`
- `PROJECT_COMPLETE_BACKUP.md`
- `PROJECT_COMPLETION_SUMMARY.md`
- `REWARDS_COUPONS_README.md`
- `REWARDS_ENHANCEMENT_SUMMARY.md`
- `SEARCH_BACKEND_INTEGRATION.md`
- `SEARCH_IMPROVEMENTS_FINAL_REPORT.md`
- `SEARCH_OVERFLOW_FIX.md`
- `SPACING_REDUCTION_COMPLETE.md`
- `TESTING_PLAN.md`
- `TESTING_RESULTS.md`

## 🐍 ملفات Python للتطوير (يمكن حذفها):
- `convert_svg.py`
- `create_filter_icons.py`
- `create_icons.py`
- `fix_issues.py`
- `generate_category_images.py`
- `optimize_category_images.py`

## 📱 ملفات Dart القديمة/المكررة:

### في مجلد lib/screens:
- `account_screen_new.dart` (مكرر مع `account_screen.dart`)
- `coupons_screen_fixed.dart` (مكرر مع `coupons_screen.dart`)
- `coupons_screen_new.dart` (مكرر مع `coupons_screen.dart`)
- `enhanced_search_screen_updated.dart` (مكرر مع `enhanced_search_screen.dart`)
- `favorites_screen.dart.old` (نسخة قديمة)
- `home_screen.dart.old` (نسخة قديمة)
- `home_screen_backup.dart` (نسخة احتياطية)
- `home_screen_restored.dart` (نسخة مستعادة)
- `home_screen_updated.dart` (مكرر مع `home_screen.dart`)
- `map_screen.dart.old` (نسخة قديمة)
- `map_screen_updated.dart` (محدث)
- `rewards_screen_new.dart` (مكرر مع `rewards_screen.dart`)
- `search_screen.dart.old` (نسخة قديمة)
- `store_detail_screen_updated.dart` (مكرر مع `store_detail_screen.dart`)

### ملفات الاختبار القديمة:
- `test_filter_functionality.dart`
- `test_filter_logic.dart`
- `test_home.dart`
- `test_images.dart`
- `test_import.dart`
- `test_search.dart`

## ✅ ملفات يجب الاحتفاظ بها:

### الملفات الأساسية:
- `lib/main.dart` ✅
- `lib/mock_data.dart` ✅
- `lib/models/` ✅
- `lib/services/` ✅
- `lib/widgets/` ✅
- `README.md` ✅
- `pubspec.yaml` ✅
- `analysis_options.yaml` ✅

### ملفات الشاشات الرئيسية:
- `lib/screens/account_screen.dart` ✅
- `lib/screens/address_edit_sheet.dart` ✅
- `lib/screens/card_payment_screen.dart` ✅
- `lib/screens/cart_screen.dart` ✅
- `lib/screens/coming_soon_screen.dart` ✅
- `lib/screens/coupons_screen.dart` ✅
- `lib/screens/dish_detail_screen.dart` ✅
- `lib/screens/enhanced_search_screen.dart` ✅
- `lib/screens/favorites_screen_updated.dart` ✅
- `lib/screens/home_screen.dart` ✅
- `lib/screens/intro_screen.dart` ✅
- `lib/screens/login_screen.dart` ✅
- `lib/screens/map_screen_updated.dart` ✅
- `lib/screens/order_confirmation_screen.dart` ✅
- `lib/screens/orders_screen.dart` ✅
- `lib/screens/rewards_coupons_section.dart` ✅
- `lib/screens/rewards_screen.dart` ✅
- `lib/screens/signup_screen.dart` ✅
- `lib/screens/store_detail_screen.dart` ✅
- `lib/screens/welcome_screen.dart` ✅

### ملفات الاختبار الأساسية:
- `test/categories_test.dart` ✅
- `test/search_test.dart` ✅
- `test/widget_test.dart` ✅

## 🧹 خطة التنظيف المقترحة:

### المرحلة 1: حذف ملفات التوثيق الزائدة (33 ملف)
```bash
# حذف جميع ملفات .md الزائدة
rm BACKUP_INFO.md CART_ICON_*.md CATEGORIES_*.md CATEGORY_*.md
rm COMPLETE_*.md COUPONS_*.md ENHANCED_*.md FILTER_*.md
rm FINAL_*.md IMPLEMENTATION_*.md OVERFLOW_*.md POINTS_*.md
rm PROJECT_*.md REWARDS_*.md SEARCH_*.md SPACING_*.md TESTING_*.md
```

### المرحلة 2: حذف ملفات Python (6 ملفات)
```bash
rm *.py
```

### المرحلة 3: حذف ملفات Dart القديمة (14 ملف)
```bash
cd lib/screens
rm *_new.dart *_old.dart *_backup.dart *_restored.dart
rm *_fixed.dart *_updated.dart
cd ../../
rm test_*.dart
```

## 📊 إحصائيات التنظيف:
- **ملفات التوثيق**: 33 ملف
- **ملفات Python**: 6 ملفات  
- **ملفات Dart القديمة**: 14 ملف
- **المجموع**: 53 ملف يمكن حذفه

## 💾 مساحة التخزين المتوقع توفيرها:
- تقريباً **2-5 MB** من ملفات التوثيق
- تقريباً **1-2 MB** من ملفات الكود القديمة
- **المجموع**: حوالي 3-7 MB

## ⚠️ تحذيرات:
1. **قم بعمل backup** قبل الحذف
2. **تأكد من عدم وجود references** لهذه الملفات
3. **احتفظ بـ Git history** للرجوع إذا احتجت

---
**التوصية**: ابدأ بحذف ملفات التوثيق أولاً، ثم ملفات Python، وأخيراً ملفات Dart القديمة.
