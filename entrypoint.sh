#!/bin/sh
set -e

update_config() {
  echo "[$(date)] Fetching Cats VPN subscription..."
  curl -sSL \
    -H "User-Agent: Happ/3.2.0" \
    -H "x-hwid: 12345678-1234-1234-1234-123456789abc" \
    "$CONFIG_URL" -o /tmp/cats_sub.json

  if jq -e 'if type=="array" and length > 0 then true else false end' /tmp/cats_sub.json > /dev/null 2>&1; then
    jq '.[0] | .inbounds = [.inbounds[] | .listen = "0.0.0.0"]' /tmp/cats_sub.json > /etc/xray/config.json
    rm -f /tmp/cats_sub.json
    echo "[$(date)] Config updated successfully."
  else
    echo "[$(date)] Error: Invalid subscription response."
    rm -f /tmp/cats_sub.json
  fi
}

# Первичное скачивание конфига
update_config

# Настройка автообновления каждые 3 часа внутри контейнера
echo "0 */3 * * * /entrypoint.sh --cron" > /etc/crontabs/root
crond -b -l 8

if [ "$1" = "--cron" ]; then
  # Если вызван из cron — просто обновляем и мягко перезагружаем Xray
  update_config
  kill -s SIGHUP $(pidof xray) 2>/dev/null || true
  exit 0
fi

# Запуск Xray
exec xray run -c /etc/xray/config.json
