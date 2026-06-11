# Cookbook

このページでは、TreeViewの既存APIを組み合わせた代表的な使い方をまとめます。

## 概要

cookbook は、個別APIの詳細仕様ではなく、host appでよく使う構成例を示すためのドキュメントです。

編集寄りの tree/table 画面については [Form と編集行](form-editing.md) を参照してください。bulk edit form、inline editing layout、Form Object、行単位の編集 action、validation error、TreeView と host app の責務境界を扱います。

より細かいAPI仕様は以下を参照してください。

- [API概要](api-overview.md)
- [使い方](usage.md)
- [Selection](selection.md)
- [Lazy Loading](lazy-loading.md)
- [Windowed Rendering](windowed-rendering.md)
- [Breadcrumb](breadcrumb.md)
- [Localized names](localized-names.md)
- [toggle icon のカスタマイズ](toggle-icons.md)

## 現在itemのbreadcrumbを追加する

records mode のtreeと現在itemがあり、rootからそのitemまでの短いpathをUIに出したい場合は [Breadcrumb](breadcrumb.md) を使います。TreeView は `tree.path_for(item)` で祖先pathを解決し、`tree_view_breadcrumb` で標準的なbreadcrumb markupを描画します。

```erb
<%= tree_view_breadcrumb(
  @tree,
  @document,
  label_builder: ->(item) { item.name },
  path_builder: ->(item) { document_path(item) }
) %>
```

現在itemはlinkではなくcurrent labelとして描画されます。route helper、authorization、現在itemの決定、layout上の配置はhost app側で扱います。通常のancestor linkには `path_builder:` を使い、breadcrumbをplain labelだけで出したい場合は省略します。

独自wrapper、条件付きcopy、階層ごとのauthorization message、helper optionでは表現しきれないmarkupが必要な場合は、bundled helperを広げず、pathを直接使ってhost app側で描画します。

```erb
<% @tree.path_for(@document).each do |item| %>
  <% if can?(:read, item) %>
    <%= link_to item.name, document_path(item) %>
  <% else %>
    <span><%= item.name %></span>
  <% end %>
<% end %>
```

TreeView は records mode のpath lookupとbundled helper option surfaceを担当します。route、authorization、breadcrumbを置く場所、追加属性に紐づくTurbo / analytics behaviorはhost app側の責務です。

## 行customization quick guide

追加したいUIに合わせて、最小のTreeView extension pointを使います。

| やりたいこと | 推奨hook | host appの責務 |
|---|---|---|
| 業務データ列 | `row_partial` | 表示field、format、link、permission |
| Edit、Show、Delete、Archive、独自action button | `row_actions_partial` | route、controller action、authorization、confirm文言 |
| input、select、inline編集label | `row_partial` または `row_actions_partial` | Form Object、validation、dirty state、保存 |
| level label | `depth_label_builder` | label文言とlocalization |
| badge、status pill、marker風label | `badge_builder` | status名、class、product semantics |
| localeに沿ったrow label、type badge、tooltip | `TreeView::NodePresenter` と LocalizedNames helpers | locale file、最終copy、業務文言 |
| legacy / direct toggle-cell marker text | toggle cellを直接描画する場合の `marker_builder` | marker名とclass |
| expand / collapse control icon | `toggle_icons` または `toggle_icon_builder` | icon set、tooltip / title copy、accessibility文言 |
| folder/file iconやtype label | `badge_builder`、`icon_builder`、または `row_partial` 内のcell | icon set、label、accessibility文言 |
| current row highlight、archived / disabled styling | `row_class_builder`、`row_data_builder`、Row status docs | 状態判定ruleとbehavior |

TreeViewは再利用可能なtree構造、row rendering slot、toggle / selection hook、browser integration markerを提供します。CRUD、保存、validation、authorization、product固有action、host app固有workflowはhost app側で実装します。

