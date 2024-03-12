create table "assistants" (
	"id" text primary key unique not null,
	"name" text not null,
	"content" text not null,
	"created_at" datetime not null default current_timestamp,
	"updated_at" datetime not null default current_timestamp
);

create table "threads" (
	"id" text primary key unique not null,
	"title" text not null,
	"created_at" datetime not null default current_timestamp,
	"updated_at" datetime not null default current_timestamp
);

create table "thread_messages" (
	"id" integer primary key autoincrement,
	"thread_id" integer not null references "threads" ("id"),
	"name" text not null,
	"content" text not null,
	"created_at" datetime not null default current_timestamp,
	"updated_at" datetime not null default current_timestamp
);