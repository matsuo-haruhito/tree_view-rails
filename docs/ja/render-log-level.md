# render log level

TreeView は `tree_view_rows` などの Rails helper 経由で組み込み partial を描画します。
このとき Rails は host application のログに `Rendered tree_view/...` のような partial render log を info level で出すことがあります。

TreeView は既定で、helper 経由の TreeView partial render log を `:warn` で抑制します。これにより、host application のログに TreeView 内部の render log が大量に混ざることを避けます。

```ruby
TreeView.configure do |config|
  config.render_log_level = :warn
end
```

## level を変更する

host app 側で別の閾値にしたい場合は、標準の Ruby logger level 名を指定します。

```ruby
TreeView.configure do |config|
  config.render_log_level = :error
end
```

指定できる値は以下です。

- `:debug`
- `:info`
- `:warn`
- `:error`
- `:fatal`
- `:unknown`

`Logger::ERROR` のような Ruby `Logger` level constant も指定できます。指定した場合は対応する symbol 名に正規化されます。

## TreeView render log の抑制を無効化する

Rails 標準の partial render log をそのまま出したい場合は `nil` を指定します。

```ruby
TreeView.configure do |config|
  config.render_log_level = nil
end
```

この設定が包むのは TreeView helper 経由で描画される partial だけです。host application 全体の `Rails.logger.level` は変更しません。
