# Breadcrumb

このページでは、TreeViewのnode pathをパンくずとして描画するhelperを説明します。

## 概要

breadcrumb helper は、records mode の `TreeView::Tree` から対象itemの親階層pathを取得し、rootから現在nodeまでのパンくずを描画します。

TreeView gem が担当するのは以下です。

- `tree.path_for(item)` による root から item までのpath取得
- `tree_view_breadcrumb(tree, item, ...)` helperによるHTML生成
- label builder / path builder / class / separator のcustomization
- records mode以外で使った場合の明確なerror

リンク先route、認可、現在nodeの決定、パンくずを置くlayoutはhost app側で実装します。

## 最小例

```erb
<%= tree_view_breadcrumb(@tree, @document) %>
```

`path_builder` を省略した場合は、各nodeのlabelだけを描画します。

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
  list_class: "breadcrumb",
  item_class: "breadcrumb-item",
  link_class: "breadcrumb-link",
  current_class: "breadcrumb-current",
  separator: "/"
) %>
```

## builder

| option | 意味 |
|---|---|
| `label_builder:` | 各itemの表示labelを返すcallable。 |
| `path_builder:` | 各itemのURL/pathを返すcallable。省略時はplain label。 |
| `list_class:` | root list要素のclass。 |
| `item_class:` | 各item要素のclass。 |
| `link_class:` | link要素のclass。 |
| `current_class:` | 現在node labelのclass。 |
| `separator:` | item間のseparator。 |

## 対応mode

breadcrumb helper は records mode のtreeを前提にします。

resolver mode や adapter mode では、親方向のpathを一意に辿れない場合があります。そのため、unsupported modeでは `TreeView::Tree` 側のpath helper errorを使って明確に失敗します。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| path lookup in records mode | yes | provides tree/item |
| breadcrumb HTML helper | yes | calls helper |
| label customization | builder hook | provides builder |
| URL/path customization | builder hook | provides routes |
| authorization | no | yes |
| current item selection | no | yes |
| layout placement | no | yes |
