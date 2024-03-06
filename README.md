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
#### _WRITE  Пост: 2,44 KB_
- ID пользователя: 8 B
- Текст поста: 512 символа * 2 B = 1 024 B
- Массив ссылок на фотографий (сами фото грузятся в S3 хранилище): 5 ссылок * 256 B = 1 280 B
- ГЕО: 128 байт

#### _READ Посты в ленте/фильтрации: 2,8 KB_
- ID поста: 8 B
- ID автора: 8 B
- ФИО автора: 256 B
- Ссылка на Аватар автора: 256 B
- Текст поста: 512 символа * 2 B = 1 KB
- Массив ссылок на фотографий (сами фото грузятся в S3 хранилище): 5 ссылок * 256 B = 1 280 B
- Счетчик лайков: 4 символа * 2 B = 8 B
- Счетчик лайков: 4 символа * 2 B = 8 B

#### _WRITE Комментарий: 528 B_
- ID поста: 8 B
- ID пользователя: 8 B
- Текст комментария: 128 символа * 2 B = 256 B
- Массив ссылок на фото: 1 фото * 256 B = 256 B

#### _READ Комментарий: 1 KB_
- ID комментария: 8 B
- ID поста: 8 B
- ID пользователя: 8 B
- ФИО автора: 256 B
- Аватар автора(ссылка): 256 B
- Текст комментария: 128 символа * 2 B = 256 B
- Массив фотографий: 400 KB

#### _READ/WRITE Личное сообщение текст: 272 B_
- ID отправителя: 8 B
- ID получателя: 8 B
- Текст сообщения: 128 символа * 2 B = 256 B

#### _READ/WRITE Личное сообщение фото: 528 B_
- ID отправителя: 8 B
- ID получателя: 8 B
- Ссылка на Фото в сообщении: 2 * 256 B = 512 KB

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
Посты(0.14) * 2,4 KB + 
Комментарии(10) * 528 B +
Поиск мест(3) * 128 B + 
Лайки(50) * 24 B = 2 KB;

READ User traffic per day =
Просмотр постов(200) * 2,8 KB = 560 KB;

User requests per day = 0.14 + 50 + 3 + 10 + 200 = 263;

RPS = DAU(10 000 000) * 263 / 86 400 = 30 456;

DAU WRITE traffic per day = DAU * WRITE User traffic = 10 000 000 * 2 KB = 20 GB/day;
DAU WRITE traffic per second = DAU write per day / 86 400 = 20 GB / 86 400 = 231 KB/sec;

DAU READ traffic per day = DAU * READ User traffic per day = 10 000 000 * 560 KB = 5,69 GB/day;
DAU READ traffic per second = DAU read per day / 86 400 = 5,69 GB / 86 400 = 65 MB/sec;
```

CAPACITY
```
количество дисков HDD(6TB) на 1 год =
365 * DAU write traffic per day / HDD capacity =
365 * 20 GB / 6 TB = 1,2 = 2
```

THROUGHPUT
```
throughput = MAX DAU traffic per second = 65 MB/sec;
соответственно выбор HDD оправдан с его пропускной способностью в 100 MB/sec
```