これらの extension point を静的に見比べたい場合は、cookbook を demo app として扱わず、mockup map を入口にしてください。まず [TreeView mockups](../mockups/README.md) を開き、presenter と row partial の組み合わせは [node-presenter-row-partials.html](../mockups/node-presenter-row-partials.html)、編集行は [form-editing-rows.html](../mockups/form-editing-rows.html)、行内の native / custom control は [drag-interactive-controls.html](../mockups/drag-interactive-controls.html) と [interactive-marker-behaviors.html](../mockups/interactive-marker-behaviors.html) で確認します。mockup は static visual reference であり、route、CRUD、authorization、保存、最終copyは引き続きhost app側の責務です。

## row_partialで表示列を追加する

主要なrow contentは設定した `row_partial` に置きます。name、owner、updated time、size、typeなどの業務列に向いています。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
<td><%= l(item.updated_at, format: :short) %></td>
```

route判断、authorization check、product固有formatはhost app partialに置きます。

## row_actions_partialで行action linkを追加する

Edit、Show、Delete、Archive、Duplicate、application固有actionなどの行単位action link / buttonは `row_actions_partial` に置きます。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  row_actions_partial: "documents/tree_actions",
  ui_config: tree_ui
)
```

```erb
<!-- app/views/documents/_tree_actions.html.erb -->
<td class="document-actions">
  <%= link_to "Show", document_path(item) %>
  <%= link_to "Edit", edit_document_path(item) %>
  <%= button_to "Delete", document_path(item), method: :delete, data: { turbo_confirm: "Delete this document?" } %>
</td>
```

このpartialでは `item`、`tree`、`render_state` を使えます。TreeViewはslotだけを提供し、route、authorization、confirm文言、controller behavior、保存はhost appが担当します。

## 行内にtext inputやselectを置く

native controlはrow contentにもrow actionsにも置けます。TreeViewは input、select、textarea、button、link、`contenteditable` label をhost app側controlとして扱い、そこからTreeView keyboard navigationやtransfer drag behaviorを開始しません。

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td>
  <%= text_field_tag "documents[#{item.id}][name]", item.name %>
</td>
<td>
  <%= select_tag "documents[#{item.id}][status]",
        options_for_select(Document.statuses.keys, item.status) %>
</td>
```

native controlではないcustom widgetでは、widgetまたは祖先要素に `data-tree-view-interactive="true"` を付けます。

validation、dirty-state handling、form submission、conflict handling、保存はhost app側の責務です。

## depth label、badge、marker、iconをcustomizeする

toggle cellにlevel labelを表示したい場合は `depth_label_builder` を使います。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  depth_label_builder: ->(_document, depth) { "Level #{depth + 1}" }
)
```

file type、workflow state、注意喚起markerなどの短いlabelは `badge_builder` に向いています。

```ruby
badge_builder = ->(document) {
  if document.archived?
    { text: "Archived", class: "is-muted", title: "This document is archived" }
  elsif document.requires_review?
    { text: "Review", class: "is-warning" }
  end
}
```

`badge_builder` はtext、または `text` / `label`、任意の `class`、`title`、`data` を持つHash-like objectを返せます。toggle cellをlegacy / direct renderingする場合は `marker_builder` も同じmarker風labelとして使えます。新しい `RenderState` codeでは `badge_builder` を優先します。

expand / collapse control 自体の見た目を差し替えたい場合は `toggle_icons:` または `toggle_icon_builder:` を使います。TreeView は toggle link、ARIA state、lazy-loading semantics、branch layout を引き続き管理し、host app は icon set、title / tooltip copy、accessibility文言を所有します。state、depth、node type ごとの例は [toggle icon のカスタマイズ](toggle-icons.md) を参照してください。

folder/file type labelを小さく表示する場合は badge / icon builder を使えます。より複雑なicon markupが必要なら、HTMLとaccessibility文言をhost appが管理できるよう `row_partial` に置きます。

```ruby
icon_builder = ->(document) {
  document.folder? ? { text: "Folder", class: "is-folder" } : { text: "File", class: "is-file" }
}
```

## row label、badge、tooltipをlocalizeする

row copyをhard-coded stringではなくhost appのlocale fileに合わせたい場合は、[Localized names](localized-names.md) を使います。`TreeView::NodePresenter` と組み合わせると、rowごとの値を使いながら、最終copy、translation、業務文言はhost app側に残せます。

