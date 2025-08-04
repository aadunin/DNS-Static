# DNS Static for MikroTik

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

Автоматизированный проект для генерации MikroTik `.rsc` скриптов на основе актуального списка доменов из [AntiZapret](https://github.com/AntiZapret/antizapret).

## 📦 Возможности

- Ежедневное сравнение `hosts` с предыдущей версией
- Генерация `.rsc` скрипта только при изменениях
- Поддержка импорта в MikroTik через `import` или `fetch`
- История изменений `hosts` сохраняется в репозитории

## ⚙️ Использование

1. Скачайте актуальный `.rsc` из [Actions → Build Mikrotik RSC](https://github.com/aadunin/DNS-Static/actions)
2. Импортируйте в MikroTik:
   ```shell
   /import file-name=dns-static.rsc
   ```
   или через fetch:
   ```shell
   /tool fetch url=https://raw.githubusercontent.com/aadunin/DNS-Static/main/mikrotik/dns-static.rsc
   /import file-name=dns-static.rsc
   ```

## 🔄 Автоматизация

- GitHub Actions запускается при изменении `hosts`
- `.rsc` пересобирается и пушится в `mikrotik/`
- История `hosts` сохраняется для анализа изменений

## 📁 Структура

```
.github/workflows/       # CI/CD pipeline
hosts/                   # История доменов
mikrotik/dns-static.rsc  # Сгенерированный скрипт
```

## 🤝 Contributing

Добро пожаловать! Если вы хотите внести вклад в проект — это здорово.

Вот как можно помочь:

- 📥 Сообщить об ошибке через [Issues](https://github.com/aadunin/DNS-Static/issues)
- 🛠 Предложить улучшения или новые функции
- 📄 Улучшить документацию или README
- 🔧 Оптимизировать скрипт или workflow

### 🚀 Как начать

1. Сделайте форк репозитория
2. Создайте новую ветку: `git checkout -b feature/my-improvement`
3. Внесите изменения и закоммитьте: `git commit -m "Добавил улучшение"`
4. Откройте Pull Request

> Пожалуйста, следуйте стилю проекта и описывайте изменения чётко.

## 📜 License

Этот проект распространяется под лицензией **MIT**.

Вы можете свободно использовать, копировать, изменять и распространять код, при условии сохранения уведомления об авторстве.

Полный текст лицензии доступен в файле [`LICENSE`](LICENSE).

## 👤 Автор

- [Alexander Dunin](https://github.com/aadunin)

---

> Проект основан на идеях [AntiZapret](https://github.com/AntiZapret/antizapret), переработан для автоматического применения на MikroTik.
