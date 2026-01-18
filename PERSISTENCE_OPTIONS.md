# Persistence Options for Saved Messages

## Current Implementation
Currently using `path_provider` with `getApplicationDocumentsDirectory()`, which stores data in:
- **iOS**: App's Documents directory (persists across app updates, but NOT across uninstalls)
- **Android**: App's internal storage (persists across app updates, but NOT across uninstalls)
- **Web**: Not currently supported (would need different implementation)

## Options for Cross-Platform Persistence

### Option 1: SharedPreferences / Hive (Local Storage)
**Pros:**
- Simple to implement
- Works on all platforms (iOS, Android, Web)
- Fast access
- Persists across app updates

**Cons:**
- **Does NOT persist across uninstalls** (data is deleted when app is uninstalled)
- Limited storage size (typically a few MB)
- Not ideal for large datasets

**Implementation:**
- Use `shared_preferences` package for simple key-value storage
- Or `hive` package for more structured data with better performance

### Option 2: Cloud Storage (Firebase, Supabase, etc.)
**Pros:**
- **Persists across install/uninstall cycles** (data stored in cloud)
- Accessible from any device
- Can sync across multiple devices
- Scalable

**Cons:**
- Requires internet connection
- Requires user authentication (or anonymous auth)
- More complex setup
- Potential privacy concerns
- May have costs at scale

**Implementation:**
- Firebase Firestore (Google)
- Supabase (open-source Firebase alternative)
- AWS Amplify
- Custom backend API

### Option 3: Browser LocalStorage / IndexedDB (Web-First)
**Pros:**
- **Persists across sessions** (even if browser cache is cleared, depends on settings)
- Works offline
- No backend required
- Good for web-first approach

**Cons:**
- **Can be cleared by user** (browser settings, private mode, etc.)
- **Does NOT persist across different browsers/devices**
- Storage limits (5-10MB typically)
- Not ideal for mobile apps (would need different solution)

**Implementation:**
- Use `shared_preferences` with web support (uses localStorage)
- Or direct `dart:html` localStorage/IndexedDB for web

### Option 4: Export/Import Feature
**Pros:**
- User controls their data
- Can backup/restore manually
- Works across all platforms
- No backend required

**Cons:**
- Requires manual user action
- Not automatic
- User must remember to export

**Implementation:**
- Export to JSON file
- Share via email/cloud storage
- Import from file

### Option 5: Hybrid Approach (Recommended for Web-First)
**For Web (GitHub Pages):**
- Use **localStorage/IndexedDB** via `shared_preferences` package
- Data persists in browser across sessions
- Can add export/import feature for backup

**For Mobile (if needed later):**
- Use cloud storage (Firebase/Supabase) for cross-device sync
- Or keep local storage with export/import

## Recommendation for Web-First Approach

Since the priority is now **web deployment on GitHub Pages**, I recommend:

1. **Primary**: Use `shared_preferences` package (works on web via localStorage)
   - Persists across browser sessions
   - Simple implementation
   - No backend required

2. **Backup**: Add export/import feature
   - Export messages as JSON file
   - User can download and re-import
   - Provides manual backup option

3. **Future**: If cloud sync is needed later, add Firebase/Supabase integration

## Implementation Notes

The current `LocalStorage` class uses `path_provider` which doesn't work on web. For web support, we'd need to:

1. Use `shared_preferences` package instead
2. Or create a platform-specific implementation:
   - Web: Use `dart:html` localStorage
   - Mobile: Use `path_provider` (current implementation)

The `shared_preferences` package automatically handles this platform difference.


