# Daily Card Random Background (Design)

## Summary
Generate a new, random background for the affirmation card on each app launch. The background is rendered at runtime (no assets), matching the current app aesthetic (blue-violet gradients + soft glow) and placed behind the card text.

## Goals
- New look on every launch.
- Preserve current readability and visual style.
- No asset pipeline changes.
- Lightweight and deterministic within a single launch.

## Non-goals
- Persisting the background across launches.
- Changing card text/layout.
- Adding external dependencies.

## Proposed Approach
### Components
1. **CardBackgroundModel**
   - Base gradient colors (aligned with `AppBackground`).
   - A list of “blobs”: position (x,y in 0..1), radius (points), color, opacity.

2. **CardBackgroundGenerator**
   - `static func make() -> CardBackgroundModel`
   - Randomizes blobs (3–5) within safe ranges.
   - Clamps values for readability.

3. **AffirmationCardBackgroundView**
   - Renders the model using `ZStack` with `LinearGradient` and `Circle` + `RadialGradient`.

### Integration
- In `ContentView`, create a `@State` model at launch time.
- Pass it into `AffirmationCard`.
- In `AffirmationCard`, render the background below the existing dark overlay, keeping current shadows and text contrast.

## Data Flow
- App launch -> `CardBackgroundGenerator.make()` -> stored in `@State`.
- `AffirmationCard` reads model and renders background.
- No persistence. No regeneration on returning from background (per requirement).

## Error Handling
- Clamp ranges to avoid extreme opacity/size values.
- If generation fails, fall back to a minimal default (base gradient only).

## Testing
- **Unit tests** for generator:
  - Blob count within range.
  - Opacity and radius within bounds.
  - Colors chosen from palette.

## Implementation Notes
- Keep palette consistent with `AppBackground`.
- Maintain `.glassCard` overlay and stroke for continuity.
- Ensure the background does not alter accessibility (text remains readable).
