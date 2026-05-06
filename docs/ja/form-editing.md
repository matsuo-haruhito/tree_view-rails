# Form と編集行

TreeView の行には Rails の form control や action link を配置できます。ただし、TreeView は編集 workflow 自体を持ちません。

bulk edit 画面、inline-edit 風の行、行単位の編集 action など、編集寄りの tree/table 画面を作るときはこのページを参照してください。

## 責務境界

TreeView は inline-editing layout を支援します。inline-editing workflow は提供しません。

つまり、TreeView は行構造、indentation、開閉 control、selection control、host app の partial を描画できます。一方で、どの行を edit mode にするか、record をどう validate するか、変更をどう保存するか、authorization をどう行うか、未保存変更をどう保護するかは host app が決めます。

| 関心事 | 責務 | 補足 |
|---|---|---|
| 行描画と tree indentation | TreeView | `tree_view_rows` と `row_partial` を使います。 |
| 行 cell 内の form control | host app | host app 所有の `row_partial` に配置します。 |
| keyboard / selection / drag の競合回避 | 共有 | TreeView は構造と hook を提供し、必要に応じて interactive control 側で行単位の挙動を止めます。 |
| edit mode state | host app | params、Turbo、Stimulus、server state などを app 側で管理します。 |
| Form Object | host app | stable な ID / parent ID を公開すれば TreeView からは通常の row object として扱えます。 |
| validation error | host app | row partial 内、または table 周辺に表示します。 |
| persistence | host app | controller / service が update semantics を決めます。 |
| authorization | host app | user ごとに表示・submit 可能な field/action を決めます。 |
| dirty-state handling | host app | 入力変更後の collapse、lazy loading、Turbo replacement などを確認・抑止します。 |
| Turbo Stream response | host app | TreeView は再描画できますが、response の timing や target は app 側の責務です。 |

## bulk edit table pattern

表示中のすべての行を editable field として描画し、まとめて submit します。name、status、flag、ordering field、その他 business attribute を一括編集したい場合に向いています。

Controller:

```ruby
class DocumentsController < ApplicationController
  def edit_tree
    @form = DocumentTreeForm.new(documents: Document.arrange_for_tree)
    build_tree_view(@form.rows)
  end

  def update_tree
    @form = DocumentTreeForm.new(document_tree_params)

    if @form.save
      redirect_to documents_path, notice: "Documents updated"
    else
      build_tree_view(@form.rows)
      render :edit_tree, status: :unprocessable_entity
    end
  end

  private

  def build_tree_view(rows)
    tree = TreeView::Tree.new(
      records: rows,
      id_method: :id,
      parent_id_method: :parent_id
    )

    @render_state = TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "documents/edit_tree_columns",
      ui_config: @tree_ui
    )
  end
end
```

View:

```erb
<%= form_with model: @form, url: update_tree_documents_path, method: :patch do |form| %>
  <table class="tree-view-table">
    <tbody>
      <%= tree_view_rows(@render_state, locals: { form: form }) %>
    </tbody>
  </table>

  <%= form.submit "Save changes" %>
<% end %>
```

Row partial:

```erb
<% row_index = form.object.index_for(item) %>

<%= form.fields_for :rows, item, index: row_index do |row_form| %>
  <td>
    <%= row_form.hidden_field :id %>
    <%= row_form.text_field :name, data: { tree_view_interactive: true } %>
    <% item.errors.full_messages_for(:name).each do |message| %>
      <div class="tree-view-row-error"><%= message %></div>
    <% end %>
  </td>
  <td>
    <%= row_form.select :status, Document.statuses.keys, {}, data: { tree_view_interactive: true } %>
  </td>
  <td>
    <%= row_form.check_box :featured, data: { tree_view_interactive: true } %>
  </td>
  <td>
    <%= row_form.text_area :notes, rows: 2, data: { tree_view_interactive: true } %>
  </td>
<% end %>
```