```ruby
presenter = TreeView::NodePresenter.define do
  label { |item| item.respond_to?(:title) ? item.title : TreeView.model_name_for(item) }
  tooltip { |item| TreeView.type_name_for(item) }
  badge { |item| TreeView.attribute_name_for(item, :status) if item.respond_to?(:status) }
end

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  presenter: presenter
)
```

model label には `TreeView.model_name_for`、attribute label には `TreeView.attribute_name_for`、異種nodeのtype labelには `TreeView.type_name_for` を使います。TreeViewは表示名を解決するだけで、どのlocale keyを用意するか、row partial、badge、title、tooltipのどこに表示するかはhost appが決めます。

## current / archived / disabled / status rowを強調する

`<tr>` 全体の見た目に関わる状態は `row_class_builder` を使い、toggle付近に短いstatus textを出したい場合は `badge_builder` を組み合わせます。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_class_builder: ->(document) {
    [
      "document-row",
      ("is-current" if document.id == params[:id].to_i),
      ("is-archived" if document.archived?),
      ("is-disabled" unless document.editable?)
    ]
  },
  badge_builder: ->(document) {
    next { text: "Archived", class: "is-muted" } if document.archived?
    next { text: "Locked", class: "is-locked" } unless document.editable?
  }
)
```

host app JavaScriptが安定したmetadataを必要とする場合は `row_data_builder` を使います。TreeView levelのinteractionとしてreadonly / disabledを表したい場合は [Row status](row-status.md) も参照してください。authorization decisionや業務ruleは引き続きhost app側で扱います。

## 名前順で安定ソートする

```ruby
sorter = ->(nodes, _tree) {
  nodes.sort_by { |node| [node.name.to_s, node.id] }
}

tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  sorter: sorter
)
```

最後に `id` のような安定化keyを入れると、同名nodeの表示順がぶれにくくなります。

## display_orderを優先してソートする

```ruby
sorter = ->(nodes, _tree) {
  nodes.sort_by do |node|
    [
      node.display_order || Float::INFINITY,
      node.name.to_s,
      node.id
    ]
  end
}
```

`nil` は `Float::INFINITY` に寄せると、未設定項目を末尾にできます。

## 検索結果まで初期展開する

```ruby
matched_documents = Document.search(params[:q]).to_a
expanded_keys = tree.expanded_keys_for(matched_documents)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    default: :collapsed,
    expanded_keys: expanded_keys
  }
)
```

検索結果の親階層を補完して表示したい場合は `path_tree_for` も使えます。

```ruby
path_tree = tree.path_tree_for(matched_documents)
```

## leafだけを選択可能にする

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    visibility: :leaves,
    checkbox_name: "selected_documents[]"
  }
)
```

## archived nodeを選択不可にする

```ruby
selection: {
  enabled: true,
  disabled_builder: ->(document) { document.archived? },
  disabled_reason_builder: ->(document) {
    document.archived? ? "アーカイブ済みのため選択できません" : nil
  }
}
```

## 大きなtreeの初期HTMLを減らす

まず `max_initial_depth` や `max_render_depth` で初期描画量を制限します。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  max_initial_depth: 1
)
```

表示対象行が多い場合は windowed rendering を使います。

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

子nodeを必要な分だけ読み込みたい場合は lazy loading を使います。

product要件として scroll位置に応じたDOM仮想化が必要な場合は、そのcontrollerをhost app側に置き、TreeViewには描画すべきHTML row sliceだけを任せます。`TreeView::RenderWindow` は、すでにvisibleとして計算されたrowを小さく出力するには使えますが、scroll位置の監視、host app queryの削減、page取得、scroll anchoringの維持は行いません。

host-app virtual scrolling の最小構成は次の形です。

1. viewport observer、scroll anchoring、overscan、analytics は host app JavaScript が担当する。
2. host app が query page、cursor、offset を選び、その viewport で表示してよいrecordをauthorizationする。
3. 選ばれたrecordから `RenderState` を作り、`TreeView::RenderWindow` または `tree_view_rows(..., window:)` でvisible HTML sliceだけを描画する。
4. 問題が scroll位置に応じたDOM作業ではなくchild fetching量なら、[Lazy Loading](lazy-loading.md) や [Children Pagination](children-pagination.md) に戻す。

TreeView側の出力境界は [描画スケール](render-scale.md) と [Windowed Rendering](windowed-rendering.md) を参照してください。host appのdata loading量も減らす必要がある場合は [Lazy Loading](lazy-loading.md) と [Children Pagination](children-pagination.md) を使います。このrecipeを組み込みvirtual scrolling engineやserver-side pagination契約として扱わないでください。

## lazy loading と children pagination を組み合わせる

1つのbranchに大量の直接childrenがあり、最初の展開後も全件描画すると大きすぎる場合に使います。lazy loading は最初のchildren endpointとremote-state placeholderをつなぎ、host app は1page分のchildrenとhost-app-ownedの「もっと見る」行を返します。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document",
  key_resolver: ->(item) { TreeView.node_key("document", item.id) }
).build(
  load_children_path_builder: ->(item, depth, scope) {
    children_document_path(item, depth:, scope:, limit: 50, format: :turbo_stream)
  }
)
```

