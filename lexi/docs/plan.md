# План работ LEXI: недостающие функции

Версия 05.11.2026. Основа — fazer.ai `v4.19.0-fazer-ai.145`, Chatwoot 4.19.0. Решения — [decisions.md](decisions.md).

## Как идёт каждая функция

1. **Приёмка — тесты upstream (L-013).** Файлы из `spec/enterprise/` вносятся в `spec/lexi/upstream_specs.txt`, `lexi-ci` гоняет их без `enterprise/`. Код `enterprise/` не открываем.
2. **Свои спеки.** Где тест upstream смешан с чужими функциями (Captain, биллинг), поведение LEXI покрывают спеки в `spec/lexi/`.
3. **Имена — как у upstream.** Классы, маршруты, таблицы и поля JSON совпадают с теми, что ждёт фронтенд.
4. **Встраивание.** Через точки `prepend_mod_with` (модули `Lexi::…`) и `to_prepare`. Вставки в ядро — только там, где ядро подключает enterprise-шаблон через `if ChatwootApp.enterprise?`; каждая вставка — одна строка.
5. **Каждая функция — ветка `lexi/<функция>`.** В `main` вливается, когда зелёные `lexi-ci` и полный прогон `run_foss_spec`. Затем проверка на стенде и релиз образа.

**Псевдонимы для тестов.** Три теста upstream ссылаются на константы `Enterprise::…`:
- `Enterprise::Conversations::PermissionFilterService` — подпись теста;
- `Enterprise::AuditLog` — модель;
- `Enterprise::AuditLogIpLookupJob` — задача.

Они получают псевдонимы на классы LEXI в `spec/lexi/support/upstream_aliases.rb`. Этот файл подключается только в прогоне приёмки. В рабочем коде модуля `Enterprise` нет.

## Этап 1. Завершить каркас — 05–06.11

| Что | Готово, когда |
|---|---|
| Синхронизация с fazer.ai `v4.19.0-fazer-ai.145` | `lexi-ci` и `run_foss_spec` зелёные, тег — предок `main`. **Влито 05.11** |
| Механизм приёмки: псевдонимы `Enterprise::…`, запуск манифеста в `lexi-ci` | пустой манифест и псевдонимы не ломают CI |
| Стенд: вход Админа, проверка каркаса | в супер-админке есть флаги; экраны SLA, ролей и аудита открываются без баннера «купите Enterprise»; «Звонки» скрыты; нет 404 на ассистентах Captain |
| Первый образ `v4.19.0-lexi.1` | образ в `ghcr.io/lepisevkalisey/lexi`, пакет публичный |

## Этап 2. SLA — 09–13.11

Приёмка — 12 файлов upstream, около 1500 строк и 115 проверок.

| Часть | Что сделать |
|---|---|
| `SlaPolicy` | Валидация имени; `has_many :conversations, dependent: :nullify`; `SlaPolicyDrop` (name, description) для шаблонов |
| `AppliedSla` | Статусы `active`, `hit`, `missed`, `active_with_misses`. Скоуп `with_sla_applicable_conversation`: без заблокированных контактов, но с удалённым контактом. Сроки `frt_due_at`, `nrt_due_at`, `rt_due_at`, в рабочие часы — через `Sla::BusinessHoursService`, с одним чтением рабочих часов. `push_event_data` |
| `SlaEvent` | Типы `frt`, `nrt`, `rt`. При создании подставляются аккаунт, inbox и политика. Уведомления `sla_missed_*` получают ответственный, участники и администраторы |
| Беседа и аккаунт | Через `Lexi::Concerns::Conversation`: `sla_policy`, `applied_sla`, `sla_events`; при назначении политики создаётся `AppliedSla`; `sla_applicable?` ложно для заблокированного контакта. Через `Lexi::Concerns::Account`: `sla_policies`, `applied_slas` |
| `Sla::BusinessHoursService` | Часовой пояс inbox; день открыт целиком или закрыт; перенос через выходные; у каждого дня свои часы; без рабочих часов — по часам на стене |
| `Sla::EvaluateAppliedSlaService` | Нарушения FRT, NRT и RT. NRT считается для каждого цикла ожидания. При решении беседы — `hit` или `missed`. Заблокированный контакт пропускается. Журнал — строками того же формата, что у upstream |
| Задачи | `Sla::TriggerSlasForAccountsJob` (очередь `scheduled_jobs`, только аккаунты с флагом `sla` и политиками) → `ProcessAccountAppliedSlasJob` → `ProcessAppliedSlaJob` (очередь `medium`). Запуск — в существующем планировщике ядра. `Sla::BackfillAppliedSlaCompletedAtService` и rake-задача |
| API | `SlaPoliciesController`: CRUD, менять может только администратор, удаление — через `DeleteObjectJob`. `AppliedSlasController`: список, метрики (`total_applied_slas`, `number_of_sla_misses`, `hit_rate`) и CSV с защитой от формул. Фильтры: период, агенты, политика, метки |
| Автоматизация | Действие `add_sla` в правилах и макросах (`Lexi::ActionService`) |
| Данные беседы | Вставка в `_conversation.json.jbuilder`: поля SLA и события для карточки беседы |

