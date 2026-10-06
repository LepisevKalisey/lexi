# LEXI

**LEXI** is a fork of [Chatwoot fazer.ai](https://github.com/fazer-ai/chatwoot) (itself a fork of [Chatwoot](https://github.com/chatwoot/chatwoot)) that adds open, clean-room implementations of Chatwoot's premium features: SLA, custom roles, audit logs and more. It is not a product of Chatwoot Inc. or FAZER.AI LTDA.

---

LEXI — форк [Chatwoot fazer.ai](https://github.com/fazer-ai/chatwoot): Chatwoot с WhatsApp по QR, группами, внутренним чатом и white label. Плюс **свои открытые реализации платных функций Chatwoot**. Код Chatwoot Enterprise (`enterprise/`) в LEXI не используется и в образ не попадает.

## Что добавляет LEXI

| Функция | Флаг аккаунта | Состояние |
|---|---|---|
| Переключатель функций аккаунта в супер-админке | — | готово |
| Отключение брендинга | `disable_branding` | работает в ядре, включается флагом |
| Обязательные атрибуты при закрытии беседы | `conversation_required_attributes` | работает в ядре, включается флагом |
| SLA: первый и следующий ответ, решение, нарушения, отчёты | `sla` | следующий этап |
| Пользовательские роли | `custom_roles` | в плане |
| Журнал аудита | `audit_logs` | в плане |

Captain (ИИ-ассистент Chatwoot) LEXI не повторяет. ИИ подключается к Chatwoot как Agent Bot.

## Установка

Образ: `ghcr.io/lepisevkalisey/lexi:<версия>`, например `v4.18.0-lexi.1`. Стек тот же, что у Chatwoot: Rails, Sidekiq, PostgreSQL с pgvector, Redis. Переход с официального Chatwoot или с fazer.ai — заменой образа, если версия LEXI не старше установленной. Перед заменой сделайте резервную копию базы.

Функции включаются для каждого аккаунта в супер-админке: **Accounts → аккаунт → Edit → Функции**.

## Разработка

Устройство, правила чистой реализации и порядок работы — [lexi/README.md](../lexi/README.md). Журнал решений — [lexi/docs/decisions.md](../lexi/docs/decisions.md). Обновление под релизы — [lexi/docs/updating.md](../lexi/docs/updating.md).

## Лицензия

Код в `lexi/` — MIT, см. [lexi/LICENSE](../lexi/LICENSE). Остальное — на условиях Chatwoot и fazer.ai: MIT вне `enterprise/` ([LICENSE](../LICENSE), [NOTICE](../NOTICE)). Каталог `enterprise/` принадлежит Chatwoot Inc. и в LEXI не используется.
