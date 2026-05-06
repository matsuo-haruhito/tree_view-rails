# Lazy Loading

このページでは、子nodeを必要なタイミングで読み込むためのTreeView hooksを説明します。

## 概要

lazy loading は、初期HTMLにすべての子孫を描画せず、ユーザー操作やhost app側のremote requestに応じて子nodeを追加表示するための機能です。

TreeView gem が担当するのは以下です。

- `load_children_path_builder` から children URL を生成する
- row data に children URL / loaded state を出力する
- `tree-view-remote-state` controller 用の data/action hook を出力する
- loading / loaded / error / retry event に反応するcontrollerを提供する

実際のfetch、Turbo request、controller action、認可、query、retry UI、children paginationはhost app側で実装します。

## UiConfigの設定

lazy loadingを使う場合は、`UiConfigBuilder#build` に `load_children_path_builder` を渡します。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build(
  hide_descendants_path_builder: ->(item, depth, scope) {
    hide_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  show_descendants_path_builder: ->(item, depth, scope) {
    show_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  load_children_path_builder: ->(item, depth, scope) {
    children_document_path(item, depth: depth, scope: scope, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) {
    documents_path(state: state)
  }
)
```

`load_children_path_builder` はURLを作るだけです。

## RenderStateの設定

`RenderState` 側では `lazy_loading:` を指定します。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  lazy_loading: {
    enabled: true,
    loaded_keys: loaded_keys,
    scope: "children"
  }
)
```

| option | 意味 |
|---|---|
| `enabled:` | lazy loading用data属性を出すかどうか。 |
| `loaded_keys:` | すでにchildrenを読み込み済みのnode_key配列。 |
| `scope:` | path builderへ渡すscope。省略可能。 |

## 最小host-app pattern

小さなlazy loading連携は、通常host app側の3つの要素で構成します。

1. parentを認可し、直接childrenだけを読み込むcollection action。
2. child rowsを追加または差し替えるTurbo Stream response。
3. serverから返却済みのrowをloaded扱いにする安定した `loaded_keys`。

routesは通常のRails routesで十分です。

```ruby
resources :documents do
  member do
    get :children
  end
end
```

controller actionでは、query、authorization、loaded state policyをhost app側に残します。

```ruby
class DocumentsController < ApplicationController
  def index
    @tree = build_tree(Document.roots_for(current_user))
    @loaded_keys = []
    @render_state = build_render_state(@tree, loaded_keys: @loaded_keys)
  end

  def children
    @parent = Document.find(params[:id])
    authorize! @parent, :show?

    children = @parent.children.visible_to(current_user).order(:name, :id)
    @tree = build_tree(children)
    @loaded_keys = [TreeView.node_key("document", @parent.id)]
    @render_state = build_render_state(@tree, loaded_keys: @loaded_keys)
  end

  private

  def build_tree(records)
    TreeView::Tree.new(
      records: records,
      parent_id_method: :parent_document_id,
      id_method: :id
    )
  end

  def build_render_state(tree, loaded_keys:)
    TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "documents/tree_columns",
      ui_config: tree_ui,
      lazy_loading: {
        enabled: true,
        loaded_keys: loaded_keys
      }
    )
  end
end
```

実際のquery shapeはアプリごとに異なります。重要なのは、TreeViewはhookを描画し、現在のuserが見てよいrecordの判断はhost app側で行う、という境界です。

## Turbo Stream response pattern

host appが所有するsubtreeやplaceholder領域だけを返します。

```erb
<%= turbo_stream.replace dom_id(@parent, :children) do %>
  <tbody id="<%= dom_id(@parent, :children) %>">
    <%= tree_view_rows(@render_state) %>
  </tbody>
<% end %>

<%= turbo_stream.replace dom_id(@parent, :remote_state) do %>
  <span id="<%= dom_id(@parent, :remote_state) %>" data-tree-remote-state="loaded">loaded</span>
<% end %>
```

requestが失敗した場合は、TreeView内部にerrorを隠さず、host app側のretry UIを返します。

```erb
<%= turbo_stream.replace dom_id(@parent, :remote_state) do %>
  <span id="<%= dom_id(@parent, :remote_state) %>" data-tree-remote-state="error">
    childrenを読み込めませんでした。
    <%= link_to "再試行", children_document_path(@parent, format: :turbo_stream), data: { turbo_stream: true } %>
  </span>
<% end %>
```

## loaded / error / retry state

状態の責務は次のように分けます。

| State | TreeView | Host app |
|---|---|---|
| not loaded | child URLと `data-tree-loaded="false"` を含むrow data | unloaded descendantsを省く初期query |
| loading | remote-state controller hook | fetch / Turbo request lifecycle とloading indicator |
| loaded | loaded-state data hook | 返却するchild rowsとloaded key state更新 |
| error | error hook | error message、retry link、logging、authorization-safe response |
| retry | retry hook | 同じhost-app endpointへの再request |

lazy loadingをauthorizationの代わりに使わないでください。parentとchildren endpointは必ずserver側で認可します。

## 出力されるrow data

lazy loadingが有効で、`load_children_path_builder` がURLを返す場合、rowには概ね以下のようなdata属性が付きます。

```html
<tr
  data-tree-lazy="true"
  data-tree-children-url="/documents/1/children"
  data-tree-loaded="false">
</tr>
```

## Remote state controller

`tree_view_state_data(render_state)` は、lazy loading有効時に `tree-view-remote-state` controller と action hook を追加します。

```text
tree-view:loading->tree-view-remote-state#loading
tree-view:loaded->tree-view-remote-state#loaded
tree-view:error->tree-view-remote-state#error
tree-view:retry->tree-view-remote-state#retry
```

host app側は、fetchやTurbo requestの状態に応じてこれらのeventをdispatchできます。

## children pagination

大量のchildrenを少しずつ読み込む場合は、server-side paginationをhost app側で実装します。

TreeView側は、URL生成とrow data hookだけを提供します。cursor、page token、limit、offset、次ページ判定、追加Turbo Streamの内容はhost app側で決めます。

children paginationの詳細は [Children pagination](children-pagination.md) を参照してください。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| children URL generation | yes | provides path builder |
| row data attributes | yes | consumes them |
| remote-state controller hooks | yes | dispatches events |
| fetching children | no | yes |
| Turbo Stream response | no | yes |
| authorization | no | yes |
| server-side pagination | no | yes |
| retry / error messaging | hook only | yes |