**Стенд.** На inbox — политика «первый ответ 15 минут в рабочее время». Нарушение видно в беседе и в отчёте SLA, уведомление приходит.

## Этап 3. Пользовательские роли — 16–20.11

Приёмка — 11 файлов upstream, около 720 строк и 43 проверки.

| Часть | Что сделать |
|---|---|
| `CustomRole` | Шесть прав (`CustomRole::PERMISSIONS`); `has_many :account_users, dependent: :nullify`. При смене прав или удалении — сброс отфильтрованных счётчиков непрочитанного и событие `account.cache_invalidated` |
| `AccountUser` | `belongs_to :custom_role`; `permissions` возвращает права роли (`Lexi::AccountUser`) |
| Видимость бесед | `Lexi::Conversations::PermissionFilterService`. `conversation_manage` — все беседы своих inbox. `conversation_unassigned_manage` — неназначенные и свои, без бесед ИИ-исполнителя. `conversation_participating_manage` — свои и те, где участник. Несколько прав — берётся более широкое |
| Политики | `ConversationPolicy`, `ContactPolicy`, `ReportPolicy`, `MessagePolicy`, `ArticlePolicy`, `CategoryPolicy`, `PortalPolicy`, `CsatSurveyResponsePolicy` — модули `Lexi::…` через точки ядра |
| API | `CustomRolesController`: CRUD, только администратор. Агентам назначается `custom_role_id` (`Lexi::Api::V1::Accounts::AgentsController`). `custom_role_id` выводится в данных агента и профиля — две вставки в шаблоны |

**Стенд.** Роль «Администратор филиала» видит только беседы своих inbox, не открывает отчёты и настройки.

## Этап 4. Журнал аудита — 23–25.11

Приёмка — 2 файла upstream, около 290 строк и 30 проверок.

| Часть | Что сделать |
|---|---|
| `Lexi::AuditLog < Audited::Audit` | `location`; `masked_remote_address` (IPv4 — последний октет, IPv6 — первые четыре группы). Задача поиска местоположения по IP — при флаге `ip_lookup` и наличии адреса. `Audited.config.audit_class` → `Lexi::AuditLog` в инициализаторе LEXI |
| Что пишется | `audited` на моделях с точками `Audit::*`: аккаунт, участник аккаунта, бот, правило автоматизации, inbox, участник inbox, макрос, команда, участник команды, пользователь, вебхук. Входы и выходы — через точку `DeviseOverrides::SessionsController` |
| API | `AuditLogsController`: только администратор; без флага — пустой список; страницы по 25. Фильтры `types`, `q` (имя или почта, в том числе текущая), `since`/`until`, `sort`; некорректные параметры игнорируются. У удалённых сообщений не отдаётся содержимое. Без флага `audit_log_ip_address` IP маскируется |

**Стенд.** Видно, кто менял макрос и кто входил.

## Параллельно и дальше

- **Русский перевод добавок fazer.ai:** около 800 ключей интерфейса, плюс бэкенд и письма. Сначала разделы, которые видят администраторы LevelUP: группы, отложенные сообщения, беседы, inbox. Остальное — следом.
- **Вторая волна** — по запросу проектов: заметки CSAT, ёмкость агентов, аналитика кампаний, мониторы бесед, SAML.

## Что нужно от Админа

- Один вход на стенде на этапе 1 — дальше проверку провожу сам.
- Для LevelUP — решения о включении: SLA, затем роль, затем аудит, по одной функции в неделю (P-168). Перевод LevelUP на образ LEXI — после этапа 2.
