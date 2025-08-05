#!/usr/bin/env bash
set -euo pipefail

# При ошибке выводим строку и команду
trap 'echo "❌ Ошибка в строке ${LINENO}: $BASH_COMMAND" >&2' ERR

# Проверяем, что файл hosts существует и не пуст
if [[ ! -s hosts ]]; then
  echo "ERROR: hosts file is missing or empty" >&2
  exit 1
fi

# Создаём каталог и инициализируем output
mkdir -p mikrotik
output="mikrotik/dns-static.rsc"
echo '/ip dns static remove [find address-list="autohost"]' > "$output"

declare -A seen
cnt=0

# Генерируем записи из файла hosts
while read -r ip rest; do
  [[ "$ip" =~ ^#|^$ ]] && continue

  for domain in $rest; do
    [[ "$ip" == "127.0.0.1" && "$domain" =~ ^(localhost|local|localhost\.localdomain)$ ]] && continue
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

# Лог в RSC и экспорт счётчика в окружение Actions
echo "/log info \"[update-hosts] Added $cnt entries\"" >> "$output"
echo "cnt=$cnt" >> "$GITHUB_ENV"

# Если новых записей нет — очищаем и выходим
if [[ "$cnt" -eq 0 ]]; then
  echo "No new domains found. Skipping RSC generation."
  > mikrotik/new-domains.txt
  > "$output"
  exit 0
fi

# Сохраняем список новых доменов
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

# Коммитим CHANGELOG.md
git add CHANGELOG.md
git commit -m "Update CHANGELOG for $TAG"
