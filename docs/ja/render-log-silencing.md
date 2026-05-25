# Render log silencing

TreeView は、host app の log が `Rendered tree_view/...` で埋まりすぎないよう、helper 経由で描画する partial の log level を既定で下げます。

この設定が効くのは `tree_view_rows` など TreeView helper を通る partial render だけです。host app 全体の logger policy、business log、controller log、SQL log、custom instrumentation を肩代わりするものではありません。

## 既定挙動

- 既定値: `:warn`
- 効果: logger が対応していれば、TreeView は helper-rendered partial を `Rails.logger.silence(...)` で囲って描画する
- 適用範囲: TreeView helper 経由で描画される partial だけ

TreeView はこの値を `TreeView.configuration.render_log_level` から読みます。

## 設定方法

global 設定は `TreeView.configure` で変更します。

```ruby
TreeView.configure do |config|
  config.render_log_level = :info
end
```

使える symbol は次のとおりです。

- `:debug`
- `:info`
- `:warn`
- `:error`
- `:fatal`
- `:unknown`

対応する `Logger` 定数を渡しても構いません。TreeView 側で symbol に正規化します。

```ruby
TreeView.configure do |config|
  config.render_log_level = Logger::INFO
end
```

## `nil` を使う場面

Rails の render log をそのまま残したい場合は `render_log_level` に `nil` を指定します。

```ruby
TreeView.configure do |config|
  config.render_log_level = nil
end
```

この設定では TreeView の `logger.silence(...)` wrapper を使わず、partial render の log も host app の通常設定どおりに出ます。

## 設定値の選び方

- 通常の開発や運用で TreeView partial の render log が多すぎるなら `:warn`
- row partial の wiring や render flow を追いたいなら `:info` または `:debug`
- host app 側で独自の log 制御をしており、TreeView に介入させたくないなら `nil`

## 責務境界

TreeView が決めるのは、自分の helper-rendered partial の周辺で log を silence するかどうかだけです。

次は引き続き host app 側の責務です。

- Rails logger 設定
- formatter や tagged logging
- SQL / controller log の粒度
- business event の log
- request tracing や instrumentation

「TreeView partial の render log が見えない」「TreeView の render log だけ多い」と感じたら、host app 全体の logger policy を変える前に、まずこの設定を見直してください。
