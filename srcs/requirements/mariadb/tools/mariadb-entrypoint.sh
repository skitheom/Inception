#!/bin/bash
set -euo pipefail

# secrets -> env
if [ -z "${MYSQL_ROOT_PASSWORD:-}" ] && [ -f /run/secrets/db_root_password ]; then
  MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
  echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
fi
if [ -z "${MYSQL_PASSWORD:-}" ] && [ -f /run/secrets/db_user_password ]; then
  MYSQL_PASSWORD="$(cat /run/secrets/db_user_password)"
  echo "MYSQL_PASSWORD: $MYSQL_PASSWORD"
fi

DATADIR=${DATADIR:-/var/lib/mysql}
INIT_MARKER="$DATADIR/.initialized"

log() {
  printf "\033[1;35m[%s] [Entrypoint] %s\033[0m\n" "$(date +'%F %T')" "$*" >&2
}

# ディレクトリ作成
install -d -m 0755 -o mysql -g mysql /run/mysqld
install -d -m 0750 -o mysql -g mysql "$DATADIR"

if [[ ! -f $INIT_MARKER ]]; then
  : "${MYSQL_ROOT_PASSWORD:?}"
  : "${MYSQL_DATABASE:?}"
  : "${MYSQL_USER:?}"
  : "${MYSQL_PASSWORD:?}"

  # 所有権の保険
  if [ "$(stat -c %U "$DATADIR")" != "mysql" ]; then
    chown -R mysql:mysql "$DATADIR"
  fi

  # 物理初期化（必要な場合）
  [[ -d $DATADIR/mysql ]] || mysql_install_db --user=mysql \
    --datadir="$DATADIR" --skip-test-db --auth-root-authentication-method=normal

  # 一時サーバをソケットで起動（skip-networking で外部閉鎖）
  log "⏳ starting temp server..."
  mysqld --user=mysql --datadir="$DATADIR" --skip-networking \
         --socket=/run/mysqld/mysqld.sock &
  tmp_pid=$!
  trap 'kill -TERM "$tmp_pid" 2>/dev/null || true' EXIT

  # 起動待ち
  for i in {60..0}; do
    if mysqladmin --protocol=socket -uroot ping >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done
  if ! mysqladmin --protocol=socket -uroot ping >/dev/null 2>&1; then
    log "❌ temp server failed to start in time"; exit 1
  else
    log "🆗 temp server started"
  fi

  # 論理初期化
  log "🪄 applying users/db"
  mysql --protocol=socket -uroot <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

  # 一時サーバ停止＆マーカー作成
  mysqladmin --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
  trap - EXIT
  touch "$INIT_MARKER"
fi

log "✅ done"
exec "$@"