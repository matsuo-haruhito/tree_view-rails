# Public name decisions

このページでは、`0.1.0` 前に決めておく公開名の判断を記録します。

## `badge_builder` と `icon_builder`

row badge / marker 表示には `badge_builder` を推奨します。

`icon_builder` は既存caller向けのcompatibility aliasとして残します。内部的には、`badge_builder` が未指定の場合に `RenderContext#badge_builder` が `icon_builder` へfallbackすることがあります。ただし、新しいdocsやexamplesでは `icon_builder` を推奨しません。

将来のtoggle visualには、`toggle_icon_builder` のようなtoggle専用hookを使う方針です。TreeViewは引き続きtoggle link / button構造、ARIA属性、Turbo属性、keyboard behaviorを所有します。

## `row_event_payload_builder`

`row_event_payload_builder` はtransfer専用です。TreeViewがdrag/drop transfer dataとしてserializeするhash-like payloadを返します。

すべてのrow event向けの汎用payload hookではありません。drag/drop以外のrow eventが必要なhost appは、`row_data_builder` やrow partialでdata属性・Stimulus actionを追加してください。

## `loading_builder` と `error_builder`

`loading_builder` と `error_builder` はremote row state用のboolean predicateです。UIをbuildするhookではありません。

各callableは、そのrowを該当stateとして扱う場合にだけ `true` を返してください。rendererでは、それ以外の値はfalse相当として扱います。

## Accessibility semantics

TreeView は table-first with tree-like row controls として扱います。ARIA配置とrow selection semanticsは [Accessibility Semantics](accessibility-semantics.md) を参照してください。
