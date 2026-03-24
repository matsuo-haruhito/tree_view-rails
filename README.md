# TurboStream TreeView Test

Rails + Turbo Stream でツリー表示 UI を試作しているサンプルアプリです。  
将来的な GEM 化を見据えつつ、まずはアプリ内で `TreeView` の責務分離を整えることを目的にしています。

## 何があるか

このリポジトリには、主に 2 つのサンプル画面があります。

### `items`
- 自己参照モデル `Item.parent_item_id` をそのままツリー表示する画面
- Turbo Stream による開閉
- 右クリックメニューによる子系統の開閉
- Turbo Frame ベースの簡素 CRUD
- `すべて広げる` / `すべて畳む`
- root 単位のページネーション

### `machines`
- `Machine / Unit / Part / Material` を 1 本のツリーとして表示する画面
- `TreeView::GraphAdapter` を使った異種ノード混在デモ
- Turbo Stream による開閉
- Turbo Frame ベースの簡素 CRUD
- `すべて広げる` / `すべて畳む`
- root 単位のページネーション

## 現在の設計方針

- `TreeView` コアは木構造ロジックに寄せる
- 画面固有の UI、Turbo、CRUD は sample app 側に置く
- path helper の抽象化よりも、木構造ロジックと行描画の分離を優先する
- GEM 本体に Turbo broadcast や CRUD は持ち込まない

詳細な作業方針は [context.md](./context.md) に置いています。

## 主な実装要素

- `app/lib/tree_view/tree.rb`
  - 親子解決、子孫数集計、ルート並び替え
- `app/lib/tree_view/traversal.rb`
  - 子孫 ID の収集
- `app/lib/tree_view/graph_adapter.rb`
  - 異種ノード混在ツリーの接続
- `app/lib/tree_view/ui_config.rb`
  - DOM ID と開閉パスの注入
- `app/views/items/_tree_row.html.slim`
  - ツリー行の共通描画
- `app/views/items/_tree_toggle_content.html.slim`
  - 先頭セルの枝・開閉ボタン・隠れ件数

## セットアップ

### 1. 初回セットアップ

```bash
git clone <repository-url>
cd TurboStream-TreeViewTest
cp .env.example .env
docker compose build
docker compose run --rm app bash
bundle install
yarn
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
exit
docker compose up -d
```

開発用にまとめると、従来どおり次の流れです。

```bash
git clone <url>
cd <name>
cp .env.example .env
docker compose build
docker compose run --rm app bash
bundle install
yarn
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
exit
docker compose up
```

### 2. ログイン

seed で以下のユーザが作られます。

- 管理者
  - username: `admin`
  - password: `admin`
- 一般ユーザ
  - username: `user1` から `user10`
  - password: username と同じ

## デモデータ

### Item
- `db/seeds/data/item.csv`
- 重複名を許容しない
- ルートごとに自己完結したデモ構成を優先

### Machine demo
- `db/seeds/data/machine_demo.csv`
- `Machine -> Unit -> Part -> Material` の混在ツリー
- `DEMO:` プレフィックス付きで既存データと見分けやすい

## 画面で試せること

### 共通
- ツリーの展開 / 折りたたみ
- `すべて広げる` / `すべて畳む`
- 枝付きの階層表示
- 右クリックメニューによる子系統の開閉
- Turbo Stream による画面 refresh サンプル
- root 単位のページネーション

### CRUD
- `Item`, `Machine`, `Unit`, `Part`, `Material` の新規作成
- 既存ノードに対する子追加
- 編集
- 削除
- フォームは Turbo Frame ベースのモーダル表示

## テスト

### 主要 spec

```bash
docker compose exec app bundle exec rspec \
  spec/helpers/items_helper_spec.rb \
  spec/views/items/index.html.slim_spec.rb \
  spec/requests/items_spec.rb \
  spec/requests/machines_spec.rb \
  spec/system/tree_view_screenshots_spec.rb
```

### スクリーンショット生成

README 用の画面キャプチャは system spec で生成できます。

```bash
docker compose exec app bin/capture_tree_view_screenshots
```

生成先:

- `tmp/screenshots/items-tree.png`
- `tmp/screenshots/machines-tree.png`

system spec 実行時には、確認用として各 example の最新スクリーンショットも上書き保存されます。

- `tmp/screenshots/treeview_screenshots_items.png`
- `tmp/screenshots/treeview_screenshots_machines.png`

## Docker まわり

app コンテナには、system spec とスクリーンショット生成のために以下を入れています。

- `chromium`
- `chromium-chromedriver`
- `font-noto-cjk`

そのため Dockerfile を更新した後は、再 build が必要です。

```bash
docker compose build app
docker compose up -d app
```

## リリース手順

元の README にあったコマンドベースの手順は残したほうがよいので、ここに整理して残します。

### Production

```bash
git clone <url>
cd <name>
cp .env.example .env
sed -i -e 's/COMPOSE_FILE=.*/COMPOSE_FILE=docker-compose.production.yml/' .env
sed -i -e 's/RAILS_ENV=.*/RAILS_ENV=production/' .env
sed -i -e "s/SECRET_KEY_BASE=.*/SECRET_KEY_BASE=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 128)/" .env
sed -i -e "s/APP_UID=.*/APP_UID=$(id -u)/" .env
sed -i -e "s/APP_GID=.*/APP_GID=$(id -g)/" .env
docker compose build
docker compose run --rm app bash
bundle install --without test development
yarn
bin/rails db:create
bin/rails db:migrate
bin/rails assets:precompile
exit
docker compose up -d
```

### HTTPS 対応

```bash
mkdir https-portal
cd https-portal
vim docker-compose.yml
docker compose up -d
```

```yml
version: '3'
services:
  https-portal:
    image: steveltn/https-portal:1.21.1
    ports:
      - '80:80'
      - '443:443'
    environment:
      STAGE: production
      DOMAINS: 'sakaikouki-fego.work -> http://app:3035'
    volumes:
      - https-portal:/var/lib/https-portal
    networks:
      - sakaikouki-order-server_default
    restart: always
volumes:
  https-portal:
networks:
  sakaikouki-order-server_default:
    external: true
```

## 現時点の注意

- `Kaminari` は全ノードではなく root collection にだけ適用する方針です
- README へのスクリーンショット掲載手順はまだ整理途中です
- 現状は sample app 優先で、GEM API はまだ固定していません

## ライセンス

未整理です。GEM 化時に合わせて明記してください。
