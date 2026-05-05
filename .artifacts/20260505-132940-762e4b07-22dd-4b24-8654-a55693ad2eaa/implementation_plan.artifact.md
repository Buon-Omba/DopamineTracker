# Add Custom Mood and Activity

This task adds the ability for users to create and track custom Moods, Activities, and "Other" entries in the Home Screen.

## Proposed Changes

### Localization

Add new strings for the "Add Custom Item" dialog.

#### [app_it.arb](file:///C:/Users/AdminAkro/Current-projects/DopamineTracker/lib/l10n/app_it.arb)
- Add `addCustomItemTitle`: "Aggiungi voce personalizzata"
- Add `addCustomItemNameLabel`: "Nome"
- Add `addCustomItemCategoryLabel`: "Categoria"
- Add `categoryMood`: "Umore"
- Add `categoryActivity`: "Attività"
- Add `categoryOther`: "Altro"

#### [app_en.arb](file:///C:/Users/AdminAkro/Current-projects/DopamineTracker/lib/l10n/app_en.arb)
- Add `addCustomItemTitle`: "Add custom item"
- Add `addCustomItemNameLabel`: "Name"
- Add `addCustomItemCategoryLabel`: "Category"
- Add `categoryMood`: "Mood"
- Add `categoryActivity`: "Activity"
- Add `categoryOther`: "Other"

---

### Service Layer

Update `DailyLogService` to handle custom items persistence.

#### [daily_log_service.dart](file:///C:/Users/AdminAkro/Current-projects/DopamineTracker/lib/services/daily_log_service.dart)
- Add `static const _customItemsKey = 'customDailyLogItems_';`
- Add `static Future<void> addCustomItem(String category, String name)` to save custom items to `SharedPreferences`.
- Add `static Future<List<String>> getCustomItems(String category)` to retrieve saved custom items.

---

### UI Layer

Update `HomeScreen` to display and add custom items.

#### [home_screen.dart](file:///C:/Users/AdminAkro/Current-projects/DopamineTracker/lib/screens/home_screen.dart)
- Add state variables to store custom moods, activities, and others.
- Update `_initializeData` to fetch custom items.
- In the "Mood e Activity" section, append custom items to the list of displayed chips.
- Use a fallback emoji (e.g., '✨') for items not found in the predefined maps.
- Add an `ActionChip` with a "+" icon to open the custom item dialog.
- Implement `_showAddCustomItemDialog` to allow users to enter a name and select a category.

## Verification Plan

### Manual Verification
1. Open the app and navigate to the Home Screen.
2. Scroll to the "Mood e Activity" section.
3. Click the "+" button.
4. Enter a name (e.g., "Meditation") and select a category (e.g., "Activity").
5. Click "Save".
6. Verify that "Meditation" appears as a chip in the list.
7. Click the "Meditation" chip and verify it stays selected (and survives a reload).
8. Restart the app and verify that "Meditation" is still available as an option.
