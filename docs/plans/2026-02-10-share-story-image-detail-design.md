# Share Story Image + Secondary Text Design

## Goal
Update the Instagram Story share image so it includes the daily illustration and the secondary (expanded) affirmation text, matching the app’s card content.

## Scope
- Share image (1080x1920) layout update.
- Pass illustration name and expanded affirmation to the share renderer.
- Keep existing background and typography style consistent with the app.

## Layout
Order (top to bottom):
1. Title + subtitle
2. Illustration image (centered)
3. Main affirmation text
4. Secondary (expanded) affirmation text
5. Footer

Suggested sizes:
- Illustration height ~320–360px (scaled to fit).
- Secondary text size ~36–40, slightly reduced opacity for hierarchy.

## Data Flow
- `ContentView` passes `model.illustrationName` and `model.expandedAffirmation` into `ShareImageRenderer.render`.
- `ShareImageRenderer` passes values into `ShareStoryView`.
- `ShareStoryView` renders the image and secondary text in the layout.

## Error Handling
- If the image asset is missing, the image view is hidden to avoid crashing the renderer.

## Testing
- Manual: tap Share, verify image shows illustration + secondary text.
- Compare app card to share output for matching secondary text.
