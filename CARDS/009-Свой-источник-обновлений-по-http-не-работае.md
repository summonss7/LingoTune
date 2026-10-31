---
id: lingotune-009
title: Свой источник обновлений по http:// не работает в release-сборках (платформа блокирует cleartext)
status: done
priority: 6
created: 2026-10-31
updated: 2026-10-31
session: ""
src: TASK
wish: w_lt009http20261031
unblockTries: 0
---
## Задача
Выявлено при полевой проверке самообновления (карточка lingotune-008).
Функция «Источник обновлений» (v5.10.0) принимает любой http(s)-URL манифеста,
но release-сборка приложения режет весь cleartext-трафик (targetSdk 35,
`android:usesCleartextTraffic` не задан, network security config отсутствует).
Итог: введённый пользователем `http://…` источник ВСЕГДА отвечает
«не удалось проверить» (SocketException: Cleartext not permitted) —
валидация диалога обещает то, что приложение выполнить не может.
Локальные/LAN update-серверы (например http://192.168.x.x) без этого не работают.

Предложить решение Артёму в «Хабе ИИ» (затрагивает security-постуру приложения):
- вариант А: network security config — cleartext разрешён только для
  user-заданных источников не получится выразить per-domain (домены произвольны),
  т.е. фактически `usesCleartextTraffic="true"` на всё приложение;
- вариант Б: оставить только https в валидации диалога «Источник обновлений»
  (честно: http-URL отклоняется с пояснением);
- вариант В: не менять ничего, задокументировать ограничение.

## Критерии готовности
- [x] Выбран вариант (согласован с Артёмом через «Хаб ИИ»)
- [x] Реализован и покрыт тестами (валидация/конфиг)
- [x] P2E: на release-сборке поведение соответствует выбранному варианту
- [x] Документация обновлена (AGENTS.md «Custom update source», CHANGELOG.md)

## Журнал
- 31.10.2026: карточка создана по итогам E2E-проверки lingotune-008.


- 31.10.2026, 14:27:24: диспетчер взял задачу в работу (новый запуск).
- 31.10.2026, 14:29: диагностика по коду подтверждена: валидация принимает http/https
  (`settings_screen.dart:192`, `update_service.dart:198`), в `app/android` нет ни
  `usesCleartextTraffic`, ни network security config — release режет cleartext.
  Карточка зарегистрирована в хабе пожеланий (w_lt009http20261031). В «Хаб ИИ» отправлен
  вопрос Артёму с вариантами А/Б/В (id lingotune009_q_20261031, рекомендован Б —
  только https, http отклонять с пояснением; в debug — cleartext через debug-overrides).
  Карточка в ожидании ответа — wait: lingotune009_q_20261031.


- 31.10.2026, 14:45:22: диспетчер: получен ответ Артёма на вопрос lingotune009_q_20261031 («Хаб ИИ»): «Б — только https, http отклонять с пояснением (рекомендую)» — Артём (summons), 31.10.2026 14:44 (кнопка 2). Блокировка снята автоматически — карточка снова в очереди; ответ учти при выполнении.


- 31.10.2026, 17:56:32: диспетчер взял задачу в работу (новый запуск).
- 31.10.2026, 21:50: вариант Б реализован и проверен P2E (начало 17:56, бэкап backup.bat
  сделан). Код: `UpdateSourceValidation {ok, httpBlocked, invalid}` +
  `UpdateService.validateCustomManifestUrl()` / `parseCustomManifestUri(allowHttp:)`
  (release — только https, http отклоняется; debug (`!kReleaseMode`) — http разрешён для
  LAN-тестов); диалог в `settings_screen.dart` показывает при http отдельный красный
  снекбар-пояснение (новая строка l10n `updateSourceHttpBlocked` во всех 11 локалях,
  подпись/`updateSourceInvalid` переформулированы под https-only). Конфиг: добавлен
  `app/android/app/src/debug/AndroidManifest.xml` (`usesCleartextTraffic="true"` только
  для debug-сборок), release-манифест чист (проверяется тестом). Попутно починен
  .gitignore: паттерн `debug/` съедал android debug-манифест — заменён на `/debug/`
  (теперь файл в git). Тесты: +7 (https/http × allowHttp, валидация диалога, сохранённый
  http в debug-цепочке, отсутствие cleartext-флагов в release-манифесте) — flutter test
  91 passed, analyze 231 (базовый уровень, 0 ошибок). Сборки в builds/:
  LingoTune-v5.12.1-release-lingotune009-rc.apk и LingoTune-v5.12.1-debug-lingotune009-rc.apk
  (версию не поднимал — публикация отдельным релиз-циклом). P2E на эмуляторе
  (AVD lecards_test): RELEASE — http://192.168.1.10/manifest.json → диалог не
  закрывается, снекбар «HTTP URLs are not supported: the app blocks unencrypted
  traffic. Use an https://… address» (подтверждён скриншотом), https://example.com/
  manifest.json → принят и сохранён, Reset → возврат к дефолту; DEBUG —
  http://127.0.0.1:8377/manifest.json (python http.server + adb reverse) → принят
  диалогом, сохранён, «Check for updates» реально скачал манифест по cleartext
  (GET /manifest.json 200 в логе сервера) и предложил «New version: 9.9.9».
  Документация: KNOWLEDGE.md «Custom update source» (раздел базы знаний, вынесенной
  из AGENTS.md карточкой scheduler-064) + CHANGELOG.md. Наблюдения (не блокеры,
  фикс не требует): 1) debug-сборка показывает блокирующий диалог «Audio Service
  Error» (assertion audio_service — debug-only, в release ассеты сняты); 2) эмулятор
  один раз упал (WHPX) и активность периодически пересоздавалась — стенд, не приложение.
  Уведомление в «Хаб ИИ» (wish w_lt009http20261031).
