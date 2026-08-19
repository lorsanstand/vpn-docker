FROM teddysun/xray:latest

USER root

# Устанавливаем curl и jq для работы со ссылкой подписки
RUN apk add --no-cache curl jq tzdata

COPY entrypoint.sh /entrypoint.sh

ENV CONFIG_URL="URL-VPN"

ENTRYPOINT ["/entrypoint.sh"]