各行に hidden ID を含めると、host app が submitted attributes を既存 record に対応付けやすくなります。ordering、authorization、permitted attributes は controller / Form Object 側の関心事として扱います。

## Form Object pattern

Form Object を TreeView が描画する row object にできます。TreeView の構造と表示に必要な `id`、`parent_id`、row partial が参照する値を公開していれば十分です。

```ruby
class DocumentTreeRowForm
  include ActiveModel::Model

  attr_accessor :id, :parent_id, :name, :status, :featured, :notes
end
```

row form object の collection から tree を組み立て、保存処理は Form Object が underlying record に対して行います。これにより、TreeView を persistence や validation rules から独立させられます。

## per-row edit pattern

通常は表示用 row を描画し、host app の action で特定の 1 行だけを editing partial に差し替えます。同時に 1 行だけ編集したい場合に向いています。

Action link は `row_actions_partial` に配置できます。

```erb
<%= link_to "Edit",
  edit_document_tree_row_path(item),
  data: { turbo_frame: dom_id(item, :tree_row), tree_view_interactive: true } %>

<%= link_to "Show", document_path(item), data: { tree_view_interactive: true } %>
<%= button_to "Delete", document_path(item), method: :delete, data: { tree_view_interactive: true } %>
```

edit route と Turbo response は host app が所有します。TreeView は、その結果として渡された render state や partial を表示するだけに留めます。

## inline editing layout の注意点

inline editing は、tree/table 行の中に form control が表示される状態を指します。TreeView は `row_partial`、`row_actions_partial`、row attributes を通じてその layout を支援します。TreeView は以下を決めません。

- どの行が現在 edit mode か
- 変更を即時保存するか、一括保存するか
- validation 失敗をどう表示するか
- optimistic update、autosave、rollback、retry を使うか
- copy/paste、undo/redo、spreadsheet 風 cell navigation をどう扱うか

bulk edit table では全行を input として描画して一括 submit します。per-row edit では、host app が 1 行を editing UI に差し替えるまで表示用 row を描画します。

## selection checkbox と business checkbox

TreeView selection checkbox は、行選択や bulk action のための checkbox です。TreeView の selection options で設定し、selection payload を submit します。

business checkbox は、host app 所有の row partial に置く通常の Rails form control です。`featured`、`active`、`billable` のような業務属性に使います。

name と params は分けてください。たとえば TreeView の行選択には `selected_documents[]` を使い、編集 form の `featured` は `document_tree_form[rows][0][featured]` のように別 params にします。

## interactive control と event 競合

行内の input、select、textarea、link、button が、意図せず row selection、drag、expand/collapse、keyboard behavior を起動しないようにします。

推奨 pattern:

- `data-tree-view-interactive="true"` のような interactive marker を control に付ける
- custom behavior がある場合は host app の Stimulus controller で propagation を止める
- TreeView selection checkbox と business form field を視覚的・意味的に区別する
- form control が多い画面では、行全体を click target にしない

これは planned interactive-control ignore marker と補完関係にあります。TreeView は行内の意図的な control を認識できるべきですが、編集 behavior 自体は host app が所有します。

## 未保存変更と row replacement のリスク

行内の編集 control は、通常の tree interaction によって削除・差し替えられる可能性があります。host app は、以下の場面で確認、抑止、保持のどれを行うか決めてください。

- dirty な行を collapse する
- dirty input を含む nested row がある状態で lazy loading が children を差し替える
- edit mode 中の行を Turbo Stream が置き換える
- filtering や windowed rendering によって dirty row が DOM から外れる
- 編集中に別 action が同じ row を変更する

TreeView は dirty state を追跡しません。未保存入力の喪失が問題になる画面では、host app の Stimulus behavior や server-side guard を追加してください。

## 関連ドキュメント

- [Cookbook](cookbook.md)
- [使い方](usage.md)
- [Selection](selection.md)
- [Rendering Boundaries](rendering-boundaries.md)
- [Host App Extension Points](host-app-extension-points.md)
