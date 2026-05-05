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
    <%= link_to "もっと見る", children_document_path(@parent, cursor: @next_cursor, format: :turbo_stream) %>
  <% end %>
<% end %>
```

## lazy loadingとの関係

children pagination は lazy loading の上にhost app側で作る仕組みです。

- TreeView: children URL とrow data hookを提供する
- Host app: page単位のquery、cursor、追加rendering、次ページUIを実装する

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
