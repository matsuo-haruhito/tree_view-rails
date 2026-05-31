# Localized names

TreeView は、Rails / ActiveModel / I18n が利用できる場合に、model 名、attribute 名、node type 名を locale 経由で解決する小さな helper を提供します。

row partial や `NodePresenter` で、host app の locale に従った表示名が必要な場合に使います。

## Model names

```ruby
TreeView.model_name_for(Document)
TreeView.model_name_for(document)
TreeView.model_name_for(Document, count: 2)
```

対象objectまたはclassが ActiveModel naming を持つ場合、TreeView は以下へ委譲します。

```ruby
Document.model_name.human(count: count)
```

通常の Rails locale file が使えます。

```yaml
ja:
  activerecord:
    models:
      document: "ドキュメント"
```

ActiveModel naming が使えない場合は、class名を素朴に humanize します。translation が無い場合や plain Ruby object に明示的な表示名を出したい場合は `default:` を渡せます。

```ruby
TreeView.model_name_for(Document, default: "ファイル")
TreeView.model_name_for(ExternalItem, default: "外部項目")
```

## Attribute names

```ruby
TreeView.attribute_name_for(Document, :published_at)
TreeView.attribute_name_for(document, :published_at)
```

利用できる場合、TreeView は以下へ委譲します。

```ruby
Document.human_attribute_name("published_at")
```

Rails locale example:

```yaml
ja:
  activerecord:
    attributes:
      document:
        published_at: "公開日時"
```

ActiveModel attribute naming が使えない場合は、attribute名を素朴に humanize します。translation が無い可能性がある field に安定した label を出したい場合は `default:` を渡せます。

```ruby
TreeView.attribute_name_for(Document, :status, default: "状態")
```

## Node type names

`node_type` を持つ heterogeneous tree node では以下を使えます。

```ruby
TreeView.type_name_for(node)
```

TreeView は以下を lookup します。

```yaml
ja:
  tree_view:
    node_types:
      folder: "フォルダ"
      document: "ドキュメント"
```

translation が見つからない場合は、`node_type` の値を humanize します。caller 側で最適な fallback label を持っている場合や `node_type` が空の node を扱う場合は `default:` を渡せます。

```ruby
TreeView.type_name_for(node, default: "ワークスペース項目")
```

## Toolbar action labels

bundled toolbar helper の default label も I18n 経由で解決できます。

```yaml
ja:
  tree_view:
    toolbar:
      labels:
        expand_all: "すべて展開"
        collapse_all: "すべて折りたたむ"
        collapse_all_except_current_path: "現在の経路以外を折りたたむ"
```

`tree_view_toolbar`、`tree_view_toolbar_actions`、`tree_view_toolbar_action_metadata` は、host app が `labels:` override を明示しない限り current locale のこれらの key を参照します。translation が無い場合は built-in の英語copyへ fallback します。

## NodePresenter example

```ruby
presenter = TreeView::NodePresenter.define do
  label { |item| item.respond_to?(:title) ? item.title : TreeView.model_name_for(item) }
  tooltip { |item| TreeView.type_name_for(item) }
  badge { |item| TreeView.attribute_name_for(item, :status) if item.respond_to?(:status) }
end
```

## Scope

これらのhelperはUIを自動描画しません。表示名を解決するだけです。どこにどう表示するかは、host app の row partial、helper、presenter が決めます。
