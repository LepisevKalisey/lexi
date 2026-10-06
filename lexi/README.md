# lexi/ — устройство LEXI

LEXI — расширение поверх Chatwoot fazer.ai. Весь код LEXI лежит в `lexi/` и `spec/lexi/`. Ядро Chatwoot меняется в трёх местах — это «патч ядра», ниже. Каталог `enterprise/` принадлежит Chatwoot Inc. Его нет ни в рабочей копии, ни в образе LEXI.

## Правила чистой реализации

1. **Без закрытого кода.** Рабочая копия — без `enterprise/`, см. «Клонирование». Кто пишет код LEXI, включая ИИ-агентов, этот каталог не открывает. CI (`lexi-ci.yml`, задача clean-room) падает, если коммит LEXI затрагивает `enterprise/` или `spec/enterprise/`.
2. **Спецификация — только из MIT-источников:** API-клиенты и экраны фронтенда (`app/javascript/dashboard/api/*.js`, `routes/dashboard/settings/*`), схема базы `db/schema.rb`, фабрики `spec/factories`, `swagger/`, публичная документация Chatwoot.
3. **Тесты upstream — приёмочные (L-013).** `spec/enterprise/` лежит вне `enterprise/` и распространяется под MIT. Тесты SLA, ролей и аудита оттуда LEXI обязан проходить без изменений. Список — `spec/lexi/upstream_specs.txt`. В рабочей копии из `spec/enterprise/` есть только файлы из этого списка.
4. **Код из чужих форков** берём, только если механическая проверка сходства с `enterprise/` чистая. Форки с перенесённым закрытым кодом не открываем: Brandpatch, samfromlv, Hermes-SRV и подобные.
5. **Имена классов, маршруты и таблицы — как у upstream.** Тогда фронтенд работает без правок, а установку можно перевести на официальный Chatwoot и обратно без переноса данных.

## Клонирование

```bash
git clone --filter=blob:none --no-checkout https://github.com/LepisevKalisey/lexi.git
cd lexi
git config core.autocrlf false
git sparse-checkout init --no-cone
printf '/*\n!/enterprise/\n!/spec/enterprise/\n' > .git/info/sparse-checkout
git checkout main
bash lexi/bin/sparse-checkout   # добавляет тесты из spec/lexi/upstream_specs.txt
git remote add fazer https://github.com/fazer-ai/chatwoot.git
git remote add chatwoot https://github.com/chatwoot/chatwoot.git
```

Шаблоны записываются прямо в `.git/info/sparse-checkout`. В Git Bash на Windows команда `git sparse-checkout set '/*'` превращает `/` в путь Windows, и исключение не срабатывает. После правки `upstream_specs.txt` снова запустите `bash lexi/bin/sparse-checkout`.

## Стенд в GitHub Codespaces (L-014)

```bash
gh codespace create -R LepisevKalisey/lexi -b main -m standardLinux32gb \
  --devcontainer-path .devcontainer/lexi/devcontainer.json
gh codespace ssh -c <имя> -- -N -L 3000:127.0.0.1:3000   # сайт стенда — http://localhost:3000
```

Конфиг `.devcontainer/lexi` берёт стек Chatwoot (приложение, PostgreSQL с pgvector, Redis, Mailhog). В отличие от конфига fazer.ai, порты остаются приватными, а `enterprise/` удаляется из рабочей копии (`lexi/bin/codespace-setup`). Приложение стартует при каждом запуске codespace (`lexi/bin/codespace-start`). Вход — пользователь из `db/seeds.rb`. Неиспользуемый codespace останавливается сам через 30 минут.

Особенности:
- **Свой образ.** Образ приложения собирается из `.devcontainer/lexi/Dockerfile`, база та же — `chatwoot_codespace`. В базовом образе устарел ключ apt-источника GitHub CLI: без правки не ставится SSH-сервер, и Codespaces откатывается на запасной контейнер.
- **Вход по SSH.** `gh codespace ssh` использует ключ `~/.ssh/codespaces.auto`. Если `gh` его не создал (так было на Windows), создайте вручную: `ssh-keygen -t ed25519 -N "" -f ~/.ssh/codespaces.auto`.
- **Журналы.** Создание codespace — `/workspaces/.codespaces/.persistedshare/creation.log`. Ручной перезапуск настройки — `/tmp/lexi-setup.log`.
- **Туннель, а не `ports forward`.** После перезапуска codespace `gh codespace ports forward` получает `Connection refused`, хотя приложение работает. SSH-туннель через сервер в контейнере доходит до порта всегда.
- **Без дев-сервера Vite.** Через проброшенный порт тысячи модулей Vite грузятся минутами. Поэтому фронтенд собирается один раз (`bin/vite build` в `codespace-setup`), а запускаются только Rails и Sidekiq (`lexi/Procfile.stand`).

## Как LEXI подключается к ядру

