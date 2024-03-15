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
  "reply_comment_id" uuid,
  "comment" varchar,
  "photo_links" varchar[],
  "created_at" timestamp,
  "updated_at" timestamp
);

CREATE TABLE "subscriptions" (
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

CREATE TABLE "chat_messages" (
  "id" uuid PRIMARY KEY,
  "from_user" uuid,
  "to_user" uuid,
  "message" varchar,
  "created_at" timestamp,
  "updated_at" timestamp
);

CREATE TABLE "last_seen_messages" (
  "id" uuid PRIMARY KEY,
  "read_at" timestamp,
  "chat_id" uuid
);

ALTER TABLE "posts" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "post_likes" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "post_likes" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "post_comments" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "post_comments" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "post_comments" ADD FOREIGN KEY ("reply_comment_id") REFERENCES "post_comments" ("id");

ALTER TABLE "subscriptions" ADD FOREIGN KEY ("following_user_id") REFERENCES "users" ("id");

ALTER TABLE "subscriptions" ADD FOREIGN KEY ("followed_user_id") REFERENCES "users" ("id");

ALTER TABLE "chat_messages" ADD FOREIGN KEY ("from_user") REFERENCES "users" ("id");

ALTER TABLE "chat_messages" ADD FOREIGN KEY ("to_user") REFERENCES "users" ("id");

ALTER TABLE "last_seen_messages" ADD FOREIGN KEY ("chat_id") REFERENCES "chat_messages" ("id");
