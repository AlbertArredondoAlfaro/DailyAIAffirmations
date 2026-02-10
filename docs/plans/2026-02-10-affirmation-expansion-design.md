# Affirmation Expansion (Design)

## Summary
Add a short dynamic paragraph (1–2 sentences) beneath each daily affirmation. The expansion is generated locally from templates so it remains fast, deterministic, and offline, and matches the affirmation language.

## Goals
- Add short supportive text for every affirmation.
- Keep tone calm and motivational.
- Maintain language parity with the affirmation (ES/EN).
- No external APIs.

## Non-goals
- Full NLP semantic parsing.
- User-configurable length.
- Remote content.

## Proposed Approach
### Components
1. **AffirmationExpansionGenerator**
   - `expand(affirmation:language:) -> String`
   - Uses template pools for ES/EN.
   - Optional keyword extraction (simple heuristics) for variety.
   - Fallback to a generic expansion when no keyword is found.

2. **AffirmationViewModel**
   - Exposes `expandedAffirmation` derived from `displayAffirmation`.

3. **UI**
   - Add secondary text below the main affirmation in the card.
   - Slightly smaller size and lower opacity.

## Data Flow
- `loadDaily()` sets `currentAffirmation`.
- `displayAffirmation` replaces `{name}` if enabled.
- `expandedAffirmation` is generated using `displayAffirmation` and current language.
- UI displays both.

## Error Handling
- If expansion returns empty, show fallback generic sentence.

## Testing
- Unit test: expansion for EN/ES returns non-empty and ends with punctuation.
- Unit test: placeholder name is preserved if already replaced.

## Implementation Notes
- Keep templates short (1–2 sentences).
- Use a small keyword list for ES/EN to add variety.