**Патч ядра** — только вставки, без правки строк upstream:

| Файл | Что добавлено |
|---|---|
| `lib/chatwoot_app.rb` | `lexi?` и `lexi_extensions`: `extensions` возвращает `[enterprise?] lexi [custom]` |
| `config/application.rb` | загрузка `lexi/config/application.rb`: пути `lexi/app/*` и `lexi/lib`, представления, инициализаторы, переводы |
| `tailwind.config.js` | `./lexi/app/views/**/*.erb` в `content` |

**Точки подмешивания.** Около 115 классов ядра вызывают `prepend_mod_with('Имя')`. LEXI определяет модуль `Lexi::Имя` в `lexi/app/...`, загрузчик подмешивает его сам. У классов без такой точки модуль подмешивается в `lexi/config/initializers/lexi.rb` через `to_prepare`. `spec/lexi/lexi_extension_points_spec.rb` проверяет, что все подмешивания на месте.

**Маршруты.** Маршруты SLA, ролей, аудита, SAML и ёмкости агентов уже объявлены в ядре без условий, нет только контроллеров. LEXI кладёт контроллеры с теми же именами классов в `lexi/app/controllers/`. Маршруты, которые ядро объявляет только при `enterprise?` (звонки, мониторы, аналитика кампаний), LEXI подключит из `lexi/config/routes.rb`, когда до них дойдёт.

**Фронтенд.** Экраны SLA, ролей и аудита открываются, только если установка — enterprise и её план не `community`. `Lexi::DashboardController` сообщает фронтенду `IS_ENTERPRISE=true` и план `lexi`. План в базе не меняется: по нему бэкенд, например, решает, показывать ли вход через SAML. Что видит каждый аккаунт, решают флаги аккаунта.

**Супер-админка.** На странице аккаунта есть поле «Функции» — галочки флагов. Их сохраняет контроллер ядра `SuperAdmin::AccountsController`. Флаги по умолчанию для новых аккаунтов задаёт `ACCOUNT_LEVEL_FEATURE_DEFAULTS`, это механизм ядра.

**Телеметрия.** По умолчанию `DISABLE_TELEMETRY=true`, вернуть отправку можно через `LEXI_TELEMETRY=true`. В тестах поведение как у upstream. Chatwoot Hub продолжает пересылать пуши в официальные мобильные приложения.

## Что фронтенд делает на enterprise-установке и как LEXI это закрывает

| Место | Что происходит | В LEXI |
|---|---|---|
| `CopilotContainer`, каждая страница | запрос списка ассистентов Captain | заглушка: пустой список (`Api::V1::Accounts::Captain::AssistantsController#index`) |
| Пункт меню «Звонки» | маршрут требует флаг `channel_voice` | скрыт, пока флаг выключен; бэкенда звонков нет, флаг не включать |
| Справочный центр, «Перевести» статьи | видно при флаге `captain_tasks`; ядро отвечает `501` | известное ограничение до второй волны |
| Аналитика WhatsApp-кампаний | кнопка у завершённых кампаний; маршрута в Community нет | известное ограничение до второй волны |
| Экраны Captain | открываются только с флагом `captain_integration` | флаг не включать |

## Структура

```
lexi/
  config/application.rb       пути, представления, инициализаторы, переводы
  config/initializers/        подмешивания через to_prepare
  config/locales/             строки LEXI (en, ru)
  lib/lexi.rb                 модуль Lexi: VERSION, PLAN_NAME
  app/<слой>/lexi/…           модули Lexi::Имя для точек ядра
  app/<слой>/…                новые классы с именами upstream (SlaPolicy, CustomRole…)
  bin/                        sparse-checkout, codespace-setup, codespace-start
  docs/decisions.md           журнал решений L-xxx
  docs/updating.md            обновление под релизы fazer.ai и Chatwoot
spec/lexi/                    спеки LEXI (их гоняют lexi-ci и полный прогон run_foss_spec)
spec/lexi/upstream_specs.txt  тесты upstream, которые LEXI обязан проходить (L-013)
.devcontainer/lexi/           стенд в Codespaces (L-014)
.github/workflows/lexi-*.yml  CI и сборка образа LEXI
```

## Проверки и релиз

- `lexi-ci.yml` — на любой пуш: clean-room, Rubocop по файлам LEXI, `rspec spec/lexi`.
- `run_foss_spec.yml` (fazer.ai) — полный набор тестов Chatwoot без `enterprise/` на каждый пуш в `main`.
- `lexi-release.yml` — образ `ghcr.io/lepisevkalisey/lexi:<тег>` для amd64 и arm64 при публикации релиза, например `v4.18.0-lexi.1`.
- В описании релиза указывать основу: тег fazer.ai, например `v4.18.0-fazer-ai.125`.

Конвенции кода — те же, что у fazer.ai, см. `AGENTS.md` в корне: Rubocop, Conventional Commits, спеки на основные сценарии.
