# Localized names

TreeView は、Rails / ActiveModel / I18n が利用できる場合に、model 名、attribute 名、node type 名を locale 経由で解決する小さな helper を提供します。

row partial や `NodePresenter` で、host app の locale に従った表示名が必要な場合に使います。

## Public surface

host app は、localized display-name の安定した入口として top-level の `TreeView.model_name_for`、`TreeView.attribute_name_for`、`TreeView.type_name_for` helper を呼び出してください。

`TreeView::LocalizedNames` は、maintainer や高度な integration が implementation family を識別できる documented public constant のままです。ただし、module method を直接呼び出すことは推奨される host-app dependency boundary ではありません。`humanize_identifier` や `class_for` のような lower-level helper は implementation helper であり、manifest-backed な host-app contract ではありません。

## Manifest-backed lookup key patterns

`config/public_api_manifest.yml` は、これらの helper が依存する lookup key family を記録します。

| Helper | Manifest key family | Responsibility |
|---|---|---|
| `TreeView.model_name_for` | `activerecord.models`, `activemodel.models` | Rails / ActiveModel の model-name lookup へ委譲し、TreeView 側の fallback label を持ちます。 |
| `TreeView.attribute_name_for` | `activerecord.attributes`, `activemodel.attributes` | Rails / ActiveModel の attribute-name lookup へ委譲し、TreeView 側の fallback label を持ちます。 |
| `TreeView.type_name_for` | `tree_view.node_types` | TreeView-owned の node type lookup prefix で、node type を humanize した fallback を持ちます。 |

manifest が固定するのは key pattern family と helper boundary であり、すべての locale inventory ではありません。host app の translation file、fallback copy、translation completeness check は引き続き host app の責務です。

## row partial と一緒に使う

- `NodePresenter` と `row_partial` の組み合わせ例は [NodePresenter row partial patterns](node-presenter-row-partials.md) を参照してください。
- TreeView の hook と host app 側の rendering code の境界を確認したい場合は [Host app extension points](host-app-extension-points.md#row_partial) を参照してください。
- 長い localized-style label、type badge、attribute label、secondary metadata、tooltip cue を静的に見比べたい場合は [localized-row-labels.html](../mockups/localized-row-labels.html) を参照してください。最終的な translation や product copy は host app の責務です。

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

ActiveModel-backed class では、同等の `activemodel.models` lookup family も使えます。manifest は委譲先の model-name prefix の両方を追跡しますが、helper 自体は Rails / ActiveModel への委譲を維持します。

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

ActiveModel-backed class では、同等の `activemodel.attributes` lookup family も使えます。manifest は委譲先の attribute-name prefix の両方を追跡しますが、host app にすべての translation key を用意することまでは要求しません。

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
