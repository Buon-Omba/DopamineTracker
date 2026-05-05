# AppBar Layout Refinement

Centering the "Dopamine Tracker" title and aligning the addiction dropdown to the left edge to match the right edge's popup menu.

## Proposed Changes

### [main_screen.dart](file:///C:/Users/AdminAkro/Current-projects/DopamineTracker/lib/screens/main_screen.dart)

- Move the `DropdownButton` from the `title` to the `leading` slot of the `AppBar`.
- Use `centerTitle: true` to ensure the title text is perfectly centered.
- Adjust `leadingWidth` to accommodate the dropdown.
- Keep the `add` button and `popup` menu in `actions`.

```dart
appBar: AppBar(
  centerTitle: true,
  leadingWidth: 120, // Adjusted for dropdown
  leading: Padding(
    padding: const EdgeInsets.only(left: 16.0), // Matching standard padding
    child: _addictions.isNotEmpty ? DropdownButton<Addiction>(...) : null,
  ),
  title: const Text('Dopamine Tracker'),
  actions: [
    IconButton(icon: const Icon(Icons.add), ...),
    PopupMenuButton<String>(...),
  ],
)
```

## Verification Plan

### Manual Verification
- Verify title is centered.
- Verify dropdown is on the left.
- Verify "Add" and "Menu" icons are on the right.
- Check symmetry of padding on both sides.
