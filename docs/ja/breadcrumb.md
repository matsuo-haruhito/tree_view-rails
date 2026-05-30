# Breadcrumb

このページでは、TreeViewのnode pathをパンくずとして描画するhelperを説明します。

## 概要

breadcrumb helper は、records mode の `TreeView::Tree` から対象itemの親階層pathを取得し、rootから現在nodeまでのパンくずを描画します。

TreeView gem が担当するのは以下です。

- `tree.path_for(item)` による root から item までのpath取得
- `tree_view_breadcrumb(tree, item, ...)` helperによるHTML生成
- label builder / path builder / class / separator / 追加HTML属性のcustomization
- records mode以外で使った場合の明確なerror

リンク先route、認可、現在nodeの決定、パンくずを置くlayout、追加属性に紐づく analytics / Turbo behavior はhost app側で実装します。

## 最小例

```erb
<%= tree_view_breadcrumb(
  @tree,
  @document,
  label_builder: ->(item) { item.name }
) %>
```

TreeView は record の表示方法を仮定しないため、`label_builder:` は必須です。`path_builder` を省略した場合は、各nodeのlabelだけを描画します。

## link付きbreadcrumb

```erb
<%= tree_view_breadcrumb(
  @tree,
  @document,
  label_builder: ->(item) { item.name },
  path_builder: ->(item) { document_path(item) }
) %>
```

現在nodeはlinkではなくcurrent labelとして描画されます。

## classとseparator

```erb
<%= tree_view_breadcrumb(
  @tree,
  @document,
  label_builder: ->(item) { item.name },
  nav_class: "breadcrumb-nav",
  list_class: "breadcrumb",
  item_class: "breadcrumb-item",
  link_class: "breadcrumb-link",
  current_class: "breadcrumb-current",
  separator: "/",
  separator_class: "breadcrumb-separator",
  aria_label: "Node path"
) %>
```

## HTML属性

`html:` は `<nav>` 要素に、item-aware な `link_html:` / `current_html:` は link / current label に、Turbo frame target、analytics metadata、system spec hook などの軽いhost app属性を足すために使います。

```erb
<%= tree_view_breadcrumb(
  @tree,
  @document,
  label_builder: ->(item) { item.name },
  path_builder: ->(item) { document_path(item) },
  html: { data: { controller: "breadcrumb-analytics" } },
  link_html: ->(item) { { data: { document_id: item.id }, rel: "up" } },
  current_html: ->(item) { { data: { current_document_id: item.id } } }
) %>
```

TreeView は、これらの属性をbuilt-in classやaccessibility属性とmergeします。`<nav>` の `aria-label` は引き続き `aria_label:` から入り、現在itemには `aria-current="page"` が残ります。

独自wrapper、認可に応じたcopy、属性追加を超えるroute-specific behaviorが必要な場合は、bundled helperを広げず、host app側で `tree.path_for(item)` から直接renderしてください。

## builder

| option | 意味 |
|---|---|
| `label_builder:` | 各itemの表示labelを返す必須のcallable。 |
| `path_builder:` | 各itemのURL/pathを返すcallable。省略時はplain label。 |
| `html:` | `<nav>` 要素への追加属性。 |
| `list_html:` | `<ol>` 要素への追加属性。 |
| `item_html:` | 各 `<li>` 要素への追加属性。callableにはitemが渡されます。 |
| `link_html:` | link要素への追加属性。callableにはitemが渡されます。 |
| `current_html:` | current label要素への追加属性。callableにはitemが渡されます。 |
| `separator_html:` | separator要素への追加属性。callableには直前のitemが渡されます。 |
| `nav_class:` | breadcrumb の `<nav>` container に付与するclass。 |
| `list_class:` | root list要素のclass。 |
| `item_class:` | 各item要素のclass。 |
| `link_class:` | link要素のclass。 |
| `current_class:` | 現在node labelのclass。 |
| `separator_class:` | separator要素のclass。 |
| `separator:` | item間のseparator。 |
| `aria_label:` | breadcrumb の `<nav>` 要素に付与するaccessible label。 |

## 対応mode

breadcrumb helper は records mode のtreeを前提にします。

resolver mode や adapter mode では、親方向のpathを一意に辿れない場合があります。そのため、unsupported modeでは `TreeView::Tree` 側のpath helper errorを使って明確に失敗します。

## Visual reference

breadcrumb path の文脈と tree 自体の current-row cue を静的に見比べたい場合は [breadcrumb-paths.html](../mockups/breadcrumb-paths.html) を参照してください。

この mockup は、この helper の責務境界を視覚的に補うためのものです。path lookup の文脈、current item の描画、host app 側が持つ route / authorization の判断を見比べられますが、route や Turbo navigation 自体を定義するものではありません。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| path lookup in records mode | yes | provides tree/item |
| breadcrumb HTML helper | yes | calls helper |
| label customization | builder hook | provides builder |
| URL/path customization | builder hook | provides routes |
| lightweight HTML/data attributes | merge hooks | provides attributes and behavior |
| authorization | no | yes |
| current item selection | no | yes |
| layout placement | no | yes |
