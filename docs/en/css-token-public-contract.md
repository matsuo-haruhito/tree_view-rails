# CSS Token Public Contract

The packaged stylesheet documents a small set of `--tree-view-*` CSS custom properties for state cues. These tokens are a compatibility surface for host-app stylesheet overrides, not a complete theme system.

The public API manifest tracks the documented token names so release checks can catch drift between the packaged stylesheet, public API docs, and styling-state guidance. Host apps may override these tokens after importing TreeView styles, but TreeView still does not own dark mode policy, density scales, brand theme design, or visual-regression baselines.

Do not treat every internal selector in `tree_view.scss` as public. Only documented tokens promoted into `config/public_api_manifest.yml` are covered by the manifest-backed token contract.
