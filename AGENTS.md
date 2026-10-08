# AGENTS.md

## Product North Star
NightShift/OnCall is a caregiving and schedule-support app. Preserve trust in schedules, caregiver/dependent state, notifications, sleep/health context, and watch handoff.

## Non-Negotiables
- Do not send or suppress notifications without making the schedule/state reason inspectable.
- Do not invent health, sleep, location, camera, or watch state when permissions are denied or stale.
- Do not break iPhone/watch consistency for profile, schedule, or alert state.
- Do not hide backend sync, keychain, or HealthKit failures behind local-only success unless the UI clearly says what is pending.
- Avoid broad architecture rewrites; this repo is small enough that explicit code is usually better.

## Choke Points
- App entry and root flow: `OnCall/OnCallApp.swift`, `OnCall/ContentView.swift`
- Schedule/profile editing: `OnCall/Views/ScheduleView.swift`, `OnCall/Views/EditScheduleView.swift`, `OnCall/Views/EditProfileView.swift`
- Backend and sleep state: `OnCall/Models/Managers/BackendSyncManager.swift`, `OnCall/Models/Managers/SleepManager.swift`
- Credentials: `OnCall/Models/Managers/KeychainWrapper.swift`
- Data model: `OnCall/Models/Schedule.swift`, `OnCall/Models/VIewModel.swift`
- Watch app: `OnCall Watch App/`

## Build and Verification Entry Points
- Project: `OnCall.xcodeproj`; app target: `OnCall`; companion target: `OnCall Watch App`.
- No shared schemes or automated test targets are checked in. Discover the available scheme in Xcode before building; do not claim a test suite exists or substitute a successful build for scenario verification.
- Follow the global native-Xcode-first policy. Use a scoped CLI fallback only when the needed native operation is unavailable or unsupported, and record that limitation.
- If tools, signing, or hardware are unavailable, continue independent inspection/edits and report the exact pending scenario. Use the matrix below for manual/runtime verification.

## Verification Matrix
- Schedule changes: verify create, edit, delete, overnight boundaries, and relaunch.
- Notification changes: verify denied/provisional permissions, foreground presentation, scheduled trigger time, and tap routing.
- Watch changes: verify paired/unpaired and stale watch state.
- Backend changes: verify offline, failed sync, retry, and conflict behavior.
- Health/sleep changes: verify permission-denied and authorized flows on device where simulator coverage is incomplete.
- UI changes: visually inspect small screens, empty states, and editing flows.

## Documentation
Update Craft/personal-docs only when schedule semantics, notification rules, caregiver/dependent workflow, or backend sync behavior changes.

Use available Craft/personal-docs access only when repository evidence leaves a relevant product decision unresolved. If unavailable, identify the gap and continue unaffected work.
