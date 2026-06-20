# State cue のスタイリング

TreeView は quick-start 用 stylesheet として `tree_view.scss` を同梱しています。この stylesheet は、再利用可能な row 構造と、selected / current / collapsed / loading / error / drop target などの軽量な見た目を提供します。

host app は TreeView を import した後に CSS custom properties を指定することで、同梱 cue color を上書きできます。

```scss
@import "tree_view";

:root {
  --tree-view-selected-row-background: color-mix(in srgb, var(--brand-primary) 12%, transparent);
  --tree-view-current-row-accent-color: var(--brand-primary);
  --tree-view-drop-target-row-background: color-mix(in srgb, var(--brand-success) 14%, transparent);
}
```

## Documented tokens

host app の stylesheet から上書きできる token は次のとおりです。

| Token | 対象 |
|---|---|
| `--tree-view-selected-row-background` | selected row |
| `--tree-view-current-row-accent-color` | current row の左 accent |
| `--tree-view-collapsed-row-background` | collapsed row |
| `--tree-view-loading-row-background` | loading row |
| `--tree-view-loading-action-color` | loading row の toggle action text |
| `--tree-view-error-row-background` | error / drop-disabled row |
| `--tree-view-drop-target-row-background` | active drop target row |
| `--tree-view-focus-outline-color` | toggle focus-visible outline |
| `--tree-view-focus-background` | toggle focus-visible background |
| `--tree-view-focus-ring-contrast-color` | toggle focus-visible contrast ring |
| `--tree-view-toggle-hover-background` | toggle hover background |
| `--tree-view-branch-line-color` | 通常の hierarchy branch line |
| `--tree-view-current-branch-line-color` | current hierarchy branch line |
| `--tree-view-level-background` | depth label background |
| `--tree-view-level-color` | depth label text |
| `--tree-view-hidden-count-background` | hidden descendant count background |
| `--tree-view-hidden-count-color` | hidden descendant count text |

各 token には、token 追加前と同じ fallback 値があります。そのため、host app が上書きしない場合は既存の quick-start appearance を維持します。

`config/public_api_manifest.yml` はこの一覧を `css_custom_property_tokens` として追跡します。manifest-backed contract が扱うのは packaged stylesheet とこのページで document された token 名であり、fallback 値を host app 向け configuration や theme API にするものではありません。

## Boundary

TreeView が持つのは、同梱 stylesheet 向けの小さな state-cue surface だけです。complete theme system、dark-mode policy、density scale、product copy、host app design tokens は TreeView の責務ではありません。

layout、spacing、row markup、application-specific な visual language が必要な場合は、引き続き各 feature guide の説明に従い、host app 側の CSS selector 上書きや copied rendering を使ってください。
