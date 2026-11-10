# HabitQuest

HabitQuest is a gamified habit tracking mobile application built with Flutter. It helps users build consistent daily habits through interactive quest completion, dynamic XP progression, milestone badges, and persistent progress analytics.

---

## Team Information

* Course: CSCI 3101U – Mobile Devices
* Team: Group 02 (CRN 44177)
* Project: HabitQuest (Part 2 Submission)

---

## Prerequisites & Environment

* Flutter SDK: >= 3.0.0
* Dart SDK: >= 3.0.0
* Target Platforms: Android / iOS / Web / macOS

---

## Build & Execution Instructions

1. Extract the project archive and open the project directory:
   cd code/habit_quest

2. Clean stale build artifacts:
   flutter clean

3. Fetch dependencies:
   flutter pub get

4. Run the application:
   flutter run

---

## Demo Test Credentials

Use the following credentials to log into the pre-configured evaluation account:

* Email: demo@habitquest.local
* Password: QuestPass123!

---

## Implemented Features (Part 2)

* Authentication & Session: Local user sign in and persistent session state across restarts.
* Quest & Habit Management:
  * Add habit with title, description, category, and target days.
  * Reminder time configuration using Flutter's native TimePicker dialog.
  * Edit and update existing habit parameters.
  * Delete habit with confirmation AlertDialog and SnackBar feedback.
* Gamification Engine:
  * Dynamic XP accumulation on habit completion with instant level recalculation.
  * Milestone badges unlocked through an achievements GridView.
* Analytics & Progress:
  * 7-day completion bar charts for habit tracking and consistency analysis.
* Accessibility & User Preferences:
  * Navigation via Material 3 Navigation Drawer.
  * Live Light / Dark theme toggle.
  * Dynamic text size scaling for accessibility.

---

## Submission Directory Structure

```text
Group02_HabitQuest_Part2/
├── code/
│   └── habit_quest/          # Flutter codebase (after running flutter clean)
├── report/
│   └── Group02_Report.pdf    # Written progress report
├── video/
│   └── Group02_Demo.mp4      # 100-second 1080p feature walkthrough video
└── README.md                 # Setup guide, test credentials, and disclosure
```

## Generative AI Disclosure

* Tools Used: Large Language Models (LLMs) were consulted for debugging Flutter UI layout constraints, structuring state management workflows, and editing project documentation.
* Originality Statement: All application architecture, custom widget hierarchies, gamification algorithms, and data structures were implemented and verified directly by the team members.
