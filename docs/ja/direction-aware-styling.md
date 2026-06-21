# Direction-aware styling boundary

TreeView は current-row cue、hierarchy connector、toggle spacing、focus / interaction state の baseline CSS を同梱しています。これらは bundled tree をそのままでも読み取りやすくするためのもので、最終的な visual policy は host app に残します。

## 現時点の判断

direction-aware な current-row / hierarchy cue は、まだ machine-readable な public styling hook には含めません。

TreeView は mockup や selector guard で direction-aware な visual reference を示すことがありますが、それだけで CSS class、pseudo-element、directional selector のすべてが compatibility contract に昇格するわけではありません。host app の locale、design system、writing direction に合わせた最終調整は host app stylesheet 側で override してください。

TreeView-owned baseline cue と host-app-owned RTL / writing-direction override を static に比較したい場合は、[`docs/mockups/direction-aware-cues/index.html`](../mockups/direction-aware-cues/index.html) を使ってください。

## 今日安定しているもの

host app が依存してよいのは、`public-api.md` と `config/public_api_manifest.yml` で説明している documented helper method、JavaScript export、controller identifier、event name、documented DOM hook です。

styling では、各 feature guide が明示している documented hook に依存してください。mockup-only class や internal stylesheet selector は、public hook として明記され、必要なら manifest-backed compatibility check に追加されるまでは review aid として扱います。

packaged stylesheet は、reusable state cue 用の小さな manifest-backed CSS custom property surface も公開しています。`config/public_api_manifest.yml` は current `css_custom_property_tokens` list を追跡し、documented styling hook と shipped CSS の drift を release / docs check で気づけるようにします。

代表 token は次のとおりです。

| 目的 | tokens |
|---|---|
| selection / current-row cue | `--tree-view-selected-row-background`, `--tree-view-current-row-accent-color` |
| collapsed / loading / error / drop-target rows | `--tree-view-collapsed-row-background`, `--tree-view-loading-row-background`, `--tree-view-loading-action-color`, `--tree-view-error-row-background`, `--tree-view-drop-target-row-background` |
| focus ring / toggle hover state | `--tree-view-focus-outline-color`, `--tree-view-focus-background`, `--tree-view-focus-ring-contrast-color`, `--tree-view-toggle-hover-background` |
| hierarchy connector / depth marker | `--tree-view-branch-line-color`, `--tree-view-current-branch-line-color`, `--tree-view-level-background`, `--tree-view-level-color`, `--tree-view-hidden-count-background`, `--tree-view-hidden-count-color` |

これらの token は TreeView が提供する state cue の override hook です。最終的な palette、typography、density、dark-mode policy、contrast review、brand styling は引き続き host app が所有します。

## host app override guidance

host app が RTL、vertical writing、design-system-specific cue を必要とする場合:

- TreeView の row semantics と documented data hook は維持する
- current-row、hierarchy connector、toggle spacing、documented CSS custom property value は host app stylesheet で override する
- 新しい host-app override では CSS logical properties を優先する
- business-specific row state、badge、color、routing decision は host app 側に残す

## 将来 public hook に昇格する条件

direction-aware styling hook を public API に昇格するのは、少なくとも次を満たす場合に限ります。

- current row、hierarchy connector、toggle spacing など対象 hook が狭く絞られている
- shipped CSS behavior が compatibility expectation を持てる程度に安定している
- 英日 docs が supported hook と responsibility boundary を明記している
- machine-readable contract が必要な hook では manifest-backed compatibility check も更新されている

complete RTL support、より広い theme system、全 stylesheet selector の export はこの判断の範囲外です。新しい CSS custom property は、stable な host-app override hook として扱う意図がある場合にだけ manifest-backed token list へ追加してください。
