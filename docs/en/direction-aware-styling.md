# Direction-aware styling boundary

TreeView ships baseline CSS for current-row cues, hierarchy connectors, toggle spacing, and focused interaction states. These styles are intended to make the bundled tree readable out of the box while leaving final visual policy to the host app.

## Current decision

Direction-aware current-row and hierarchy cues are not a machine-readable public styling hook yet.

TreeView may show direction-aware visual references or selector guards in mockups and tests, but those references do not automatically promote every CSS class, pseudo-element, or directional selector into the compatibility contract. Host apps may override the bundled CSS when their locale, design system, or writing direction requires a different treatment.

## What is stable today

Host apps may rely on the documented helper methods, JavaScript exports, controller identifiers, event names, and documented DOM hooks described in `public-api.md` and `config/public_api_manifest.yml`.

For styling, rely on documented feature-level hooks where the relevant guide names them. Mockup-only classes and internal stylesheet selectors are review aids unless they are explicitly documented as public hooks and, when needed, added to the manifest-backed compatibility checks.

## Host-app override guidance

When a host app needs RTL, vertical writing, or design-system-specific cues:

- keep TreeView's row semantics and documented data hooks intact;
- override current-row, hierarchy connector, and toggle spacing CSS in the host app stylesheet;
- prefer CSS logical properties for new host-app overrides;
- keep business-specific row state, badges, colors, and routing decisions in the host app.

## Future public hook criteria

A direction-aware styling hook should be promoted to public API only when all of these are true:

- the hook is narrowly scoped, such as current row, hierarchy connector, or toggle spacing;
- the shipped CSS behavior is stable enough to support compatibility expectations;
- the English and Japanese docs name the supported hook and its responsibility boundary;
- manifest-backed compatibility checks are updated when the hook must be machine-readable.

Complete RTL support, theme tokens, a CSS custom property system, and exporting every stylesheet selector remain outside this decision.
