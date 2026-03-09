# মেস হিসাব ট্র্যাকার — Complete Application Documentation

> **Version:** 1.0.0
> **Platform:** Android (Flutter)
> **Language:** Dart · Framework: Flutter 3.x
> **Database:** SQLite (local, offline-first)
> **Last Updated:** March 2026

---

## Table of Contents

1. [Application Overview](#1-application-overview)
2. [Core Features](#2-core-features)
3. [Technology Stack](#3-technology-stack)
4. [Project Structure](#4-project-structure)
5. [Architecture & Design Patterns](#5-architecture--design-patterns)
6. [Database Schema](#6-database-schema)
7. [Authentication System](#7-authentication-system)
8. [Screens & User Interface](#8-screens--user-interface)
9. [Data Models](#9-data-models)
10. [Providers (State Management)](#10-providers-state-management)
11. [Services](#11-services)
12. [Theme & Design System](#12-theme--design-system)
13. [Business Logic & Calculations](#13-business-logic--calculations)
14. [Chat System](#14-chat-system)
15. [Getting Started](#15-getting-started)
16. [Build & Deployment](#16-build--deployment)
17. [Configuration](#17-configuration)
18. [Known Limitations](#18-known-limitations)

---

## 1. Application Overview

**মেস হিসাব ট্র্যাকার** (Mess Hisab Tracker) is a fully offline, Bengali-localized Flutter application designed for managing shared mess (communal dining hall) accounting in Bangladesh. It handles the complete financial lifecycle of a mess — from tracking daily market expenses and member meal counts to generating monthly settlement reports.

### Who It's For

| Role | Description |
|------|-------------|
| **Manager (ম্যানেজার)** | Creates and administers the mess. Has full control over all data, can start new months, manage members, and send reports. |
| **Member (সদস্য)** | Joins using a mess code provided by the manager. Can view their own balance, participate in chat, and track meals. |

### Key Design Principles

- **100% Offline** — All data stored locally in SQLite. No internet required for core functionality.
- **Single-Device Shared App** — Designed to run on one shared device (or identically configured devices).
- **Bengali-First** — All UI text, labels, and month names are in Bengali.
- **Vibrant UI** — Gradient-heavy, colorful Material Design 3 interface.

---

## 2. Core Features

### 2.1 Authentication
- Manager creates a mess with a unique **Mess Code** and password
- Members join by providing: name, phone, email, and the mess code
- Session persisted across app restarts via `SharedPreferences`
- Manager-only controls (new month, manage members) are gated by auth status

### 2.2 Mess Month Management
- Track expenses month-by-month with explicit start/end dates
- Only one month can be **active** at a time
- Manager can close the current month and start a new one
- All historical months are accessible for reporting

### 2.3 Daily Market Expense (দৈনিক বাজার)
- Add expenses as **itemized lists** — multiple items with individual prices per shopping trip
- Auto-calculates total from all items
- Records who bought the items
- Expandable cards show full item breakdown
- Swipe to edit or delete any expense entry

### 2.4 Member Management
- Add members with: name, phone number, email
- Soft-delete (deactivate) members — data is preserved
- Members who joined via join screen are automatically added
- All members visible in list with active/inactive status

### 2.5 Meal Tracking (মিল ট্র্যাকার)
- Toggle breakfast, lunch, dinner for each member per day
- Navigate by day with arrow buttons or date picker
- Meal unit weights:
  - Breakfast = **0.5 units**
  - Lunch = **1.0 unit**
  - Dinner = **1.0 unit**
- Default state for new records: lunch ✓, dinner ✓, breakfast ✗

### 2.6 Deposit Tracking (জমা)
- Record cash deposits from members
- Select member from dropdown, enter amount, optional note
- Full history per active month
- Swipe to delete

### 2.7 Monthly Report (মাসিক রিপোর্ট)
- Per-member settlement table showing:
  - Total meal units consumed
  - Total deposit amount
  - Calculated meal cost (units × meal rate)
  - Final balance (positive = refund due, negative = owes money)
- Meal rate auto-calculated: `totalExpenses ÷ totalMealUnits`
- Export as **PDF** (shareable) or **Excel** (.xlsx)
- Email report with PDF + Excel attachments via Gmail SMTP

### 2.8 Group Chat (গ্রুপ চ্যাট)
- All mess members can message in a shared group channel
- Messages stored locally in SQLite
- Auto-refreshes every 2 seconds for near real-time feel
- Message bubbles show sender name, timestamp
- Long-press own messages to delete

### 2.9 Private 1:1 Chat
- Direct messaging between any two mess members
- Separate conversation threads per pair
- Color-coded per person for visual clarity
- Double-tick indicator on sent messages

### 2.10 Backup & Restore
- Export entire SQLite database as a `.db` file (share via any app)
- Import `.db` file to restore data
- Useful for transferring data between devices

### 2.11 Email Integration
- Configure Gmail SMTP credentials in Settings
- Send monthly reports (PDF + Excel) to a list of recipients
- Test email functionality to verify configuration

---

## 3. Technology Stack

| Category | Package | Version | Purpose |
|----------|---------|---------|---------|
| Framework | `flutter` | 3.x | UI framework |
| Language | `dart` | ≥3.0.0 | Programming language |
| State Management | `flutter_riverpod` | ^2.4.9 | Reactive state management |
| Database | `sqflite` | ^2.3.2 | SQLite for local storage |
| Path | `path` | ^1.9.0 | File path manipulation |
| File Storage | `path_provider` | ^2.1.2 | App documents directory |
| File Picker | `file_picker` | ^10.0.0 | Import backup files |
| Sharing | `share_plus` | ^10.0.0 | Export/share files |
| PDF | `pdf` | ^3.10.8 | Generate PDF reports |
| PDF Preview | `printing` | ^5.11.3 | Share PDF files |
| Excel | `excel` | ^4.0.3 | Generate Excel reports |
| Email | `mailer` | ^6.1.0 | Gmail SMTP email sending |
| Fonts | `google_fonts` | ^6.1.0 | Nunito font family |
| Charts | `fl_chart` | ^0.66.2 | Chart rendering (future use) |
| Internationalization | `intl` | ^0.19.0 | Date formatting |
| Swipe Actions | `flutter_slidable` | ^3.0.1 | Swipe-to-edit/delete |
| Spacing | `gap` | ^3.0.1 | Consistent spacing widget |
| Icons | `iconsax` | ^0.0.8 | Extended icon set |
| UUID | `uuid` | ^4.3.3 | Unique ID generation |
| Preferences | `shared_preferences` | ^2.2.2 | Persist auth session |

---

## 4. Project Structure

```
mess_hisab_tracker/
├── lib/
│   ├── main.dart                        # App entry point, MainShell (bottom nav)
│   │
│   ├── theme/
│   │   └── app_theme.dart               # AppColors, AppTheme, gradient definitions
│   │
│   ├── database/
│   │   └── db_helper.dart               # Singleton SQLite helper, all DB operations
│   │
│   ├── models/
│   │   ├── member.dart                  # Member data class
│   │   ├── expense.dart                 # Expense (shopping trip) data class
│   │   ├── expense_item.dart            # Individual item within an expense
│   │   ├── deposit.dart                 # Member deposit data class
│   │   ├── meal.dart                    # Daily meal record data class
│   │   ├── mess_month.dart              # Billing period data class
│   │   └── chat_message.dart            # Chat message data class
│   │
│   ├── providers/
│   │   ├── db_provider.dart             # DBHelper singleton provider
│   │   ├── auth_provider.dart           # Authentication state & logic
│   │   ├── member_provider.dart         # Member CRUD state
│   │   ├── expense_provider.dart        # Expense CRUD + items state
│   │   ├── deposit_provider.dart        # Deposit CRUD state
│   │   ├── meal_provider.dart           # Meal toggle state (per date)
│   │   ├── mess_month_provider.dart     # Mess month list & active month
│   │   ├── report_provider.dart         # Monthly report calculation
│   │   └── chat_provider.dart           # Group & private chat state
│   │
│   ├── screens/
│   │   ├── splash_screen.dart           # Auth-checking splash
│   │   ├── welcome_screen.dart          # Manager vs Member choice
│   │   ├── setup_screen.dart            # First-time mess creation
│   │   ├── login_screen.dart            # Manager password login
│   │   ├── join_screen.dart             # Member joining with mess code
│   │   ├── dashboard_screen.dart        # Overview, stats, member balances
│   │   ├── members_screen.dart          # Member list management
│   │   ├── expense_screen.dart          # Daily market expenses (multi-item)
│   │   ├── deposit_screen.dart          # Member deposits
│   │   ├── meal_toggle_screen.dart      # Daily meal tracking
│   │   ├── report_screen.dart           # Monthly settlement report
│   │   ├── settings_screen.dart         # App config, backup, email, logout
│   │   ├── chat_hub_screen.dart         # Chat list (group + 1:1 overview)
│   │   ├── group_chat_screen.dart       # Group chat conversation
│   │   └── private_chat_screen.dart     # 1:1 private chat conversation
│   │
│   ├── services/
│   │   ├── report_service.dart          # PDF & Excel generation
│   │   ├── backup_service.dart          # DB export/import
│   │   └── email_service.dart           # Gmail SMTP email sending
│   │
│   └── widgets/
│       └── common_widgets.dart          # Shared UI components
│
├── test/
│   ├── calculation_test.dart            # Business logic unit tests
│   └── widget_test.dart                 # Widget tests
│
├── pubspec.yaml                         # Dependencies & metadata
├── DOCUMENTATION.md                     # This file
└── android/                             # Android platform config
```

---

## 5. Architecture & Design Patterns

### 5.1 Overall Architecture

The app follows a **layered architecture**:

```
UI (Screens & Widgets)
        ↕
State Management (Riverpod Providers)
        ↕
Data Layer (DBHelper)
        ↕
SQLite Database
```

### 5.2 State Management — Riverpod

All state is managed via **Flutter Riverpod 2.x**. Three provider types are used:

| Provider Type | Used For | Example |
|---------------|----------|---------|
| `NotifierProvider` | Mutable state with actions (CRUD) | `memberNotifierProvider` |
| `NotifierProviderFamily` | Same but parameterized by an argument | `expenseNotifierProvider(monthId)` |
| `FutureProvider` | Simple read-only async data | `activeMemberListProvider` |
| `FutureProvider.family` | Parameterized read-only async | `expenseItemsProvider(expenseId)` |

### 5.3 Data Flow

```
User Action
    → Screen Widget calls Notifier method
        → Notifier calls DBHelper
            → DBHelper executes SQL
                → Notifier reloads state
                    → UI rebuilds automatically
```

### 5.4 Database Pattern

- **Singleton pattern** for `DBHelper` — one instance shared across the app via `dbHelperProvider`
- **UPSERT** used for meal records (conflict resolution on `member_id + date`)
- **Soft delete** for members — `is_active = 0` instead of physical deletion
- **Cascading delete** for expense items when an expense is deleted
- **Transactions** used for multi-table writes (expense + items)

### 5.5 Navigation

- **Bottom Navigation Bar** with 8 tabs (IndexedStack — screens stay alive)
- **Auth screens** use full-page replacement (`pushAndRemoveUntil`)
- **Chat screens** use slide transition push/pop navigation

### 5.6 Polling Strategy for Chat

Since the app is local (no WebSocket/Firebase), chat uses a **2-second periodic timer** inside each chat Notifier to refresh messages. This gives a "near real-time" feel without a backend.

```dart
_timer = Timer.periodic(const Duration(seconds: 2), (_) => _load());
```

---

## 6. Database Schema

**Database file:** `mess_hisab.db`
**Current version:** 3
**Location:** App documents directory (SQLite default path)

### Table: `mess_months`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique identifier |
| `year` | INTEGER | NOT NULL | Calendar year (e.g. 2026) |
| `month` | INTEGER | NOT NULL | Calendar month (1–12) |
| `is_active` | INTEGER | NOT NULL, DEFAULT 1 | 1 = active, 0 = closed |
| `start_date` | TEXT | NOT NULL | ISO date string (YYYY-MM-DD) |
| `end_date` | TEXT | NULL | Set when month is closed |

**Business rule:** Only one row may have `is_active = 1` at any time.

---

### Table: `members`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique identifier |
| `name` | TEXT | NOT NULL | Full name |
| `phone` | TEXT | NULL | Phone number |
| `email` | TEXT | NULL | Email address |
| `join_date` | TEXT | NOT NULL | ISO date string |
| `is_active` | INTEGER | NOT NULL, DEFAULT 1 | Soft-delete flag |

---

### Table: `expenses`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique identifier |
| `amount` | REAL | NOT NULL | Total cost (sum of all items) |
| `description` | TEXT | NOT NULL | Auto-generated from item names |
| `date` | TEXT | NOT NULL | Purchase date (YYYY-MM-DD) |
| `added_by` | TEXT | NOT NULL | Who made the purchase |
| `mess_month_id` | INTEGER | NOT NULL, FK → mess_months | Billing period |

---

### Table: `expense_items`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique identifier |
| `expense_id` | INTEGER | NOT NULL, FK → expenses (CASCADE DELETE) | Parent expense |
| `item_name` | TEXT | NOT NULL | Product name (e.g. "চাল", "তেল") |
| `price` | REAL | NOT NULL | Individual item price |

**Note:** When an expense is deleted, all its items are automatically deleted via `ON DELETE CASCADE`.

---

### Table: `deposits`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique identifier |
| `member_id` | INTEGER | NOT NULL, FK → members | Which member paid |
| `amount` | REAL | NOT NULL | Amount deposited (BDT) |
| `date` | TEXT | NOT NULL | Payment date (YYYY-MM-DD) |
| `note` | TEXT | NULL | Optional payment note |
| `mess_month_id` | INTEGER | NOT NULL, FK → mess_months | Billing period |

---

### Table: `meals`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique identifier |
| `member_id` | INTEGER | NOT NULL, FK → members | Which member |
| `date` | TEXT | NOT NULL | Date (YYYY-MM-DD) |
| `breakfast` | INTEGER | NOT NULL, DEFAULT 0 | 0 or 1 |
| `lunch` | INTEGER | NOT NULL, DEFAULT 1 | 0 or 1 |
| `dinner` | INTEGER | NOT NULL, DEFAULT 1 | 0 or 1 |
| — | — | UNIQUE(member_id, date) | One record per member per day |

**Insert strategy:** UPSERT with `ConflictAlgorithm.replace` — toggling a meal writes the entire row.

---

### Table: `app_config`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `key` | TEXT | PRIMARY KEY | Config key name |
| `value` | TEXT | NOT NULL | Config value |

**Stored keys:**

| Key | Value |
|-----|-------|
| `manager_name` | Manager's full name |
| `mess_name` | Name of the mess |
| `mess_code` | Code members use to join |
| `manager_password` | Plain-text password (local only) |

---

### Table: `chat_messages`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PK, AUTOINCREMENT | Unique identifier |
| `sender_name` | TEXT | NOT NULL | Sender's display name |
| `message` | TEXT | NOT NULL | Message text content |
| `timestamp` | TEXT | NOT NULL | ISO 8601 datetime |
| `chat_type` | TEXT | NOT NULL, DEFAULT 'group' | `'group'` or `'private'` |
| `receiver_name` | TEXT | NOT NULL, DEFAULT '' | For private chats only |

---

### Database Migrations

| Version | Changes |
|---------|---------|
| **v1** | Initial schema: mess_months, members, expenses, deposits, meals |
| **v2** | Added `email` column to members; added `expense_items` table; added `app_config` table |
| **v3** | Added `chat_messages` table |

---

## 7. Authentication System

### 7.1 Flow Diagram

```
App Launch
    ↓
SplashScreen
    ↓ checks SharedPreferences
    ├── is_logged_in = false → WelcomeScreen
    │       ├── Manager (setup done?)
    │       │       ├── YES → LoginScreen (password entry)
    │       │       └── NO  → SetupScreen (create mess)
    │       └── Member → JoinScreen (mess code + personal info)
    │
    └── is_logged_in = true → MainShell (direct to home)
```

### 7.2 Manager Setup (First Time)

**Screen:** `SetupScreen`
**Fields required:**
- Manager name
- Mess name
- Mess code (minimum 4 characters — shared with members)
- Password (minimum 4 characters)
- Confirm password

**What happens:**
1. All config saved to `app_config` table in SQLite
2. `SharedPreferences` sets `is_logged_in = true`, `user_type = manager`
3. App navigates to `MainShell`

### 7.3 Manager Login (Returning)

**Screen:** `LoginScreen`
**Field required:** Password only

**What happens:**
1. Password compared against `app_config['manager_password']`
2. On match → session saved to `SharedPreferences` → `MainShell`
3. On mismatch → error snackbar shown

### 7.4 Member Join

**Screen:** `JoinScreen`
**Fields required:**
- Full name
- Phone number
- Email address
- Mess code

**What happens:**
1. Mess code verified against `app_config['mess_code']`
2. On match → new row inserted into `members` table
3. Session saved (`user_type = member`) → `MainShell`
4. On mismatch → "মেস কোড ভুল" error shown

### 7.5 Auth State Object

```dart
class AuthState {
  final AuthStatus status;   // unknown | unauthenticated | manager | member
  final String? userName;    // displayed in dashboard & settings
  final String? messName;    // displayed in dashboard header
}
```

### 7.6 Logout

Available in **Settings** screen. Clears `is_logged_in` from `SharedPreferences` and navigates to `WelcomeScreen`.

---

## 8. Screens & User Interface

### 8.1 Navigation Structure

```
MainShell (IndexedStack — 8 tabs)
├── [0] DashboardScreen
├── [1] MembersScreen
├── [2] ExpenseScreen
├── [3] MealToggleScreen
├── [4] DepositScreen
├── [5] ChatHubScreen
│       ├── GroupChatScreen (push)
│       └── PrivateChatScreen (push)
├── [6] ReportScreen
└── [7] SettingsScreen
```

---

### 8.2 SplashScreen

**File:** `screens/splash_screen.dart`

- Animated logo with scale + fade-in (Elastic curve, 1.2s)
- Watches `authProvider` for state change
- Navigates to `WelcomeScreen` (unauthenticated) or `MainShell` (authenticated)
- Uses fade page transition

---

### 8.3 WelcomeScreen

**File:** `screens/welcome_screen.dart`

- Checks `isSetupDoneProvider` to determine if mess exists
- **Manager card:** routes to `LoginScreen` (if setup done) or `SetupScreen` (new)
- **Member card:** always routes to `JoinScreen`
- Feature badges at bottom (decorative)

---

### 8.4 SetupScreen

**File:** `screens/setup_screen.dart`

- Gradient form fields (each with colored icon prefix)
- Password confirmation validation
- Calls `authProvider.notifier.setupMess(...)`

---

### 8.5 LoginScreen

**File:** `screens/login_screen.dart`

- Single password field with show/hide toggle
- Calls `authProvider.notifier.loginManager(password: ...)`

---

### 8.6 JoinScreen

**File:** `screens/join_screen.dart`

- 4 fields: name, phone (phone keyboard), email (email keyboard), mess code
- Calls `authProvider.notifier.joinMess(...)`
- Creates member record on success

---

### 8.7 DashboardScreen

**File:** `screens/dashboard_screen.dart`

**Components:**
- **SliverAppBar** with purple-pink gradient, shows mess name and current user
- **"New Month" button** — only shown if `auth.status == AuthStatus.manager`
- **4 stat cards** — total expenses, meal rate, total meals, member count
- **Member balance list** — each member shown with gradient avatar, balance chip (green = refund, orange/pink = owes)
- **Pull-to-refresh** invalidates both `activeMessMonthProvider` and `monthlyReportProvider`

**New Month Dialog:**
- Year + month dropdowns
- Closes current active month (sets `end_date`, `is_active = 0`)
- Creates new `MessMonth` record

---

### 8.8 MembersScreen

**File:** `screens/members_screen.dart`

- Purple-pink gradient SliverAppBar
- Cards show name, phone, email, active/inactive badge
- **Swipe left** reveals: Edit (blue) | Deactivate (red)
- **Add Member** bottom sheet with name, phone, email fields
- Member avatar color is deterministic (based on first character of name)

---

### 8.9 ExpenseScreen (দৈনিক বাজার)

**File:** `screens/expense_screen.dart`

**Main list:**
- Orange-yellow gradient SliverAppBar showing total expenses
- Expandable cards — tap to reveal item breakdown (bullet dots with prices)
- Swipe left to edit or delete

**Add/Edit Bottom Sheet (`_ExpenseBottomSheet`):**
- "Who bought" text field
- **Items section** with dynamic rows — each row has:
  - Item name field
  - Price field (number keyboard)
  - Remove button (if more than 1 item)
- **"+ Add Item"** button adds a new row
- Running total shown live in header and submit button
- Saves all items atomically in a DB transaction

---

### 8.10 MealToggleScreen

**File:** `screens/meal_toggle_screen.dart`

- Orange-yellow gradient SliverAppBar
- **Date navigator** — left/right arrows + tap to open date picker
- Cannot navigate to future dates
- Per-member cards with 3 animated toggles: 🌅 সকাল | ☀️ দুপুর | 🌙 রাত
- Toggle state shown with color and emoji
- Saves immediately on tap (UPSERT to DB)

---

### 8.11 DepositScreen

**File:** `screens/deposit_screen.dart`

- Green-teal gradient SliverAppBar
- Deposit cards show member avatar, name, date, note, amount badge
- Swipe left to delete
- **Add Deposit** bottom sheet: member dropdown, amount, note

---

### 8.12 ChatHubScreen

**File:** `screens/chat_hub_screen.dart`

- Indigo-purple gradient SliverAppBar
- **Group chat tile** — full-width gradient card with last message preview
- **Member list** for 1:1 chats — colored avatars, last message preview + time
- Hides current user from the 1:1 list (`m.name != myName`)
- Slide-in page transition to chat screens

---

### 8.13 GroupChatScreen

**File:** `screens/group_chat_screen.dart`

- Indigo-purple gradient AppBar
- Message list with `ListView.builder` + auto-scroll to bottom
- **Own messages:** right-aligned, purple gradient bubble, no sender name
- **Others' messages:** left-aligned, white bubble, sender name shown (color-coded)
- Long-press own message → delete dialog
- Input bar at bottom with expandable text field (max 4 lines)

---

### 8.14 PrivateChatScreen

**File:** `screens/private_chat_screen.dart`

- AppBar color dynamically set to the other person's unique color
- Same bubble layout as group chat
- Double-tick ✓✓ indicator on sent messages
- Message list auto-scrolls to bottom

---

### 8.15 ReportScreen

**File:** `screens/report_screen.dart`

- Teal-blue gradient SliverAppBar
- Month selector dropdown (loads all historical months)
- 2 stat cards: total expenses, meal rate
- Settlement table with colored header (teal gradient)
- Alternating row colors for readability
- Balance chips: green (positive) / red (negative)
- **PDF** and **Excel** export buttons with gradient styling

---

### 8.16 SettingsScreen

**File:** `screens/settings_screen.dart`

- Purple-pink gradient SliverAppBar
- **User info card** — shows current user name, role emoji, mess name
- **Backup section:** Export DB | Import DB (with confirmation dialog)
- **Email section:** Sender email, app password, recipients (comma-separated)
- **Send Report button:** Sends active month's PDF + Excel via email
- **Logout button** (outlined, red) — clears session, navigates to WelcomeScreen

---

## 9. Data Models

### Member

```dart
class Member {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String joinDate;    // YYYY-MM-DD
  final bool isActive;      // false = soft-deleted
}
```

### Expense

```dart
class Expense {
  final int? id;
  final double amount;        // Sum of all items
  final String description;   // Comma-joined item names
  final String date;          // YYYY-MM-DD
  final String addedBy;       // Buyer's name
  final int messMonthId;
}
```

### ExpenseItem

```dart
class ExpenseItem {
  final int? id;
  final int expenseId;
  final String itemName;   // e.g. "চাল", "ডাল", "তেল"
  final double price;
}
```

### Deposit

```dart
class Deposit {
  final int? id;
  final int memberId;
  final double amount;
  final String date;        // YYYY-MM-DD
  final String note;
  final int messMonthId;
}
```

### Meal

```dart
class Meal {
  final int? id;
  final int memberId;
  final String date;        // YYYY-MM-DD
  final bool breakfast;     // Weight: 0.5 units
  final bool lunch;         // Weight: 1.0 units
  final bool dinner;        // Weight: 1.0 units

  double get totalUnits =>
      (breakfast ? 0.5 : 0.0) + (lunch ? 1.0 : 0.0) + (dinner ? 1.0 : 0.0);
}
```

### MessMonth

```dart
class MessMonth {
  final int? id;
  final int year;
  final int month;
  final bool isActive;
  final String startDate;   // YYYY-MM-DD
  final String? endDate;    // Set when closed

  String get label;         // Bengali month name + year, e.g. "মার্চ 2026"
}
```

### ChatMessage

```dart
class ChatMessage {
  final int? id;
  final String senderName;
  final String message;
  final String timestamp;      // ISO 8601 full datetime
  final String chatType;       // 'group' or 'private'
  final String? receiverName;  // Only for private messages
}
```

### AuthState

```dart
enum AuthStatus { unknown, unauthenticated, manager, member }

class AuthState {
  final AuthStatus status;
  final String? userName;
  final String? messName;
}
```

---

## 10. Providers (State Management)

### db_provider.dart

```dart
final dbHelperProvider = Provider<DBHelper>((ref) => DBHelper());
```
Exposes the singleton `DBHelper` to all providers.

---

### auth_provider.dart

| Provider | Type | Description |
|----------|------|-------------|
| `authProvider` | `NotifierProvider<AuthNotifier, AuthState>` | Auth state + login/logout/setup actions |
| `isSetupDoneProvider` | `FutureProvider<bool>` | Whether manager has set up the mess |

**AuthNotifier methods:**
- `setupMess(...)` — first-time mess creation
- `loginManager(password)` — password verification & session creation
- `joinMess(name, phone, email, messCode)` — member registration
- `logout()` — clear session

---

### member_provider.dart

| Provider | Type | Description |
|----------|------|-------------|
| `memberNotifierProvider` | `NotifierProvider` | Full member list with CRUD |
| `memberListProvider` | `FutureProvider` | All members (active + inactive) |
| `activeMemberListProvider` | `FutureProvider` | Active members only |

**MemberNotifier methods:** `addMember`, `updateMember`, `deactivateMember`, `refresh`

---

### expense_provider.dart

| Provider | Type | Description |
|----------|------|-------------|
| `expenseNotifierProvider(monthId)` | `NotifierProviderFamily` | Expense list + CRUD per month |
| `totalExpensesProvider(monthId)` | `FutureProvider.family` | Sum of expenses for a month |
| `expenseItemsProvider(expenseId)` | `FutureProvider.family` | Items for a specific expense |

**ExpenseNotifier methods:** `addExpense`, `addExpenseWithItems`, `updateExpense`, `updateExpenseWithItems`, `deleteExpense`, `refresh`

---

### deposit_provider.dart

| Provider | Type | Description |
|----------|------|-------------|
| `depositNotifierProvider(monthId)` | `NotifierProviderFamily` | Deposit list + CRUD per month |

**DepositNotifier methods:** `addDeposit`, `deleteDeposit`, `refresh`

---

### meal_provider.dart

| Provider | Type | Description |
|----------|------|-------------|
| `mealNotifierProvider(dateString)` | `NotifierProviderFamily` | Meals for a specific date |

**MealNotifier methods:** `upsertMeal` (creates or updates)

---

### mess_month_provider.dart

| Provider | Type | Description |
|----------|------|-------------|
| `messMonthListProvider` | `FutureProvider` | All mess months, newest first |
| `activeMessMonthProvider` | `FutureProvider` | Currently active month (or null) |

---

### report_provider.dart

| Provider | Type | Description |
|----------|------|-------------|
| `monthlyReportProvider(monthId)` | `FutureProvider.family` | Full settlement report for a month |

Returns a `MonthlyReport` containing:
- `totalExpenses` — double
- `totalMealUnits` — double
- `mealRate` — double
- `summaries` — `List<MemberSummary>` (one per member)

`MemberSummary` contains: `member`, `totalDeposit`, `totalMealUnits`, `mealCost`, `balance`

---

### chat_provider.dart

| Provider | Type | Description |
|----------|------|-------------|
| `groupChatProvider` | `NotifierProvider` | Group messages, auto-refresh every 2s |
| `privateChatProvider(key)` | `NotifierProviderFamily` | Private messages for a user pair |
| `lastGroupMessageProvider` | `FutureProvider` | Most recent group message (for preview) |
| `lastPrivateMessageProvider(key)` | `FutureProvider.family` | Most recent private message (for preview) |

**Helper function:**
```dart
String privateChatKey(String user1, String user2) {
  final sorted = [user1, user2]..sort();
  return sorted.join('|');   // e.g. "Karim|Rahim"
}
```
Sorting ensures `Karim→Rahim` and `Rahim→Karim` share the same conversation.

---

## 11. Services

### ReportService (`services/report_service.dart`)

#### `generatePdf(MonthlyReport report, MessMonth month) → Future<File>`

Generates an A4 PDF with:
- Title: "Mess Hisab — {month label}"
- Summary row: meal rate + total expenses
- Table: Member | Meals | Deposit | Cost | Balance
- Teal header row, white text
- Saved to app documents directory as `mess_report_{year}_{month}.pdf`

#### `generateExcel(MonthlyReport report, MessMonth month) → Future<File>`

Generates `.xlsx` with a Bengali-header sheet ("হিসাব"):
- Columns: সদস্য | মিল সংখ্যা | জমা | মিল খরচ | ব্যালেন্স
- Data rows per member
- Summary rows: total expenses, meal rate
- Saved as `mess_report_{year}_{month}.xlsx`

---

### BackupService (`services/backup_service.dart`)

#### `exportBackup() → Future<void>`
- Copies the SQLite `.db` file to app documents directory
- Triggers native share sheet (`share_plus`) for the file

#### `importBackup() → Future<void>`
- Opens file picker (`.db` extension)
- Copies selected file over the current database
- App must be restarted to use restored data

---

### EmailService (`services/email_service.dart`)

Configured with Gmail SMTP (`smtp.gmail.com:587`, STARTTLS).

#### `sendReport({recipients, subject, body, attachments?}) → Future<void>`
Generic email sender with optional file attachments.

#### `sendMonthlyReport({recipients, monthLabel, reportText, pdfFile, excelFile}) → Future<void>`
Sends a formatted monthly report email with:
- Subject: "Mess Hisab Report — {monthLabel}"
- Body: plain-text summary
- Attachments: PDF file + Excel file

**Configuration required** (stored in SharedPreferences):
- `sender_email` — Gmail address
- `sender_password` — Gmail App Password (not regular password)
- `recipients` — Comma-separated email list

---

## 12. Theme & Design System

### Color Palette (`AppColors`)

| Name | Hex | Usage |
|------|-----|-------|
| `primary` | `#6C3CE1` | Purple — main brand color |
| `primaryDark` | `#4A1DA3` | Darker purple |
| `secondary` | `#EC4899` | Hot pink |
| `accent` | `#F97316` | Orange — expenses/market |
| `teal` | `#0D9488` | Teal — deposits |
| `green` | `#10B981` | Green — positive balance |
| `yellow` | `#F59E0B` | Amber — summary cards |
| `blue` | `#3B82F6` | Blue — reports/edit |
| `red` | `#EF4444` | Red — delete/error |

### Gradients

| Name | Colors | Used In |
|------|--------|---------|
| `gradientPurplePink` | Purple → Pink | Dashboard, Members, Settings |
| `gradientOrangeYellow` | Orange → Amber | Expenses, Meals |
| `gradientTealBlue` | Teal → Blue | Reports, Deposits header |
| `gradientGreenTeal` | Green → Teal | Deposits, positive balance |
| `gradientPinkOrange` | Pink → Orange | Negative balance, PDF button |
| `gradientBackground` | Lavender → Pink → Blue | Auth screen backgrounds |

### Typography

**Font:** Nunito (Google Fonts)

| Style | Weight | Usage |
|-------|--------|-------|
| `displayLarge` | 900 | Hero titles |
| `headlineLarge` | 800 | Screen titles |
| `titleLarge` | 700 | Card titles |
| `titleMedium` | 600 | Section headers |
| `bodyLarge` | 500 | List items |
| `labelLarge` | 700 | Buttons |

### UI Component Standards

| Component | Border Radius | Shadow |
|-----------|--------------|--------|
| Cards | 18–20px | `Colors.black 5% blur:12` |
| Buttons | 14–16px | Gradient color 35–40% blur:14 |
| Input fields | 14–16px | `Colors.black 6% blur:10` |
| Avatar containers | 12–16px | Matching color 30% blur:8 |
| FABs | 18px (stadium) | Gradient color 40% blur:16 |

---

## 13. Business Logic & Calculations

### Meal Rate Calculation

```
mealRate = totalExpenses ÷ totalMealUnits
```

Where:
- `totalExpenses` = SUM of all expense amounts in the active month
- `totalMealUnits` = SUM of all member meal units in the active month

If `totalMealUnits = 0`, then `mealRate = 0.0` (prevents division by zero).

### Member Meal Units

For each member, per day:
```
dailyUnits = (breakfast ? 0.5 : 0) + (lunch ? 1.0 : 0) + (dinner ? 1.0 : 0)
```

Monthly total = SUM of all `dailyUnits` across all days in the month.

### Member Settlement

```
mealCost = memberMealUnits × mealRate
balance  = totalDeposit - mealCost
```

| Balance | Meaning |
|---------|---------|
| Positive (`> 0`) | Member paid more than consumed — **refund due** |
| Negative (`< 0`) | Member consumed more than paid — **owes money** |
| Zero | Perfectly settled |

### Expense Description Auto-Generation

When saving a multi-item expense, the `description` field is auto-generated:
```dart
description = validItems.map((i) => i.nameCtrl.text.trim()).join(', ')
// e.g. "চাল, ডাল, তেল, পেঁয়াজ"
```

---

## 14. Chat System

### Architecture

```
User sends message
    → ChatNotifier.send(senderName, text)
        → DBHelper.insertChatMessage(ChatMessage)
            → SQL INSERT into chat_messages
                → _load() called
                    → state updated
                        → UI rebuilds
```

Simultaneously, a `Timer.periodic(2 seconds)` polls the DB and updates state automatically — so other users see new messages within 2 seconds.

### Group Chat Key

All group messages share `chat_type = 'group'`. No key needed — queries filter by `chat_type`.

### Private Chat Key

Private conversations are identified by a deterministic key:
```
key = sort([user1, user2]).join('|')
```

Example: A conversation between "Karim" and "Rahim" always uses key `"Karim|Rahim"` regardless of who initiates.

The DB query retrieves messages where:
```sql
chat_type = 'private'
AND (
  (sender_name = user1 AND receiver_name = user2)
  OR
  (sender_name = user2 AND receiver_name = user1)
)
```

### Message Deletion

- **Own messages only** — long-press triggers delete dialog
- Physically removes the row from `chat_messages`
- State refreshed immediately

---

## 15. Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | ≥ 3.0.0 |
| Dart SDK | ≥ 3.0.0 |
| Android Studio / VS Code | Latest |
| Android SDK | API 21+ (Android 5.0+) |
| Java JDK | 11 or 17 |

### Setup Steps

```bash
# 1. Clone or download the project
cd C:/Users/Jakuan/STA/APPS/mess_hisab_tracker

# 2. Install dependencies
flutter pub get

# 3. Run on connected device or emulator
flutter run

# 4. Run in release mode (faster)
flutter run --release
```

### First Launch Flow

1. App opens → SplashScreen
2. No session found → WelcomeScreen
3. Tap "ম্যানেজার" → SetupScreen
4. Fill in mess details → tap "মেস তৈরি করুন"
5. App goes to Dashboard
6. Start a new month from Dashboard
7. Add members, expenses, meals, deposits

### Adding a Member (After Setup)

1. Share the **Mess Code** with the person
2. They open the app → WelcomeScreen → "সদস্য" → JoinScreen
3. They fill in: name, phone, email, mess code
4. They are now added to the members list

---

## 16. Build & Deployment

### Debug Build

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release Build

```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore ~/mess_hisab.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias mess_hisab

# Build signed APK
flutter build apk --release

# Build split APKs (smaller file per architecture)
flutter build apk --split-per-abi --release

# Output: build/app/outputs/flutter-apk/
#   app-arm64-v8a-release.apk
#   app-armeabi-v7a-release.apk
#   app-x86_64-release.apk
```

### Install on Device

```bash
# Install debug APK via ADB
adb install build/app/outputs/flutter-apk/app-debug.apk

# Or use flutter directly
flutter install
```

### Minimum Android Version

- **Min SDK:** API 21 (Android 5.0 Lollipop)
- **Target SDK:** API 34 (Android 14)

---

## 17. Configuration

### Email (Gmail SMTP)

To use the email report feature:

1. Go to **Settings** screen
2. Enter your Gmail address as "প্রেরক ইমেইল"
3. Generate a **Gmail App Password**:
   - Go to Google Account → Security → 2-Step Verification → App Passwords
   - Generate a password for "Mail" on "Android device"
   - Copy the 16-character password
4. Paste it as "অ্যাপ পাসওয়ার্ড"
5. Enter recipient emails (comma-separated)
6. Tap "সংরক্ষণ"
7. Use "টেস্ট" to verify it works

> **Note:** Regular Gmail passwords will NOT work. You must use an App Password.

### Mess Code

- Set during Manager setup
- Minimum 4 characters
- Can be alphanumeric (e.g. `MESS2026`, `1234`)
- Share verbally or via message to members

### Backup Recommendation

Export backup weekly:
1. Settings → "ব্যাকআপ রপ্তানি"
2. Save the `.db` file to Google Drive or another location
3. To restore: Settings → "ব্যাকআপ পুনরুদ্ধার" → select file → restart app

---

## 18. Known Limitations

| Limitation | Details |
|-----------|---------|
| **Single Device** | No cloud sync. All data is on one device. Multiple devices cannot share live data. |
| **No Real-Time Chat** | Chat polls every 2s. Not WebSocket-based. Works only on shared device. |
| **Plain-Text Password** | Manager password stored as plain text in SQLite `app_config`. Suitable for trusted local use only. |
| **No Push Notifications** | Chat does not trigger notifications. |
| **Gmail Only** | Email feature uses Gmail SMTP hardcoded. Other providers not supported. |
| **No Image Support** | Chat is text-only. No file or image sharing. |
| **Month Overlap** | No validation prevents duplicate month/year combinations. |
| **Single Mess** | One device can only manage one mess setup at a time. |

---

## Appendix A — File Quick Reference

| Task | File |
|------|------|
| Change app colors | `lib/theme/app_theme.dart` |
| Add a new DB table | `lib/database/db_helper.dart` → `_onCreate` + `_onUpgrade` |
| Add a new screen | Create in `lib/screens/`, import in `lib/main.dart` |
| Change meal weights | `lib/models/meal.dart` → `totalUnits` getter |
| Change chat refresh rate | `lib/providers/chat_provider.dart` → `Timer.periodic(...)` |
| Modify email template | `lib/services/email_service.dart` |
| Change PDF layout | `lib/services/report_service.dart` |

---

## Appendix B — Calculation Example

**Scenario:**
- Total expenses: ৳5,000
- Members: Karim, Rahim, Jamal

| Member | Breakfast | Lunch | Dinner | Daily Units | Days | Total Units | Deposit |
|--------|-----------|-------|--------|-------------|------|-------------|---------|
| Karim | ✗ | ✓ | ✓ | 2.0 | 30 | 60.0 | ৳1,800 |
| Rahim | ✓ | ✓ | ✓ | 2.5 | 30 | 75.0 | ৳2,000 |
| Jamal | ✗ | ✓ | ✗ | 1.0 | 30 | 30.0 | ৳1,200 |
| **Total** | | | | | | **165.0** | **৳5,000** |

**Meal Rate** = 5000 ÷ 165 = **৳30.30 per unit**

| Member | Meal Cost | Deposit | Balance |
|--------|-----------|---------|---------|
| Karim | 60 × 30.30 = ৳1,818 | ৳1,800 | **-৳18** (owes) |
| Rahim | 75 × 30.30 = ৳2,273 | ৳2,000 | **-৳273** (owes) |
| Jamal | 30 × 30.30 = ৳909 | ৳1,200 | **+৳291** (refund) |

---

*Documentation written for মেস হিসাব ট্র্যাকার v1.0.0*
*© 2026 — All rights reserved*
