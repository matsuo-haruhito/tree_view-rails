# Public Setup Surface

persisted-state install generator は public setup entrypoint です。

- `bin/rails generate tree_view:state:install`
- `bin/rails generate tree_view:state:install User`

`config/public_api_manifest.yml` の machine-readable setup-generator contract は、generator 名、任意の owner 引数、生成先 path を追跡します。

生成先 path は setup surface の一部です。

- `db/migrate/*_create_tree_view_states.rb`
- `app/models/tree_view_state.rb`
- `app/models/concerns/tree_view_state_owner.rb`

この path-level contract は、migration schema や生成ファイル内容そのものを固定するものではありません。この generator は persisted-state 用 migration、model、owner concern を作成する入口として使い、生成後のファイルは host app 側で確認してください。

storage ownership、認可、保存タイミング、controller action、UI wiring は host app 側の責務です。詳しくは [Persisted State](persisted-state.md) を参照してください。
