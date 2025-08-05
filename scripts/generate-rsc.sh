#!/usr/bin/env bash
set -euo pipefail

# Гарантируем папку вывода
mkdir -p mikrotik
output="mikrotik/dns-static.rsc"

# Сброс предыдущего скрипта
echo '/ip dns static remove [find address-list="autohost"]' > "$output"

# Правильное объявление массива + счетчика
declare -A seen
cnt=0

# Читаем очищенный от комментариев список hosts
while read -r ip rest; do
  [[ "$ip" =~ ^#|^$ ]] && continue
  for domain in $rest; do
    # отфильтровываем localhost-* и broadcasthost
    [[ "$ip" == "127.0.0.1" && "$domain" =~ ^(localhost|local|localhost.localdomain)$ ]] && continue
    [[ "$ip" == "255.255.255.255" && "$domain" == "broadcasthost" ]] && continue

    # незаполненный адрес 0.0.0.0 мапим на TEST-IP
    ip_addr=$([[ "$ip" == "0.0.0.0" ]] && echo "192.0.2.1" || echo "$ip")
    key="$ip_addr|$domain"

    # добавляем только новые пары IP|домен
    if [[ -z "${seen[$key]+x}" ]]; then
      echo "/ip dns static add name=$domain address=$ip_addr ttl=1d address-list=autohost" >> "$output"
      seen[$key]=1
      ((cnt++))
    fi
  done
done < <(grep -Ev '^(#|$)' hosts)

# Логируем и экспортируем count в GitHub Actions
echo "/log info \"[update-hosts] Added $cnt entries\"" >> "$output"
echo "cnt=$cnt" >> "$GITHUB_ENV"

# Если ничего не добавилось — чистим артефакты и выходим
if [[ "$cnt" -eq 0 ]]; then
  echo "No new domains found. Skipping RSC generation."
  > mikrotik/new-domains.txt
  > "$output"
  exit 0
fi

# Иначе сохраняем список новых доменов
grep '^/ip dns static add name=' "$output" > mikrotik/new-domains.txt

# Обновляем CHANGELOG.md
touch CHANGELOG.md
DATE=$(date +'%Y-%m-%d')
TAG="v$(date +'%Y%m%d')"

{
  echo "## [$TAG] — $DATE"
  echo "Добавлено $cnt записей"
  sed 's/^/- /' mikrotik/new-domains.txt
  echo ""
} >> CHANGELOG.md

# Фиксим коммит с новым changelog
git add CHANGELOG.md
git commit -m "Update CHANGELOG for $TAG"
