## バックアップ

```bash
docker-compose exec db bash
/# pg_dump -U app -v <database_name> -f /backup/`date "+%Y%m%d_%H%M"`.sql
```

## リストア

データベースを空の状態にしてから

```bash
docker-compose exec db bash
/# psql -U app <database_name> < /backup/yyyymmmdd_hhmm.sql
```
