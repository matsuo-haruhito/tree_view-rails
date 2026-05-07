# Children Pagination

このページでは、lazy loading と組み合わせて大量のchildrenを少しずつ読み込むための方針を説明します。

## 概要

children pagination は、1つのnodeに大量のchildrenがある場合に、host app側でserver-side paginationを行い、必要な分だけ子nodeを読み込む設計です。

TreeView gem は pagination algorithm を持ちません。

TreeView が担当するのは以下です。

- `load_children_path_builder` によるchildren URL生成
- lazy loading用のrow data属性
- remote-state controller hook
- childrenを追加表示するためのHTML/Turbo Streamをhost appが返せるようにする境界

cursor、offset、limit、page token、次ページ判定、query、認可、Turbo Stream responseはhost app側で実装します。

## URL設計例

```ruby
load_children_path_builder: ->(item, depth, scope) {
  children_document_path(
    item,
    depth: depth,
    scope: scope,
    cursor: params[:cursor],
    limit: 50,
    format: :turbo_stream
  )
}
```

ただし、実際には `params` を直接閉じ込めるより、controller側で現在のcursorやlimitを明示的に組み立てる方が安全です。

## 最小cursor pattern

安定した並び順を使い、次pageがあるかを判定するために1件多く取得します。

```ruby
class DocumentsController < ApplicationController
  DEFAULT_CHILD_LIMIT = 50
  MAX_CHILD_LIMIT = 100

  def children
    @parent = Document.find(params[:id])
    authorize! @parent, :show?

    @limit = child_limit
    relation = @parent.children.visible_to(current_user).order(:name, :id)
    relation = apply_cursor(relation, params[:cursor]) if params[:cursor].present?

    page = relation.limit(@limit + 1).to_a
    @children = page.first(@limit)
    @next_cursor = page.size > @limit ? encode_cursor(@children.last) : nil

    @tree = TreeView::Tree.new(
      records: @children,
      parent_id_method: :parent_document_id,
      id_method: :id
    )

    @render_state = TreeView::RenderState.new(
      tree: @tree,
      root_items: @tree.root_items,
      row_partial: "documents/tree_columns",
      ui_config: tree_ui,
      lazy_loading: {
        enabled: true,
        loaded_keys: [TreeView.node_key("document", @parent.id)]
      }
    )
  end

  private

  def child_limit
    requested = params.fetch(:limit, DEFAULT_CHILD_LIMIT).to_i
    [[requested, 1].max, MAX_CHILD_LIMIT].min
  end

  def apply_cursor(relation, cursor)
    name, id = decode_cursor(cursor)
    relation.where("name > ? OR (name = ? AND id > ?)", name, name, id)
  end

  def encode_cursor(record)
    Base64.urlsafe_encode64([record.name, record.id].join("\0"))
  end

  def decode_cursor(cursor)
    Base64.urlsafe_decode64(cursor).split("\0", 2)
  rescue ArgumentError
    raise ActionController::BadRequest, "Invalid cursor"
  end
end
```

cursor形式はhost app側の判断です。重要なのは、安定したordering、明示的なlimit clamp、server側cursor validationです。

## controller例

```ruby
class DocumentsController < ApplicationController
  def children
    parent = Document.find(params[:id])
    authorize! parent, :show?

    page = Document.where(parent_document_id: parent.id)
      .order(:name, :id)
      .limit(limit + 1)

    @children = page.first(limit)
    @next_cursor = page.size > limit ? @children.last.id : nil
  end

  private

  def limit
    [[params.fetch(:limit, 50).to_i, 1].max, 100].min
  end
end
```

## Turbo Stream例

host app側で、children rowsと「もっと見る」UIを返します。

```erb
<%= turbo_stream.append dom_id(@parent, :children) do %>
  <%= tree_view_rows(@render_state) %>
<% end %>

<% if @next_cursor %>
  <%= turbo_stream.replace dom_id(@parent, :children_more) do %>
    <%= link_to "もっと見る",
      children_document_path(@parent, cursor: @next_cursor, limit: @limit, format: :turbo_stream),
      data: { turbo_stream: true } %>
  <% end %>
<% else %>
  <%= turbo_stream.remove dom_id(@parent, :children_more) %>
<% end %>
```

初期表示側では、host appが表示したい場所に次page用placeholderを出します。

```erb
<tr id="<%= dom_id(parent, :children_more) %>">
  <td colspan="6">
    <%= link_to "もっと見る",
      children_document_path(parent, cursor: next_cursor, limit: limit, format: :turbo_stream),
      data: { turbo_stream: true } %>
  </td>
</tr>
```

## lazy loadingとの関係

children pagination は lazy loading の上にhost app側で作る仕組みです。

- TreeView: children URL とrow data hookを提供する
- Host app: page単位のquery、cursor、追加rendering、次ページUIを実装する

## selection / drag-drop との相互作用

pagination中は、まだDOM上に存在しないdescendantsがあります。product behaviorを明示的に決めてください。

| Feature | host app側で決めること |
|---|---|
| Checkbox selection | selectionをloaded rowsだけに適用するのか、filtered child set全体に適用するのかを決める。loaded rowsを超えて適用する場合は、DOM上のcheckbox値だけでなくserver-side selection intentを送る。 |
| Cascade selection | server側でcascadeを計算しない限り、unloaded descendantsはunknownとして扱う。1pageだけ読み込まれている状態で、parent checkboxが全childrenを代表しているように見せない。 |
| Drag/drop | move validationはserver側で行う。見えていないsiblingsがallowed positions、ordering、conflict checkに影響する可能性があります。 |
| Bulk actions | unloaded childrenにも作用するactionはquery-backed actionにする。DOMから送られるcheckbox値はloaded-row actionsに限定する。 |
| Retry/error UI | 失敗したparent/pageにretry controlをscopeし、他のpageがloadedのまま残れるようにする。 |

## 注意点

- 並び順は必ず安定させてください。例: `order(:name, :id)`
- limitには上限を設けてください。
- cursorやpage tokenはhost app側で検証してください。
- drop/reorderなどの操作と組み合わせる場合は、pagination中の見えていないnodeをどう扱うかを業務仕様として決めてください。

## 責務範囲

| Area | TreeView | Host app |
|---|---|---|
| children URL hook | yes | provides builder |
| row lazy-loading data | yes | consumes data |
| remote-state events | hook only | dispatches events |
| cursor / offset / token | no | yes |
| query and ordering | no | yes |
| next-page detection | no | yes |
| Turbo Stream response | no | yes |
| authorization | no | yes |
| retry/error UI | hook only | yes |
