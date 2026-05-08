# Accessibility semantics

このページでは、table based な TreeView row の現在のaccessibility方針と、host app が現時点で依存できる挙動を記録します。

## Goal

TreeView は accessibility を重要な integration concern として扱います。gem は tree-like table rows 向けに一貫した row-level ARIA state を提供し、page structure、domain label、caption、form、業務固有interactionは host app が責任を持ちます。

## 方針

TreeView は table-first with tree-like row controls として扱います。

TreeView は host app の業務columnsをtable row内に描画するため、現時点では完全な `tree` semantics を名乗らず、完全な `treegrid` semantics にもopt-inしません。host appは、生成markupを「展開control、selection状態、current row状態、任意のlazy-loading状態を持つtable」として扱ってください。

`treegrid` semantics へ寄せる場合は、互換性を意識した明示的な判断として行います。個別属性のついでに導入しないでください。

## 現在のARIA配置

- `aria-level` は描画されたrowに置き、node depthを表します。
- `aria-expanded` はbranch rowと、expand/collapse操作を行うTurbo toggle linkに置きます。
- `aria-selected` は描画されたrowに置き、TreeView row selection状態を反映します。
- `aria-current="page"` は、そのrowがcurrent itemを表すときに描画されたrowへ置きます。
- `aria-controls` は現時点ではtoggle linkへ出力しません。
- 現時点では table row に `role="tree"` や `role="treeitem"` は出力しません。

## 対応している描画例

### Static table rows

static rendering は row-level の depth と branch state を持つ table row を出力します。

```html
<tr id="project_1" aria-level="1" aria-expanded="true" aria-selected="false">
  ...
</tr>
```

`initial_state`、`collapsed_keys`、`max_initial_depth` によって branch が collapsed になる場合、その branch row は `aria-expanded="false"` を持ち、現在の render に含まれない descendants は HTML に出力されません。

### Turbo trees

Turbo rendering は static rendering と同じ row-level ARIA state を使います。expand/collapse 操作を行う toggle link も現在の `aria-expanded` 値を持つため、assistive technology が control state を読み上げやすくなります。

TreeView は Turbo toggle link に `aria-controls` を出力しません。toggle が複数 descendant rows に影響することがあり、lazy-loading 時は対象がまだ DOM に存在しないことがあるためです。

### Checkbox trees

selection が有効な場合、各描画 row の `aria-selected` は TreeView の selected row state を反映します。checkbox payload や disabled state は [Selection](selection.md) に記載された selection API が引き続き扱います。

## Keyboard behavior

TreeView は state tracking、selection、transfer payload、remote loading state 用の Stimulus controller を登録しますが、現時点では完全な WAI-ARIA tree / treegrid keyboard interaction model は実装していません。

host app は page-level keyboard flow、focus order、table caption、action button、TreeView 周辺に追加する shortcut key に責任を持ちます。host app が完全な treegrid keyboard navigation を必要とする場合は、TreeView が自動提供しているものと見なさず、明示的な application feature として扱ってください。

## `aria-controls`

toggle linkは複数のdescendant rowsを表示/非表示にすることがあり、lazy-loading時は制御対象のdescendantsがまだDOM上に存在しない場合があります。常に制御対象と言える単一で安定したcontainerはありません。

そのため、TreeView は `aria-controls` をcurrent rowや誤解を招くtargetへ向けません。`aria-controls` を再導入する場合は、制御対象が明示的・安定的・documentedであることを条件にしてください。

## Selection semantics

`aria-selected` は TreeView row selection状態を意味します。host appが意図的に同一概念として扱わない限り、host app側の業務checkbox状態を意味しません。

checkbox payload、disabled selection状態、送信値は [Selection](selection.md) に記載します。

## Tests

TreeView は documented ARIA behavior を以下の integration specs で保護します。

- static row の `aria-level`、`aria-expanded`、`aria-current`
- collapsed branch の `aria-expanded="false"`
- checkbox selection の `aria-selected`
- windowed rendering の row depth と expansion state

## Host app responsibilities

page-level heading、周辺table caption、domain-specific label、drop target、業務固有のcheckbox semanticsはhost app側の責務です。
