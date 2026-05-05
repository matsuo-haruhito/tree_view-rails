# Windowed Rendering

`TreeView::VisibleRows` で得られる表示対象行に対して `offset` / `limit` を適用し、必要な範囲だけを描画する opt-in API です。

大量ノードを一度にHTMLへ展開したくない画面で使います。既存の recursive rendering は従来どおり既定の描画方式として残り、`window:` を指定した場合だけ windowed rendering が有効になります。

## 基本例

```erb
<tbody>
  <%= tree_view_rows(
        render_state,
        window: {
          offset: params.fetch(:offset, 0).to_i,
          limit: 100
        }
      ) %>
</tbody>
```

`window:` には Hash-like object を渡します。

| key | 説明 |
|---|---|
| `offset` | 表示対象行の先頭index。`0` 以上のInteger |
| `limit` | 描画する最大行数。正のInteger |

`offset` / `limit` は、`VisibleRows` が現在の開閉状態・描画範囲を反映した後の一次元配列に対して適用されます。

## navigation metadata

ページングUIや「さらに読み込む」UIを作る場合は、`tree_view_window` helper で `TreeView::RenderWindow` を取得できます。

```erb
<% window = tree_view_window(render_state, offset: params.fetch(:offset, 0).to_i, limit: 100) %>

<tbody>
  <%= tree_view_rows(render_state, window: window) %>
</tbody>

<% if window.previous? %>
  <%= link_to "前へ", url_for(offset: window.previous_offset) %>
<% end %>

<% if window.next? %>
  <%= link_to "次へ", url_for(offset: window.next_offset) %>
<% end %>
```

`RenderWindow` は以下を提供します。

| メソッド | 説明 |
|---|---|
| `rows` / `to_a` | window内の `VisibleRows::Row` 配列 |
| `total_count` | window適用前の表示対象行数 |
| `start_index` | windowの開始index |
| `end_index` | windowの終了index |
| `previous?` | 前のwindowが存在するか |
| `next?` | 次のwindowが存在するか |
| `previous_offset` | 前windowのoffset。存在しない場合は `nil` |
| `next_offset` | 次windowのoffset。存在しない場合は `nil` |

## 開閉状態との関係

Windowed rendering は、`RenderState` の以下を反映した後に window を切ります。

- `initial_state`
- `max_initial_depth`
- `max_render_depth`
- `max_leaf_distance`
- `expanded_keys`
- `collapsed_keys`

そのため、閉じている node の子孫は window 対象に含まれません。特定の node を window 内に表示したい場合は、その祖先を `expanded_keys` に含めてください。

## 既存描画との違い

通常の `tree_view_rows(render_state)` は recursive partial rendering です。root から順に子孫partialを再帰的に描画します。

`tree_view_rows(render_state, window: { offset:, limit: })` は flat rendering です。`VisibleRows` で現在表示される行を一次元化し、指定された範囲だけを `tree_view/tree_window_row` partial で描画します。

表示される row markup は通常描画と同じ構造を保ちます。

- row partial
- row actions partial
- selection cell
- toggle cell
- badge / icon / depth label
- row class / row data
- lazy loading data
- aria attributes

## 責務範囲

TreeView gem は、現在の表示行をflattenし、`offset` / `limit` の範囲だけを描画するところまでを提供します。

以下は host app 側の責務です。

- scroll位置から `offset` を決めること
- infinite scroll / virtual scroll のJavaScript制御
- URL query、session、localStorageなどへの window state 保存
- server-side pagination や cursor strategy
- DOM上の spacer row、placeholder、scroll height 調整

この境界により、TreeView gem はRails helperとして安全にopt-inできる windowed rendering を提供しつつ、画面ごとのUXやデータ取得戦略は host app 側で選べます。