```erb
<%= turbo_stream.replace tree_children_container_dom_id(@parent) do %>
  <tbody id="<%= tree_children_container_dom_id(@parent) %>">
    <%= tree_view_rows(@render_state) %>
    <% if @next_cursor %>
      <tr id="<%= dom_id(@parent, :children_more) %>">
        <td colspan="6">
          <%= link_to "もっと見る",
            children_document_path(@parent, cursor: @next_cursor, limit: @limit, format: :turbo_stream),
            data: { turbo_stream: true } %>
        </td>
      </tr>
    <% end %>
  </tbody>
<% end %>

<%= turbo_stream.replace tree_remote_state_placeholder_dom_id(@parent) do %>
  <span <%= tag.attributes(tree_remote_state_placeholder_attributes(@parent, state: "loaded")) %>>loaded</span>
<% end %>
```

TreeView は `load_children_path_builder`、children container ID、remote-state placeholder attributes、row rendering、lazy-loading hookを提供します。cursor / offset strategy、limit clamp、query ordering、authorization、`children_more` の配置、retry copy、Turbo Stream partial の形はhost app側で決めます。

詳しい責務境界とcursor設計は [Lazy Loading](lazy-loading.md)、[Children Pagination](children-pagination.md)、[描画スケール](render-scale.md) を参照してください。この recipe を infinite scroll や virtual scroll の契約として扱わないでください。それらの方針は、別のfeatureで変えない限りhost app側の責務です。

## static collapsed tree が開けなくなる落とし穴を避ける

`build_static` は開閉URLを設定しません。そのため static rendering と `initial_expansion: { default: :collapsed }` を組み合わせると、collapsed な子孫行は初期HTMLに描画されず、ユーザー操作では展開できません。

```ruby
# static mode は show/hide URL を持たないため、default collapsed にすると
# 子孫行は初期描画されず、ユーザー操作では展開できない。
# ユーザーに開閉させたい場合は Turbo mode で path builder を渡す。
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document_tree",
  key_resolver: ->(item) { node_key(item) }
).build_static

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: { default: :collapsed }
)
```

これは最終的な非インタラクティブ表示だけに使ってください。ユーザーがbranchを開けるUIにしたい場合は Turbo mode を使います。

## Turbo expand/collapse の最小構成

