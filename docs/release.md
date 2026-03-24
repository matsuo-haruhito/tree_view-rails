# Release

## Production

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

## HTTPS

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
