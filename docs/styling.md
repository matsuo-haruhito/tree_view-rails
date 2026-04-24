# Styling

## Basic Policy

TreeView の見た目は、GEM 側が最低限のベース CSS を提供し、導入先アプリ側で上書きする前提です。

現時点では、見た目の設定値を `UiConfig` に入れる方針は取っていません。  
見た目を変えたい場合は、host app 側の CSS でクラスを上書きする想定です。

## Base Stylesheet

TreeView 固有のスタイルは `tree_view.scss` にあります。

host app 側では、application stylesheet から読み込む想定です。

```scss
@import "./tree_view";
```

## Main CSS Classes

主に触ることになるクラスは次です。

- `.tree-toggle-cell`
  - 先頭セル全体
- `.tree-toggle`
  - 枝とボタンをまとめるコンテナ
- `.tree-toggle__branches`
  - 枝表示の領域
- `.tree-toggle__branch-slot`
  - 深さごとの枝スロット
- `.tree-toggle__control`
  - ボタンと hidden count の領域
- `.tree-toggle__action`
  - 展開 / 折りたたみボタン
- `.tree-toggle__level`
  - 葉ノードなどで表示するレベル表示
- `.tree-toggle__hidden-count`
  - hidden count の見た目
- `.tree-context-menu`
  - 右クリックメニュー全体
- `.tree-context-menu__item`
  - メニュー項目

## Common Adjustments

### Indent Width

枝の横幅は `.tree-toggle__branch-slot` の `width` / `min-width` で調整できます。

```scss
.tree-toggle__branch-slot {
  width: 1.6rem;
  min-width: 1.6rem;
}
```

### Branch Line Color

枝線の濃さは `background-color` を上書きします。

```scss
.tree-toggle__branch-slot.has-line::before,
.tree-toggle__branch-slot.is-current::before,
.tree-toggle__branch-slot.is-current::after {
  background-color: rgba(0, 0, 0, 0.25);
}
```

### Toggle Button Size

ボタン幅や padding は `.tree-toggle__action` を上書きします。

```scss
.tree-toggle__action {
  min-width: 3.2rem;
  padding: 0.1rem 0.4rem;
}
```

### Hidden Count

hidden count のサイズや色は `.tree-toggle__hidden-count` で調整できます。

```scss
.tree-toggle__hidden-count {
  min-width: 1.6rem;
  background-color: #f8f9fa;
  color: #343a40;
}
```

### Context Menu

右クリックメニューの色や影は `.tree-context-menu` と `.tree-context-menu__item` を上書きします。

```scss
.tree-context-menu {
  border-radius: 0.75rem;
  box-shadow: 0 1rem 2rem rgba(0, 0, 0, 0.2);
}

.tree-context-menu__item:hover {
  background-color: #eef2f7;
}
```

## Boundary

GEM 側で提供するのは、あくまで TreeView の最低限の見た目とクラス構造です。  
ブランドカラー、余白設計、hover 感、テーブル全体の見え方などは host app 側で調整する前提です。

つまり、

- TreeView 固有 UI の骨格は GEM 側
- 最終的な見た目の仕上げは host app 側

という分担になります。
