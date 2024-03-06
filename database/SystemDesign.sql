CREATE TABLE "posts" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid,
  "description" varchar,
  "photo_links" varchar[],
  "created_at" timestamp,
  "updated_at" timestamp
);

CREATE TABLE "post_likes" (
  "id" uuid PRIMARY KEY,
  "post_id" uuid,
  "user_id" uuid,
  "created_at" timestamp
);

CREATE TABLE "post_comments" (
  "id" uuid PRIMARY KEY,
  "user_id" uuid,
  "post_id" uuid,
  "comment" varchar,
  "photo_links" varchar[],
  "created_at" timestamp,
  "updated_at" timestamp
);

CREATE TABLE "follows" (
  "id" uuid PRIMARY KEY,
  "following_user_id" uuid,
  "followed_user_id" uuid,
  "created_at" timestamp
);

CREATE TABLE "users" (
  "id" uuid PRIMARY KEY,
  "login" varchar,
  "first_name" varchar,
  "middle_name" varchar,
  "last_name" varchar,
  "created_at" timestamp,
  "updated_at" timestamp
);

CREATE TABLE "chats" (
  "id" uuid PRIMARY KEY,
  "created_at" timestamp,
  "is_personal" boolean
);

CREATE TABLE "chat_users" (
  "chat_id" uuid,
  "user_id" uuid
);

CREATE TABLE "chat_messages" (
  "id" uuid PRIMARY KEY,
  "chat_id" uuid,
  "message" varchar,
  "created_at" timestamp,
  "updated_at" timestamp
);

ALTER TABLE "posts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "post_likes" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "post_likes" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "post_comments" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "post_comments" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "follows" ADD FOREIGN KEY ("following_user_id") REFERENCES "users" ("id");

ALTER TABLE "follows" ADD FOREIGN KEY ("followed_user_id") REFERENCES "users" ("id");

ALTER TABLE "chat_users" ADD FOREIGN KEY ("chat_id") REFERENCES "chats" ("id");

ALTER TABLE "chat_users" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "chat_messages" ADD FOREIGN KEY ("chat_id") REFERENCES "chats" ("id");
