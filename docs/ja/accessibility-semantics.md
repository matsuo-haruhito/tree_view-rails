# Accessibility semantics

このページでは、table based な TreeView row の現在のaccessibility方針を記録します。

## 方針

TreeView は table-first with tree-like row controls として扱います。

TreeView は host app の業務columnsをtable row内に描画するため、現時点では完全な `tree` semantics を名乗らず、完全な `treegrid` semantics にもopt-inしません。host appは、生成markupを「展開control、selection状態、current row状態、任意のlazy-loading状態を持つtable」として扱ってください。

将来的に `treegrid` semantics へ寄せる可能性はありますが、その場合は互換性を意識した明示的な判断として行います。個別属性のついでに導入しないでください。

## 現在のARIA配置

- `aria-level` は描画されたrowに置き、node depthを表します。
- `aria-expanded` はbranch rowと、expand/collapse操作を行うTurbo toggle linkに置きます。
- `aria-selected` は描画されたrowに置き、TreeView row selection状態を反映します。
- `aria-current="page"` は、そのrowがcurrent itemを表すときに描画されたrowへ置きます。
- `aria-controls` は現時点ではtoggle linkへ出力しません。

## `aria-controls`

toggle linkは複数のdescendant rowsを表示/非表示にすることがあり、lazy-loading時は制御対象のdescendantsがまだDOM上に存在しない場合があります。常に制御対象と言える単一で安定したcontainerはありません。

そのため、TreeView は `aria-controls` をcurrent rowや誤解を招くtargetへ向けません。`aria-controls` を再導入する場合は、制御対象が明示的・安定的・documentedであることを条件にしてください。

## Selection semantics

`aria-selected` は TreeView row selection状態を意味します。host appが意図的に同一概念として扱わない限り、host app側の業務checkbox状態を意味しません。

checkbox payload、disabled selection状態、送信値は [Selection](selection.md) に記載します。

## Host app responsibilities

page-level heading、周辺table caption、domain-specific label、drop target、業務固有のcheckbox semanticsはhost app側の責務です。
