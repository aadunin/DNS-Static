#!/bin/bash
set -euo pipefail

mkdir -p mikrotik
output="mikrotik/dns-static.rsc"

# Очистка предыдущих записей
echo '/ip dns static remove [find address-list="autohost"]' > "$output"

# Правильное объявление: массив и переменная отдельно
declare -A seen
cnt=0

# Обработка входного файла hosts
while read -r ip rest; do
  [[ "$ip" =~ ^#|^$ ]] && continue
  for domain in $rest; do
    [[ "$ip" == "127.0.0.1" && "$domain" =~ ^(localhost|local|localhost.localdomain)$ ]] && continue
    [[ "$ip" == "255.255.255.255" && "$domain" == "broadcasthost" ]] && continue

    ip_addr=$([[ "$ip" == "0.0.0.0" ]] && echo "192.0.2.1" || echo "$ip")
    key="$ip_addr|$domain"

    if [[ -z "${seen[$key]+x}" ]]; then
      echo "/ip dns static add name=$domain address=$ip_addr ttl=1d address-list=autohost" >> "$output"
      seen[$key]=1
      ((cnt++))
    fi
  done
done < <(grep -Ev '^(#|$)' hosts)

# Лог MikroTik и экспорт cnt в окружение для Actions
echo "/log info \"[update-hosts] Added $cnt entries\"" >> "$output"
echo "cnt=$cnt" >> "$GITHUB_ENV"

# Если нет новых записей — очищаем артефакты и выходим
if [[ "$cnt" -eq 0 ]]; then
  echo "No new domains found. Skipping RSC generation."
  > mikrotik/new-domains.txt
  > "$output"
  exit 0
fi

# Иначе сохраняем список новых доменов
grep '^/ip dns static add name=' "$output" > mikrotik/new-domains.txt

# Обновляем CHANGELOG
touch CHANGELOG.md
DATE=$(date +'%Y-%m-%d')
TAG="v$(date +'%Y%m%d')"

{
  echo "## [$TAG] — $DATE"
  echo "Добавлено $cnt записей"
  sed 's/^/- /' mikrotik/new-domains.txt
  echo ""
} >> CHANGELOG.md

# Фиксим коммит
git add CHANGELOG.md
git commit -m "Update CHANGELOG for $TAG"
