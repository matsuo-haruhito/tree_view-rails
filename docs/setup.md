# Setup

## Initial Setup

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

## Login

seed で以下のユーザが作られます。

- 管理者
  - username: `admin`
  - password: `admin`
- 一般ユーザ
  - username: `user1` から `user10`
  - password: username と同じ

## Demo Data

### Item

- `db/seeds/data/item.csv`
- 重複名を許容しない
- ルートごとに自己完結した構成

### Machine demo

- `db/seeds/data/machine_demo.csv`
- `Machine -> Unit -> Part -> Material`
- `DEMO:` プレフィックス付き

## Tests

```bash
docker compose exec app bundle exec rspec \
  spec/helpers/items_helper_spec.rb \
  spec/views/items/index.html.slim_spec.rb \
  spec/requests/items_spec.rb \
  spec/requests/machines_spec.rb \
  spec/system/tree_view_screenshots_spec.rb
```

## Screenshots

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

## Docker Notes

app コンテナには、system spec とスクリーンショット生成のために以下を入れています。

- `chromium`
- `chromium-chromedriver`
- `font-noto-cjk`

Dockerfile を更新した後は再 build が必要です。

```bash
docker compose build app
docker compose up -d app
```
