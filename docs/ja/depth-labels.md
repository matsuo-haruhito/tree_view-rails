# Depth labels

このページでは、TreeViewの各行にdepth labelを表示するためのhookを説明します。

## 概要

Depth label は、nodeのdepthをユーザーに分かりやすく表示するための小さな表示hookです。

TreeView gem が担当するのは以下です。

- row contextからdepthを渡す
- `depth_label_builder` を評価する
- builderの戻り値をrow visual areaに表示する

どのdepthにどの文言を出すか、業務上の意味付け、CSS表現はhost app側で決めます。

## 基本例

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  depth_label_builder: ->(item, context) {
    "Level #{context.depth}"
  }
)
```

## 業務用labelに変換する

```ruby
depth_label_builder = ->(_item, context) {
  case context.depth
  when 0 then "カテゴリ"
  when 1 then "フォルダ"
  else "項目"
  end
}
```

## 何も表示しない行

builderが `nil` や空文字を返した場合、labelは表示されません。

```ruby
depth_label_builder = ->(_item, context) {
  context.depth.zero? ? "Root" : nil
}
```

## contextで使える情報

`context` には、rowごとの描画情報が入ります。

主に以下を利用できます。

| API | 意味 |
|---|---|
| `depth` | rootを0とするdepth。 |
| `item` | 現在のitem。 |
| `tree` | 現在のtree。 |
| `render_state` | 現在のRenderState。 |

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| depth calculation | yes | no |
| builder invocation | yes | provides builder |
| label text | no | yes |
| CSS styling | no | yes |
| business meaning of depth | no | yes |
