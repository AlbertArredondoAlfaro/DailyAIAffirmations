# Daily Affirmation Notifications (Design)

## Summary
Send a daily local notification at 10:00 with the correct affirmation for that date. The app requests permission on first launch and schedules upcoming notifications. If permission is denied, users can enable notifications later from the Customization screen via a settings link.

## Goals
- Daily notification at 10:00 with the correct affirmation for that day.
- Automatic permission request on first launch.
- User can enable/disable from Customization screen.
- No background tasks required.

## Non-goals
- Remote push notifications.
- User-selectable time (fixed 10:00).
- Complex scheduling logic beyond a short rolling window.

## Proposed Approach
### Components
1. **NotificationManager** (new)
   - `requestAuthorization()`
   - `scheduleDailyAffirmations(daysAhead: Int)`
   - `refreshIfNeeded()`
   - `cancelAll()`
   - `openSystemSettings()`

2. **Customization UI**
   - Toggle when authorization is granted.
   - If denied, show a CTA button to open Settings.

### Scheduling Strategy
- Use non-repeating notifications to ensure daily text is correct.
- Schedule a rolling window (e.g., 7 days ahead).
- On each app launch, check the pending requests; if fewer than 2 remain, schedule another batch.

### Content
- Use `AffirmationSelector.dailyAffirmation(for:date, ...)` to build the body.
- Localized title/body using existing `Localizable.strings`.

## Data Flow
- First launch: request permission.
- If granted: schedule next 7 days.
- On launch: `refreshIfNeeded()` to keep the window filled.
- In Customization: toggle ON to schedule, OFF to cancel.

## Error Handling
- If permission denied: show Settings CTA, do not schedule.
- If scheduling fails: log and fail silently (no crash).

## Testing
- Unit tests using a protocol-based notification center mock:
  - 7 requests created for 10:00 local time.
  - Body matches `AffirmationSelector` for each date.
  - Cancel clears pending requests.

## Implementation Notes
- Store a simple flag in UserDefaults to avoid repeated permission prompts.
- Use identifiers like `daily-affirmation-YYYY-MM-DD` for pending requests.
