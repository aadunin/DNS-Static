# DNS Static for MikroTik

Автоматизированный проект для генерации MikroTik `.rsc` скриптов на основе актуального списка доменов из [AntiZapret](https://github.com/pumPCin/AntiZapret).

---

## 🔧 Как это работает

1. Репозиторий ежедневно скачивает свежий `hosts` из AntiZapret.
2. Если список доменов изменился — запускается генерация MikroTik-совместимого скрипта `dns-static.rsc`.
3. Скрипт публикуется в папке `mikrotik/` и может быть импортирован вручную или автоматически.

---

## 📦 Возможности

- Ежедневное сравнение `hosts` с предыдущей версией
- Генерация `.rsc` скрипта только при изменениях
- Поддержка импорта в MikroTik через `/import` или `fetch`
- История изменений `hosts` сохраняется в репозитории

---

## 📁 Структура проекта

| Путь | Назначение |
|------|------------|
| `.github/workflows/build-mikrotik.yml` | CI/CD: автоматическая сборка и публикация `.rsc` |
| `scripts/generate-rsc.sh` | Bash-скрипт генерации MikroTik DNS-правил |
| `hosts` | Последняя версия доменов от AntiZapret |
| `mikrotik/dns-static.rsc` | Сгенерированный скрипт для импорта в MikroTik |

---

## 🧪 Локальное тестирование

```bash
# Скачайте свежий hosts
curl -o hosts https://raw.githubusercontent.com/pumPCin/AntiZapret/main/hosts

# Запустите генерацию
bash scripts/generate-rsc.sh

# Проверьте результат
cat mikrotik/dns-static.rsc
```

---

## 📄 Импорт в MikroTik

### Вручную:
```routeros
/import file-name=dns-static.rsc
```

### Автоматически:
```routeros
:local oldSize 0
:if ([/file find name="dns-static.rsc"] != "") do={
  :set oldSize [:len [/file get dns-static.rsc contents]]
}
/tool fetch url="https://raw.githubusercontent.com/aadunin/DNS-Static/main/mikrotik/dns-static.rsc" dst-path=dns-static.rsc mode=https
:local newSize [:len [/file get dns-static.rsc contents]]
:if ($oldSize != $newSize) do={
  /import file-name=dns-static.rsc
  :log info "DNS Static: Import complete"
} else={
  :log info "DNS Static: No changes, skipping import"
}
```

---

## 🤝 Contributing

Добро пожаловать! Если вы хотите внести вклад в проект — это здорово. Вот как можно помочь:

- 📥 Сообщить об ошибке через Issues
- 🛠 Предложить улучшения или новые функции
- 📄 Улучшить документацию или README
- 🔧 Оптимизировать скрипт или workflow

---

## 🚀 Как начать

```bash
# Сделайте форк репозитория
# Создайте новую ветку
git checkout -b feature/my-improvement

# Внесите изменения и закоммитьте
git commit -m "Добавил улучшение"

# Откройте Pull Request
```

Пожалуйста, следуйте стилю проекта и описывайте изменения чётко.

---

## 📜 License

Этот проект распространяется под лицензией MIT. Вы можете свободно использовать, копировать, изменять и распространять код, при условии сохранения уведомления об авторстве.

Полный текст лицензии доступен в файле `LICENSE`.

---

## 👤 Автор

Alexander Dunin  
Проект основан на идеях [AntiZapret](https://github.com/pumPCin/AntiZapret), переработан для автоматического применения на MikroTik.

📄 [Скачать актуальный dns-static.rsc](https://github.com/aadunin/DNS-Static/blob/main/mikrotik/dns-static.rsc)
