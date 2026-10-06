# Обновление LEXI под релизы

Основа LEXI — релизные теги fazer.ai `vX.Y.Z-fazer-ai.N`. Upstream Chatwoot выпускает минорную версию примерно раз в месяц, fazer.ai вливает её за несколько дней. Промежуточные сборки fazer.ai берём по необходимости: исправления, нужные функции. Одно обновление — около рабочего дня.

## 1. Слить тег fazer.ai

```bash
git fetch fazer --tags
git switch -c chore/sync-vX.Y.Z-fazer-ai.N main
git merge --no-ff vX.Y.Z-fazer-ai.N -m "chore(sync): merge fazer.ai vX.Y.Z-fazer-ai.N"
```

Конфликты:

| Где | Как решать |
|---|---|
| Workflow, удалённые в LEXI (L-010), изменены у fazer.ai | оставить удалёнными: `git rm <файл>` |
| `lib/chatwoot_app.rb`, `config/application.rb`, `tailwind.config.js` | взять обе стороны: вставки LEXI плюс правки upstream |
| `enterprise/`, `spec/enterprise/` | не бывает: LEXI их не меняет. Если конфликт всё же возник, взять версию fazer.ai не открывая: `git checkout --theirs -- <путь>` |

## 2. Проверить, что изменилось у основы

```bash
OLD=<прошлый тег fazer.ai>; NEW=vX.Y.Z-fazer-ai.N
# новые и изменённые workflow: публикацию и плановые задачи — удалить
git diff --stat $OLD $NEW -- .github/workflows
# контракт, на который опирается LEXI
git diff $OLD $NEW -- app/javascript/dashboard/api/sla.js app/javascript/dashboard/api/slaReports.js \
  app/javascript/dashboard/api/customRole.js app/javascript/dashboard/api/auditLogs.js \
  app/javascript/dashboard/routes/dashboard/settings/sla app/javascript/dashboard/routes/dashboard/settings/customRoles \
  app/javascript/dashboard/routes/dashboard/settings/auditlogs config/features.yml config/routes.rb
git diff $OLD $NEW -- db/schema.rb | grep -nE "sla_|custom_roles|audits" || true
# точки подмешивания: класс переименован или убран — спек extension_points упадёт
git diff $OLD $NEW -G'prepend_mod_with|include_mod_with|extend_mod_with' --stat -- app lib
```

Изменился API-клиент или экран — поправить бэкенд LEXI под новый контракт в той же ветке.

## 3. Прогнать проверки и влить

1. `git push -u origin chore/sync-…` — `lexi-ci.yml` должен быть зелёным.
2. Влить в `main` merge-коммитом, не squash: `git switch main && git merge --no-ff chore/sync-… && git push`.
3. Пуш в `main` запускает полный набор `run_foss_spec.yml`. Дождаться зелёного.
4. Проверить, что тег стал предком: `git merge-base --is-ancestor vX.Y.Z-fazer-ai.N main && echo ok`.

## 4. Выпустить образ

```bash
gh release create vX.Y.Z-lexi.1 --repo LepisevKalisey/lexi --target main \
  --title "LEXI vX.Y.Z-lexi.1" --notes "Основа: vX.Y.Z-fazer-ai.N. Изменения LEXI: …"
```

`lexi-release.yml` собирает `ghcr.io/lepisevkalisey/lexi:vX.Y.Z-lexi.1` и `latest`. Номер после `lexi.` растёт с каждым релизом LEXI на той же версии Chatwoot.

## 5. Обновить установки проектов

По одной: резервная копия базы → новый тег образа в compose → перезапуск (миграции выполняются при старте) → проверка по чек-листу проекта.
