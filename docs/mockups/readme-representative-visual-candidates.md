# README representative visual candidates

This note narrows the README screenshot or GIF source candidates before issue #360 adds an actual image asset.

The source HTML/CSS mockups remain canonical. The current first README image asset lives at `docs/mockups/assets/readme-default-tree.svg` and should stay traceable to the representative rows and state cues in `default-tree.html`.

## Candidate A: baseline tree screenshot

- Source: `default-tree.html`
- Selected README asset: `assets/readme-default-tree.svg`
- Recommended state: first viewport showing the default hierarchy table, expanded and collapsed rows, selection checkboxes, row badges, depth labels, and row actions.
- What it communicates: TreeView's baseline shape in one compact image. A new reader can understand that the gem renders table-first hierarchy rows while leaving business actions to the host app.
- README placement: near the existing static visual reference paragraph in the introduction, before the feature list grows dense.
- Alt text direction: "Static TreeView mockup showing expanded and collapsed hierarchy rows with selection checkboxes, badges, and row actions."
- Weight concern: low. One focused screenshot is easier to scan than a gallery capture and does not imply every focused mockup is part of the README hero.
- Refresh note: when `default-tree.html` changes the first-viewport representative rows, update the README asset in the same review so it still reflects the baseline table-first shape.
- Caveat: it should not look like a complete file-manager product. Crop around the tree surface and keep host-app business copy out of the image.

## Candidate B: review gallery overview

- Source: `review-gallery.html`, preferably the gallery card or preview area that includes the default-tree reference plus a few focused state families.
- Recommended state: side-by-side gallery overview that shows the breadth of focused mockups without opening every page.
- What it communicates: the repository has a reviewable static mockup system for baseline output, state cues, accessibility references, and focused UX surfaces.
- README placement: below the baseline TreeView explanation or in a short "Visual references" note, not as the primary hero image.
- Alt text direction: "TreeView review gallery showing multiple static mockup previews for baseline rows and focused interaction states."
- Weight concern: medium. The overview is useful for reviewers, but it may be visually busy for first-time README readers.
- Caveat: the gallery image should not replace links to individual mockup pages. It is an orientation aid, not the source of truth for every state.

## Recommendation

Use Candidate A as the first README image candidate because it explains the product shape with the least visual noise. Keep Candidate B as a secondary option if #360 decides the README should emphasize the mockup review system rather than the rendered tree surface itself.

## Non-goals for this note

- Adding multiple screenshots, GIFs, or GitHub-hosted image assets.
- Redesigning `default-tree.html` or `review-gallery.html`.
- Deciding a screenshot baseline platform or visual regression approval workflow.