Turbo mode は TreeView の toggle link を host app の route につなぎます。path builder は URL を作るだけで、route、認可、query、Turbo Stream response は host app 側の責務です。

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: self,
  node_prefix: "document_tree",
  key_resolver: ->(item) { node_key(item) }
).build(
  show_descendants_path_builder: ->(item, depth, scope) {
    show_document_tree_path(item, depth:, scope:, format: :turbo_stream)
  },
  hide_descendants_path_builder: ->(item, depth, scope) {
    hide_document_tree_path(item, depth:, scope:, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) {
    documents_path(tree_state: state, format: :turbo_stream)
  }
)
```

```ruby
def show_tree_branch
  authorize! :read, @document
  rebuild_tree_state(expanded_keys: expanded_keys_from_params + [node_key(@document)])

  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: turbo_stream.replace(
        "tree_panel",
        partial: "documents/tree",
        locals: { render_state: @render_state }
      )
    end
  end
end
```

```erb
<div id="tree_panel">
  <%= tree_view_rows(render_state) %>
</div>
```

最初の実装では tree panel 全体を置換する方が、状態の再構築を明示できて手戻りが少ないです。大きなtreeでは、routeとstateの形が安定してから対象の子孫行だけ置換する方式を検討します。

## 現在のブランチだけ初期展開する

ナビゲーション用サイドバーでは、現在のprojectやdocumentを含むbranchだけを開き、他のbranchはcollapsedにする構成がよくあります。`current_item:` または `current_key:` と `auto_expand_ancestors: true` を組み合わせると、current path だけを開き、兄弟branchはcollapsedのまま保てます。

```ruby
current_key = @document ? node_key(@document) : node_key(@project)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    default: :collapsed,
    current_key: current_key,
    auto_expand_ancestors: true
  },
  row_class_builder: ->(document) {
    ["document-row", ("is-current" if node_key(document) == current_key)]
  }
)
```

host app 側が current record object をそのまま持っている場合は、`current_key:` の代わりに `current_item:` を渡せます。

```ruby
initial_expansion: {
  default: :collapsed,
  current_item: @document,
  auto_expand_ancestors: true
}
```

`auto_expand_ancestors:` は `root_items` 配下で current node を解決し、その祖先keyだけを `expanded_keys` に加えます。別の sibling branch や追加pathも最初から開きたい場合は、`expanded_keys:` を併用してください。

current node がない一覧ページでは `current_item:` / `current_key:` を省略し、top-level 行だけを見せたいなら `default: :collapsed` を維持します。他branchもユーザーに開閉させたい場合は、`build_static` ではなく Turbo mode と組み合わせます。

## GraphAdapter と ActiveRecord の性能

`GraphAdapter` の裏側で ActiveRecord data を扱う場合、`children_resolver` から lazy な relation を返さない方が安全です。描画中に children が複数回参照されることがあり、row partial でも関連データを触りがちです。子要素は配列として事前計算し、高コストな derived value は row partial の外に出します。

```ruby
projects = Project.visible_to(current_user).to_a

children_by_project_id = projects.index_with do |project|
  project.documents
    .accessible_to(current_user)
    .includes(:latest_version)
    .to_a
    .sort_by(&:title)
end.transform_keys(&:id)

adapter = TreeView::GraphAdapter.new(
  roots: projects,
  children_resolver: ->(node) {
    node.is_a?(Project) ? children_by_project_id.fetch(node.id, []) : []
  }
)
```

実装時の確認ポイント:

- tree 構築前に親recordを `to_a` で確定する。
- `children_resolver` から ActiveRecord relation ではなく配列を返す。
- parent id ごとの children cache を host app 側で作る。
- row partial 内で DB query や高コストな権限・version判定をしない。
- 表示可能versionなどの derived value は helper や presenter でcacheする。

## recursive tree の development log Tips

大きめの recursive tree では、Rails log に `_tree_row.html.erb`、`_tree_toggle_cell.html.erb`、`_tree_toggle_content.html.erb` などの view render log が大量に出ることがあります。render log 自体は異常ではありません。性能調査では、row render 中に database work が繰り返されていないかに注目します。

Rails log では次を見ます。

- `Views:` に比べて `ActiveRecord:` が大きい。
- row render 中に `Document Load` や `DocumentVersion Load` が繰り返される。
- `CACHE` ではない同形queryが大量に出る。
- row partial から呼ぶ helper が association を繰り返し触っている。

host app 側の対策は、children を配列で事前計算する、row partial で使う derived value をcacheする、DB query 調査中だけ development の view log ノイズを抑える、などです。recursive partial log は想定内で、問題は繰り返し発生する uncached query です。

## 行に状態classを付ける

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_class_builder: ->(document) {
    ["document-row", ("is-archived" if document.archived?)]
  }
)
```

行全体のdisabled / readonly状態を表す場合は [Row status](row-status.md) も参照してください。

## node_key衝突を避ける

異種nodeを同じtreeで扱う場合は、class名などを含めます。

```ruby
node_key_resolver = ->(node) {
  TreeView.node_key(node.class.name, node.id)
}
```

詳細は [Node keys](node-keys.md) を参照してください。
