# System Design социальной сети для курса по System Design

## Функциональные требования:
- Публикация постов из путешествий с фотографиями, небольшим описанием и привязкой к конкретному месту путешествия;
- Оценка и комментарии постов других путешественников;
- Подписка на других путешественников, чтобы следить за их активностью;
- Поиск популярных мест для путешествий и просмотр постов с этих мест в виде ТОПа мест по странам и городам;
- Общаться с другими путешественниками в личных сообщениях;
- Просматривать ленту других путешественников;
---
## Нефункциональные требования:
- DAU 10 000 000;
- Запуск только в СНГ;
- Работает онлайн из браузера и мобильных устройств;
- Availability 99.99%;
- Latency <= 1 сек на поиск READ популярных мест/прогрузку ленты других путешественников;
- Latency на WRITE комментария, поста < 2сек;
- Realtime переписка в личных сообщениях;
- WRITE Действия пользователя в день (средние значения):
  - 1 пост в неделю = 0.14 постов в день:
    -  512 символов текст поста (max 1024),
    -  5 фотографий к посту (max 10)
  - подписывается на 1 путешественника в неделю = 0.14 в день:
    - max 1000 друзей;
  - 10 комментариев к постам:
    - 128 символов в одном сообщении (max 256),
    - 1 фото в одном сообщении (max 5);
  - 100 личных сообщений текстом:
    - 128 символов одно сообщение (max 1024);
  - 20 личных сообщений фотографиями:
    -  2 фотографии в одном сообщении (max 10)
  - лайкает 50 постов,
   - ищет 3 места через поиск,
- READ Действия пользователя в день (средние значения):
  - пролистывает 200 личных сообщений,
  - чтение 200 комментариев,
  - просматривает 200 постов в ленте;
- Данные хранятся всегда;
- Количество комментариев неограничено;
- Количество/глубина просмотра истории ленты/постов/мест неограничено;
---
## Размер запросов:
[Google Sheets расчеты](https://docs.google.com/spreadsheets/d/155onyxw7PWFR-YExZn2ziP-an_p7lt6MJ3RuJGw5PVI/edit?usp=sharing)
#### _WRITE  Пост: 2 MB_
- ID пользователя: 8 B
- Текст поста: 512 символа * 2 B = 1 024 B
- Массив фотографий: 5 фото * 400 KB = 2 000 KB = 2 MB
- ГЕО: 128 байт

#### _READ Посты в ленте/фильтрации: 2 MB_
- ID поста: 8 B
- ID автора: 8 B
- ФИО автора: 256 B
- Аватар автора: 100 KB
- Текст поста: 512 символа * 2 B = 1 KB
- Фотографии: 2 MB
- Счетчик лайков: 4 символа * 2 B = 8 B
- Счетчик лайков: 4 символа * 2 B = 8 B

#### _WRITE Комментарий: 400 KB_
- ID поста: 8 B
- ID пользователя: 8 B
- Текст комментария: 128 символа * 2 B = 256 B
- Массив фото: 1 фото * 400 KB = 400 KB

#### _READ Комментарий: 500 KB_
- ID комментария: 8 B
- ID поста: 8 B
- ID пользователя: 8 B
- ФИО автора: 256 B
- Аватар автора: 100 KB
- Текст комментария: 128 символа * 2 B = 256 B
- Массив фотографий: 400 KB

#### _READ/WRITE Личное сообщение текст: 272 B_
- ID отправителя: 8 B
- ID получателя: 8 B
- Текст сообщения: 128 символа * 2 B = 256 B

#### _READ/WRITE Личное сообщение фото: 800 KB_
- ID отправителя: 8 B
- ID получателя: 8 B
- Фото в сообщении: 2 * 400 KB = 800 KB

#### _WRITE Фильтр на поиск ТОП мест: 128 B_
- Текст запроса: 64 символа * 2 B = 128 B

#### _READ/WRITE Лайк: 24 B_
- ID лайка: 8 B
- ID пользователя: 8 B
- ID поста: 8 B

#### _READ/WRITE Подписка: 24 B_
- ID подписки: 8 B
- ID подписчика: 8 B
- ID путешественника: 8 B
---
## Расчеты:
```
WRITE User traffic per day = 
Посты(0.14) * 2 MB + 
Подписка(0.14) * 24 B + 
Комментарии(10) * 0.4 MB +
Поиск мест(3) * 128 B + 
Личные сообщения текст(100) * 272 B +
Личные сообщения фото(20) * 800KB +
Лайки(50) * 24 B = 20311989,76 B = 20 MB;

READ User traffic per day = 
Личные сообщения текст(200) * 272 B +
Личные сообщения фото(20) * 800KB +
Чтение комментариев(200) * 500 KB + 
Просмотр постов(200) * 2 MB = 536 MB;

User requests per day = 0.14 + 0.14 + 10 + 100 + 20 + 50 + 3 + 200 + 200 + 200 = 783;

RPS = DAU(10 000 000) * 783 / 86 400 = 90 657;

DAU WRITE traffic per day = DAU * WRITE User traffic = 10 000 000 * 20 MB = 203 TB/day;
DAU WRITE traffic per second = DAU write per day / 86 400 = 203 TB / 86 400 = 2 GB/sec;

DAU READ traffic per day = DAU * READ User traffic per day = 10 000 000 * 536 MB = 5364 TB/day;
DAU READ traffic per second = DAU read per day / 86 400 = 5364 TB / 86 400 = 62 GB/sec;
```

CAPACITY
```
количество дисков SSD(100TB) на 1 год = 3
65 * DAU write traffic per day / SSD capacity =
365 * 203 TB / 100 TB = 741

количество дисков SSD(100TB) + 50% для подстраховки = 1112
```

THROUGHPUT
```
throughput = MAX DAU traffic per second = 62 GB
```
