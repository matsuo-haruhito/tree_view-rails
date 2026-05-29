# Render log silencing

このページは、古いリンクを壊さないための互換 alias です。

現在の render log documentation は [render log level](render-log-level.md) にあります。

`TreeView.configuration.render_log_level`、指定できる値、既定の `:warn`、Rails 標準の partial render log をそのまま出すための `nil` は、現行ページを参照してください。

TreeView が担当するのは、helper 経由で描画される TreeView partial の周辺だけ log level を下げることです。host app 全体の logger 設定、SQL / controller log、business-event logging、request tracing、custom instrumentation は host app 側の責務です。
